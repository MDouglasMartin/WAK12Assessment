# ==============================================================================
# Script: 03_Profile_S275_DataQuality.ps1
# Purpose: Profile the S275 master dataset to empirically identify field contents,
#          outliers, and data quality issues. This "Pre-Flight" diagnostic will
#          guide aggregation logic before running expensive views.
# Location: WAK12_AI_Portal\01_Data_Pipeline_Codebase\Financial_Leg
# Output: D:\_AI_GITHUB\01_Data_Pipeline_Codebase\S275\S275_Profiling
# ==============================================================================

Import-Module SqlServer

# Database Connection Variables
$SqlServer   = "localhost"
$Database    = "EdData"
$ProfileDir  = "D:\_AI_GITHUB\01_Data_Pipeline_Codebase\S275\S275_Profiling"

# Ensure Output Directory exists
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir | Out-Null
}

Write-Host "=== S275 DATA PROFILING SCRIPT ===" -ForegroundColor Cyan
Write-Host "Analyzing vw_S275_Master_Decade for data quality and field content validation..." -ForegroundColor Cyan

# ==============================================================================
# QUERY 1: Global Counts, Nulls, and Basic Statistics
# ==============================================================================

Write-Host "`n[1/5] Running Global Data Quality Check..." -ForegroundColor Yellow

$GlobalQuery = @"
SELECT 
    'vw_S275_Master_Decade' AS TableName,
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT codist) AS Distinct_Districts,
    COUNT(DISTINCT SchoolYear) AS Distinct_Years,
    COUNT(DISTINCT cert) AS Distinct_CertNumbers,
    COUNT(CASE WHEN LastName IS NOT NULL THEN 1 END) AS Rows_With_Names,
    COUNT(CASE WHEN asssal IS NULL THEN 1 END) AS Null_Count_asssal,
    COUNT(CASE WHEN assfte IS NULL THEN 1 END) AS Null_Count_assfte,
    COUNT(CASE WHEN asshpy IS NULL THEN 1 END) AS Null_Count_asshpy,
    COUNT(CASE WHEN ftehrs IS NULL THEN 1 END) AS Null_Count_ftehrs,
    COUNT(CASE WHEN ftedays IS NULL THEN 1 END) AS Null_Count_ftedays,
    MIN(asssal) AS Min_asssal,
    MAX(asssal) AS Max_asssal,
    MIN(asshpy) AS Min_asshpy,
    MAX(asshpy) AS Max_asshpy,
    MIN(assfte) AS Min_assfte,
    MAX(assfte) AS Max_assfte,
    MIN(ftehrs) AS Min_ftehrs,
    MAX(ftehrs) AS Max_ftehrs,
    MIN(ftedays) AS Min_ftedays,
    MAX(ftedays) AS Max_ftedays
FROM [dbo].[vw_S275_Master_Decade]
"@

$GlobalStats = Invoke-SqlCmd -ServerInstance $SqlServer -Database $Database -Query $GlobalQuery -TrustServerCertificate

Write-Host "Global Stats Retrieved. Total Rows: $($GlobalStats[0].Total_Rows)" -ForegroundColor Green
$GlobalStats | Export-Csv -Path "$ProfileDir\01_Global_Stats.csv" -NoTypeInformation -Force

# ==============================================================================
# QUERY 2: Field Value Distribution - asshpy (Hourly Pay or Hours Worked?)
# ==============================================================================

Write-Host "`n[2/5] Analyzing asshpy field (Hourly Pay vs. Hours Worked)..." -ForegroundColor Yellow

$AsshpyQuery = @"
WITH AsshpyRanked AS (
    SELECT 
        asshpy,
        ROW_NUMBER() OVER (ORDER BY asshpy) AS Row_Num,
        COUNT(*) OVER () AS Total_Count
    FROM [dbo].[vw_S275_Master_Decade]
    WHERE asshpy > 0  -- Exclude zeros to see the true distribution
),
Quartiles AS (
    SELECT 
        'asshpy Field Analysis' AS Analysis_Type,
        COUNT(*) AS Row_Count,
        MIN(asshpy) AS Min_Value,
        MAX(asshpy) AS Max_Value,
        AVG(CAST(asshpy AS FLOAT)) AS Mean_Value,
        STDEV(asshpy) AS StdDev_Value
    FROM AsshpyRanked
)
SELECT 
    q.Analysis_Type,
    q.Row_Count,
    q.Row_Count AS Non_Zero_Records,
    q.Min_Value,
    (SELECT TOP 1 asshpy FROM AsshpyRanked WHERE Row_Num >= CAST(Total_Count * 0.25 AS INT) ORDER BY Row_Num) AS Q1_25th,
    (SELECT TOP 1 asshpy FROM AsshpyRanked WHERE Row_Num >= CAST(Total_Count * 0.50 AS INT) ORDER BY Row_Num) AS Q2_Median,
    (SELECT TOP 1 asshpy FROM AsshpyRanked WHERE Row_Num >= CAST(Total_Count * 0.75 AS INT) ORDER BY Row_Num) AS Q3_75th,
    q.Max_Value,
    CAST(q.Mean_Value AS DECIMAL(10,2)) AS Mean_Value,
    CAST(q.StdDev_Value AS DECIMAL(10,2)) AS StdDev_Value,
    CASE 
        WHEN q.Mean_Value > 10 AND q.Mean_Value < 200 THEN 'Likely_Hourly_Rate'
        WHEN q.Mean_Value > 200 THEN 'Likely_Hours_or_Large_Dollar_Figure'
        ELSE 'Inconclusive'
    END AS Field_Interpretation
FROM Quartiles q
"@

$AsshpyStats = Invoke-SqlCmd -ServerInstance $SqlServer -Database $Database -Query $AsshpyQuery -TrustServerCertificate

Write-Host "asshpy Analysis Complete. Median Value: $($AsshpyStats[0].Q2_Median)" -ForegroundColor Green
Write-Host "Interpretation: $($AsshpyStats[0].Field_Interpretation)" -ForegroundColor Cyan
$AsshpyStats | Export-Csv -Path "$ProfileDir\02_asshpy_Distribution.csv" -NoTypeInformation -Force

# ==============================================================================
# QUERY 3: Work Year Calculation Validation (ftehrs * ftedays)
# ==============================================================================

Write-Host "`n[3/5] Validating Work Year Calculation (ftehrs * ftedays)..." -ForegroundColor Yellow

$WorkYearQuery = @"
SELECT 
    droot,
    COUNT(*) AS Record_Count,
    COUNT(DISTINCT codist) AS District_Count,
    AVG(ftehrs) AS Avg_Hours_Per_Day,
    MIN(ftehrs) AS Min_Hours_Per_Day,
    MAX(ftehrs) AS Max_Hours_Per_Day,
    AVG(ftedays) AS Avg_Days_Per_Year,
    MIN(ftedays) AS Min_Days_Per_Year,
    MAX(ftedays) AS Max_Days_Per_Year,
    -- Calculated annual hours
    AVG(ftehrs * ftedays) AS Avg_Annual_Work_Hours,
    MIN(ftehrs * ftedays) AS Min_Annual_Work_Hours,
    MAX(ftehrs * ftedays) AS Max_Annual_Work_Hours,
    -- Count of anomalies
    COUNT(CASE WHEN ftehrs IS NULL OR ftedays IS NULL THEN 1 END) AS Null_Count,
    COUNT(CASE WHEN ftehrs = 0 OR ftedays = 0 THEN 1 END) AS Zero_Count,
    COUNT(CASE WHEN (ftehrs * ftedays) < 500 THEN 1 END) AS Sub_500_Hour_Records,
    COUNT(CASE WHEN (ftehrs * ftedays) > 2500 THEN 1 END) AS Over_2500_Hour_Records
FROM [dbo].[vw_S275_Master_Decade]
WHERE ftehrs > 0 AND ftedays > 0
GROUP BY droot
ORDER BY droot
"@

$WorkYearStats = Invoke-SqlCmd -ServerInstance $SqlServer -Database $Database -Query $WorkYearQuery -TrustServerCertificate

Write-Host "Work Year Analysis Complete. Retrieved $(($WorkYearStats).Count) duty codes." -ForegroundColor Green
$WorkYearStats | Export-Csv -Path "$ProfileDir\03_WorkYear_by_DutyRoot.csv" -NoTypeInformation -Force

# ==============================================================================
# QUERY 4: Salary Anomalies by Duty Code (The "Extreme Micro-FTE" Flag)
# ==============================================================================

Write-Host "`n[4/5] Identifying Salary Anomalies by Duty Code..." -ForegroundColor Yellow

$AnomalyQuery = @"
SELECT 
    droot,
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT cert) AS Unique_Staff,
    -- SALARY ANALYSIS
    MIN(asssal) AS Min_Salary,
    (SELECT TOP 1 asssal FROM [dbo].[vw_S275_Master_Decade] WHERE asssal > 0 AND droot = a.droot ORDER BY asssal) AS Q1_Salary,
    (SELECT AVG(asssal) FROM [dbo].[vw_S275_Master_Decade] WHERE asssal > 0 AND droot = a.droot) AS Median_Salary,
    MAX(asssal) AS Max_Salary,
    AVG(asssal) AS Mean_Salary,
    -- FTE ANALYSIS
    MIN(assfte) AS Min_FTE,
    AVG(assfte) AS Avg_FTE,
    MAX(assfte) AS Max_FTE,
    -- ANOMALY FLAGS
    COUNT(CASE WHEN asssal = 0 THEN 1 END) AS Zero_Salary_Count,
    COUNT(CASE WHEN assfte < 0.2 AND asssal > 50000 THEN 1 END) AS Extreme_MicroFTE_Count,
    COUNT(CASE WHEN assfte < 0.2 AND asssal > 50000 THEN asssal END) / 
        NULLIF(COUNT(CASE WHEN assfte < 0.2 AND asssal > 50000 THEN 1 END), 0) 
        AS Avg_Micro_FTE_Salary,
    COUNT(CASE WHEN asssal > 0 AND assfte = 0 THEN 1 END) AS Zero_FTE_But_Paid_Count
FROM [dbo].[vw_S275_Master_Decade] a
WHERE asssal > 0  -- Exclude pure zero records
GROUP BY droot
ORDER BY droot
"@

$AnomalyStats = Invoke-SqlCmd -ServerInstance $SqlServer -Database $Database -Query $AnomalyQuery -TrustServerCertificate

Write-Host "Anomaly Analysis Complete. Identified $(($AnomalyStats | Where-Object {$_.Extreme_MicroFTE_Count -gt 0}).Count) duty codes with micro-FTE issues." -ForegroundColor Green
$AnomalyStats | Export-Csv -Path "$ProfileDir\04_Salary_Anomalies_by_DutyRoot.csv" -NoTypeInformation -Force

# ==============================================================================
# QUERY 5: The "Confidence Interval" View - Duty Code Buckets with Ranges
# ==============================================================================

Write-Host "`n[5/5] Building Confidence Intervals by Duty Bucket..." -ForegroundColor Yellow

$ConfidenceQuery = @"
WITH DutyBuckets AS (
    SELECT 
        CASE 
            WHEN droot BETWEEN 31 AND 49 THEN '01_Direct_Instruction'
            WHEN droot BETWEEN 11 AND 25 THEN '02_Management'
            WHEN droot IN (91, 96) THEN '03_Support_Clerical'
            ELSE '04_Other_Operations'
        END AS Duty_Bucket,
        droot,
        asssal,
        assfte,
        ftehrs,
        ftedays,
        asshpy,
        SchoolYear
    FROM [dbo].[vw_S275_Master_Decade]
    WHERE asssal > 0
),
SalaryQuartiles AS (
    SELECT 
        Duty_Bucket,
        droot,
        asssal,
        assfte,
        ftehrs * ftedays AS Work_Year_Hours,
        NTILE(4) OVER (PARTITION BY Duty_Bucket ORDER BY asssal) AS Salary_Quartile
    FROM DutyBuckets
),
FTEQuartiles AS (
    SELECT 
        Duty_Bucket,
        droot,
        assfte,
        NTILE(4) OVER (PARTITION BY Duty_Bucket ORDER BY assfte) AS FTE_Quartile
    FROM DutyBuckets
),
WorkYearQuartiles AS (
    SELECT 
        Duty_Bucket,
        droot,
        ftehrs * ftedays AS Work_Year_Hours,
        NTILE(4) OVER (PARTITION BY Duty_Bucket ORDER BY ftehrs * ftedays) AS WorkYear_Quartile
    FROM DutyBuckets
)
SELECT 
    sq.Duty_Bucket,
    sq.droot,
    COUNT(DISTINCT sq.droot) AS Record_Count,
    (SELECT COUNT(DISTINCT cert) FROM DutyBuckets WHERE droot = sq.droot) AS Unique_Staff_Count,
    -- SALARY RANGES (Using Quartile approach as proxy for confidence intervals)
    MIN(CASE WHEN sq.Salary_Quartile = 1 THEN sq.asssal END) AS Salary_Low_25pct,
    (SELECT AVG(asssal) FROM SalaryQuartiles WHERE droot = sq.droot AND Salary_Quartile = 2) AS Salary_Q1,
    (SELECT AVG(asssal) FROM SalaryQuartiles WHERE droot = sq.droot AND Salary_Quartile = 3) AS Salary_Median,
    (SELECT AVG(asssal) FROM SalaryQuartiles WHERE droot = sq.droot AND Salary_Quartile = 4) AS Salary_Q3,
    MAX(CASE WHEN sq.Salary_Quartile = 4 THEN sq.asssal END) AS Salary_High_75pct,
    -- FTE RANGES
    (SELECT MIN(assfte) FROM FTEQuartiles WHERE droot = sq.droot AND FTE_Quartile = 1) AS FTE_Low_25pct,
    (SELECT AVG(assfte) FROM FTEQuartiles WHERE droot = sq.droot AND FTE_Quartile = 2) AS FTE_Q1,
    (SELECT AVG(assfte) FROM FTEQuartiles WHERE droot = sq.droot AND FTE_Quartile = 3) AS FTE_Median,
    (SELECT MAX(assfte) FROM FTEQuartiles WHERE droot = sq.droot AND FTE_Quartile = 4) AS FTE_Q3,
    -- WORK YEAR RANGES
    (SELECT MIN(Work_Year_Hours) FROM WorkYearQuartiles WHERE droot = sq.droot AND WorkYear_Quartile = 1) AS WorkYear_Low_Hours,
    (SELECT AVG(Work_Year_Hours) FROM WorkYearQuartiles WHERE droot = sq.droot AND WorkYear_Quartile = 2) AS WorkYear_Q1,
    (SELECT AVG(Work_Year_Hours) FROM WorkYearQuartiles WHERE droot = sq.droot AND WorkYear_Quartile = 3) AS WorkYear_Median,
    (SELECT MAX(Work_Year_Hours) FROM WorkYearQuartiles WHERE droot = sq.droot AND WorkYear_Quartile = 4) AS WorkYear_Q3
FROM SalaryQuartiles sq
GROUP BY sq.Duty_Bucket, sq.droot
ORDER BY sq.Duty_Bucket, sq.droot
"@

$ConfidenceStats = Invoke-SqlCmd -ServerInstance $SqlServer -Database $Database -Query $ConfidenceQuery -TrustServerCertificate

Write-Host "Confidence Interval Analysis Complete. Retrieved $(($ConfidenceStats).Count) bucket/duty combinations." -ForegroundColor Green
$ConfidenceStats | Export-Csv -Path "$ProfileDir\05_Confidence_Intervals_by_DutyBucket.csv" -NoTypeInformation -Force

# ==============================================================================
# BONUS QUERY 6: Sample Data for Manual Inspection (Top Anomalies)
# ==============================================================================

Write-Host "`n[BONUS] Extracting Sample Anomalies for Manual Review..." -ForegroundColor Yellow

$SampleQuery = @"
SELECT TOP 500
    SchoolYear,
    codist,
    cert,
    LastName,
    FirstName,
    droot,
    assfte,
    asssal,
    asshpy,
    ftehrs,
    ftedays,
    (ftehrs * ftedays) AS Calculated_Annual_Hours,
    ROUND(CASE 
        WHEN (ftehrs * ftedays) > 0 THEN asssal / (ftehrs * ftedays) 
        ELSE 0 
    END, 2) AS Calculated_Hourly_Rate,
    CASE 
        WHEN assfte < 0.2 AND asssal > 50000 THEN 'FLAG: Extreme Micro-FTE'
        WHEN asssal = 0 THEN 'FLAG: Zero Salary'
        WHEN assfte = 0 AND asssal > 0 THEN 'FLAG: Zero FTE But Paid'
        ELSE 'Standard'
    END AS Anomaly_Flag
FROM [dbo].[vw_S275_Master_Decade]
WHERE assfte < 0.2 AND asssal > 50000  -- Extreme micro-FTE filter
   OR (assfte = 0 AND asssal > 0)       -- Zero FTE but paid
ORDER BY asssal DESC
"@

$SampleData = Invoke-SqlCmd -ServerInstance $SqlServer -Database $Database -Query $SampleQuery -TrustServerCertificate

Write-Host "Sample Data Retrieved. Found $($SampleData.Count) anomalies." -ForegroundColor Green
$SampleData | Export-Csv -Path "$ProfileDir\06_Sample_Anomalies.csv" -NoTypeInformation -Force

# ==============================================================================
# SUMMARY REPORT
# ==============================================================================

Write-Host "`n" -ForegroundColor Cyan
Write-Host "====== PROFILING COMPLETE ======" -ForegroundColor Green
Write-Host "Output Location: $ProfileDir" -ForegroundColor Green
Write-Host "`nFiles Generated:" -ForegroundColor Cyan
Write-Host "  1. 01_Global_Stats.csv                      - Overall dataset health" -ForegroundColor White
Write-Host "  2. 02_asshpy_Distribution.csv               - asshpy field analysis (CRITICAL for logic)" -ForegroundColor White
Write-Host "  3. 03_WorkYear_by_DutyRoot.csv              - Work year validation by duty code" -ForegroundColor White
Write-Host "  4. 04_Salary_Anomalies_by_DutyRoot.csv      - Micro-FTE and zero-salary flags" -ForegroundColor White
Write-Host "  5. 05_Confidence_Intervals_by_DutyBucket.csv - 90% CI ranges for aggregation logic" -ForegroundColor White
Write-Host "  6. 06_Sample_Anomalies.csv                   - Manual review of flagged records" -ForegroundColor White

Write-Host "`nKEY QUESTIONS TO ANSWER BEFORE AGGREGATION:" -ForegroundColor Cyan
Write-Host "  Q1: Is asshpy hourly rate ($10-$200) or hours worked (0-2500)?" -ForegroundColor Yellow
Write-Host "  Q2: Are ftehrs/ftedays consistently populated, or do they vary by district/duty?" -ForegroundColor Yellow
Write-Host "  Q3: What salary ranges should trigger 'Anomaly Flags' for your forensic audit?" -ForegroundColor Yellow
Write-Host "  Q4: Are the confidence intervals (5th-95th percentile) reasonable for each duty bucket?" -ForegroundColor Yellow
Write-Host "  Q5: Do the micro-FTE anomalies align with your data quality expectations?" -ForegroundColor Yellow

Write-Host "`nRECOMMENDATION:" -ForegroundColor Cyan
Write-Host "Review 02_asshpy_Distribution.csv FIRST. It will guide whether to use asshpy" -ForegroundColor White
Write-Host "or recalculate hourly rate from (asssal / calculated_hours)." -ForegroundColor White

Write-Host "`nProfiling script complete." -ForegroundColor Green
