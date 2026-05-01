# ==============================================================================
# Script: 02_Export_Financial_Txts.ps1
# Purpose: Extract S275 financial data from SQL Server into pipe-delimited shards
#          by district to minimize AI token waste while preserving data integrity.
# Location: WAK12_AI_Portal\01_Data_Pipeline_Codebase\Financial_Leg
# ==============================================================================

# Ensure SQL Server module is loaded for Invoke-SqlCmd
Import-Module SqlServer

# Database Connection Variables
$SqlServer   = "localhost" # Update with actual SQL Server instance if needed
$Database    = "EdData"    
$ExportDir   = "D:\_AI_GITHUB\S275"

# Ensure Export Directory exists
if (-not (Test-Path $ExportDir)) {
    New-Item -ItemType Directory -Path $ExportDir | Out-Null
}

# ---------------------------------------------------------------------------  
# Write a DataTable to a Pipe-Separated Text File (.txt)  
# ---------------------------------------------------------------------------  
function Write-PipeText([System.Data.DataTable]$dt, [string]$path) {  
    $sb = New-Object System.Text.StringBuilder  
      
    # 1. Build Headers  
    $headers = $dt.Columns | ForEach-Object { $_.ColumnName }  
    $sb.AppendLine(($headers -join "|")) | Out-Null  
      
    # 2. Build Data Rows  
    foreach ($row in $dt.Rows) {  
        $fields = foreach ($col in $dt.Columns) {  
            $v = $row[$col.ColumnName]  
            if ($v -is [System.DBNull]) {   
                ""   
            }  
            else {   
                # Escape newlines so they don't break the row format  
                $v.ToString().Replace("`n", " ").Replace("`r", "")   
            }  
        }  
        $sb.AppendLine(($fields -join "|")) | Out-Null  
    }  
      
    [System.IO.File]::WriteAllText($path, $sb.ToString(), [System.Text.Encoding]::UTF8)  
    return $dt.Rows.Count  
}

# ---------------------------------------------------------------------------
# 1. Fetch Distinct District Codes (codist)
# ---------------------------------------------------------------------------
Write-Host "Fetching distinct district codes..." -ForegroundColor Cyan
$DistQuery = "SELECT DISTINCT codist FROM S275_2023_2024 WHERE codist IS NOT NULL ORDER BY codist"
# Added -TrustServerCertificate to bypass local SSL validation
$DistrictTable = Invoke-SqlCmd -ServerInstance $SqlServer -Database $Database -Query $DistQuery -TrustServerCertificate

# ---------------------------------------------------------------------------
# 2. Extract and Shard Data by District
# ---------------------------------------------------------------------------
Write-Host "Starting extraction and sharding process..." -ForegroundColor Cyan
foreach ($Row in $DistrictTable) {
    $DistrictCode = $Row.codist
    $FileName = "S275_D_$DistrictCode.txt"
    $FilePath = Join-Path -Path $ExportDir -ChildPath $FileName

    # The SQL query pulls the core financial metrics and calculates the true hourly rate.
    # It explicitly surfaces extreme salary-to-FTE anomalies for evaluation.
    $DataQuery = @"
        SELECT 
            SchoolYear,
            codist,
            certno,
            droot,
            assfte,
            asssal,
            -- Calculate True Hourly Rate (assuming certificated 1350 baseline for this shard)
            ROUND(CASE 
                WHEN (assfte * 1350) > 0 THEN asssal / (assfte * 1350) 
                ELSE 0 
            END, 2) AS True_Hourly_Rate,
            -- Explicit Anomaly Flagging: Identify micro-FTEs with disproportionate salaries
            CASE 
                WHEN assfte < 0.2 AND asssal > 50000 THEN 'FLAG: Extreme Micro-FTE / Split-Code'
                WHEN asssal = 0 THEN 'FLAG: Zero Salary'
                ELSE 'Standard'
            END AS Process_Anomaly_Flag
        FROM 
            S275_2023_2024
        WHERE 
            codist = '$DistrictCode'
            AND prog = '01'
"@
    
    # Added -TrustServerCertificate to bypass local SSL validation
    $DataTable = Invoke-SqlCmd -ServerInstance $SqlServer -Database $Database -Query $DataQuery -TrustServerCertificate
    
    # Verify data exists before attempting to write the shard
    if ($null -ne $DataTable -and $DataTable.Rows.Count -gt 0) {
        $RowCount = Write-PipeText -dt $DataTable -path $FilePath
        Write-Host "Exported $RowCount rows to $FileName"
    } else {
        # Wrapped DistrictCode in braces to prevent colon syntax error
        Write-Host "Skipped ${DistrictCode}: No Program 01 records found." -ForegroundColor Yellow
    }
}

Write-Host "Pipeline extraction complete." -ForegroundColor Green