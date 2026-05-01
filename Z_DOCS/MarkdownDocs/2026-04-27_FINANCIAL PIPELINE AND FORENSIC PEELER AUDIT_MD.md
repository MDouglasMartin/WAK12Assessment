FINANCIAL PIPELINE AND FORENSIC PEELER AUDIT
Session Reference: 202602101102.docx Objective: Establish the true mathematical Cost of Poor Quality (COPQ) and build the forensic tools required to extract data from OSPI's shifting historical file formats.

1. The Core Philosophy & Financial Logic (The "Why")
This section defines how we calculate the monetary cost of the system's failure, shifting the focus from "annual budgets" to "cumulative manufacturing costs."
* The "Total Pipeline" Sunk Cost: We do not evaluate the system on its $20,000 "Annual Burn Rate." In Lean Six Sigma (LSS), the product requires a 12-year manufacturing cycle. The true "Gross Investment" per student is the cumulative pipeline cost (e.g., ~$240,000+ by 10th grade).
* The "Unit Cost of Proficiency" (The Muda Multiplier): If a district has a 33% yield in Math (the Anchor Metric), it takes the budget of three students to produce one that meets the quality specification. Therefore, the true, scrap-adjusted cash cost to produce a single proficient unit is $720,000+.
* The "Daily Rate" Labor Normalization: To accurately assess the value of the labor being purchased, instructional salaries (based on a 180-day/7.5-hour cycle) must be normalized. A $120,000 teacher salary equates to a $666 daily rate-which, if projected to a standard 240-day professional work year, represents a $160,000 market-value position.
2. The Data Architecture & Extraction (The "How")
This documents the specific challenges found in the raw OSPI data files and how the pipeline was designed to defeat them.
* The OSPI "Process Drift" (2015 vs. 2024): The state frequently changes how it reports data to obscure historical analysis.
o Pre-2021: Data was stored in generic "Staggered Grade" sheets.
o 2021-2022 Anomaly: "Fall 2021" tested previous year grades due to COVID delays.
o Post-2022: Data moved to a specific "Frequency Distribution" tab with a 4-column layout.
* The "Forensic Peeler" Solution: A PowerShell script (Forensic_Peeler_v2.6.ps1) dynamically detects the era of the Excel file (FS15 through FS25), bypassing OSPI's format obfuscation to extract raw Student Counts and Scale Scores.
* The "Suppression" Trap: OSPI replaces counts <10 with an asterisk (*) or <10. The parser catches these and safely converts/nullifies them without crashing the script or falsely reporting a 0% proficiency rate.
3. The "Wrong Paths" (What Was Rejected & Why)
* Rejected Path: Blaming "Administrative Bloat".
o Why we killed it: It is a Red Herring. Admin costs only represent ~10-15% of the total spend. Even if you fired every administrator, the "Unit Cost of Proficiency" remains astronomically high because the instructional process itself has a 70% scrap rate. Focus remains on Total System Cost vs. General Ed Instructional Cost.
* Rejected Path: Single-Year Unit Costing.
o Why we killed it: It ignores the "Work in Progress" (WIP) debt. A 10th-grade failure represents 10-11 years of wasted capital, not just one. We strictly apply the "Cumulative Pipeline" multiplier.

4. The Preserved Code Base
Script 1: Forensic_Peeler_v2.6.ps1
Purpose: Iterates through user-cleaned OSPI Excel files (FS15.xlsx to FS25.xlsx), automatically switching logic based on the year (modern 4-column vs. historic staggered) to rip out raw Scale Scores and Counts.
PowerShell
<#
.SYNOPSIS
    Forensic_Peeler_v2.6
    Extracts raw student counts and scale scores from OSPI frequency files (FS15-FS25).
    Handles dynamic format changes and suppression characters (*, <10).
#>

$sourceDir = "D:\Downloads" 
$outputFile = "D:\PROJECTS\EdDataAI\GdriveShadow\Assessment_ScaleScores_Master.csv"
$excelFiles = Get-ChildItem -Path $sourceDir -Filter "FS*.xlsx"

$masterData = @()

# Use COM Object to read Excel without needing heavy modules
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

foreach ($file in $excelFiles) {
    Write-Host "Peeling data from: $($file.Name)" -ForegroundColor Cyan
    
    # Determine the Year from the filename (e.g., FS15 -> 2015)
    $yearMatch = [regex]::Match($file.Name, '\d{2}')
    $year = if ($yearMatch.Success) { "20" + $yearMatch.Value } else { "Unknown" }
    
    $workbook = $excel.Workbooks.Open($file.FullName)
    $worksheet = $workbook.Sheets.Item(1) # Assuming cleaned data is on sheet 1
    
    $maxRow = $worksheet.UsedRange.Rows.Count
    $maxCol = $worksheet.UsedRange.Columns.Count

    # Logic Switch: Modern (Post-2022) vs Historic (Staggered)
    if ([int]$year -ge 2022) {
        # MODERN FORMAT: 4 Columns (Grade, Subject, ScaleScore, Count)
        for ($row = 2; $row -le $maxRow; $row++) {
            $grade = $worksheet.Cells.Item($row, 1).Text
            $subject = $worksheet.Cells.Item($row, 2).Text
            $scaleScore = $worksheet.Cells.Item($row, 3).Text
            $countStr = $worksheet.Cells.Item($row, 4).Text
            
            # Suppression Trap Handler
            $cleanCount = if ($countStr -match "\*|<10" -or [string]::IsNullOrWhiteSpace($countStr)) { 0 } else { $countStr }

            if (![string]::IsNullOrWhiteSpace($scaleScore)) {
                $masterData += [PSCustomObject]@{
                    SchoolYear = $year
                    GradeLevel = $grade
                    Subject    = $subject
                    ScaleScore = $scaleScore
                    Count      = $cleanCount
                    SourceFile = $file.Name
                }
            }
        }
    } else {
        # HISTORIC FORMAT: Staggered columns (Iterate through columns looking for Score/Count pairs)
        for ($col = 1; $col -le ($maxCol - 1); $col += 2) {
            $header = $worksheet.Cells.Item(1, $col).Text
            
            # Example header: "MATH 10 Scale Score"
            if ($header -match "(MATH|ELA)\s*(\d+)") {
                $subject = $matches[1]
                $grade = $matches[2]
                
                for ($row = 2; $row -le $maxRow; $row++) {
                    $scaleScore = $worksheet.Cells.Item($row, $col).Text
                    $countStr = $worksheet.Cells.Item($row, $col + 1).Text
                    
                    $cleanCount = if ($countStr -match "\*|<10" -or [string]::IsNullOrWhiteSpace($countStr)) { 0 } else { $countStr }
                    
                    if (![string]::IsNullOrWhiteSpace($scaleScore)) {
                        $masterData += [PSCustomObject]@{
                            SchoolYear = $year
                            GradeLevel = $grade
                            Subject    = $subject
                            ScaleScore = $scaleScore
                            Count      = $cleanCount
                            SourceFile = $file.Name
                        }
                    }
                }
            }
        }
    }
    $workbook.Close($false)
}

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

$masterData | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "Forensic Peeling Complete. Data saved to $outputFile" -ForegroundColor Green
Script 2: Join_LSS_Education_Data.ps1
Purpose: Merges cleaned expenditure data with assessment yield data to calculate the ultimate Lean Six Sigma metric: The Unit_Cost_Proficiency.
PowerShell
<#
.SYNOPSIS
    LSS Proficiency-Cost Mapper
    Merges wsacfExpd_Cleaned.csv and Assessment1-3.csv to calculate the actual Cost of Poor Quality (COPQ).
#>

$financeFile = "D:\PROJECTS\EdDataAI\GdriveShadow\wsacfExpd_Cleaned.csv"
$assessmentFile = "D:\PROJECTS\EdDataAI\GdriveShadow\Assessment1-3.csv"
$outputFile = "D:\PROJECTS\EdDataAI\GdriveShadow\LSS_Master_ROI_Table.csv"

# Load the datasets
$financeData = Import-Csv $financeFile
$assmtData = Import-Csv $assessmentFile

# Create a lookup hash table for Finance Data based on DistrictID + Year
$financeLookup = @{}
foreach ($row in $financeData) {
    $key = "$($row.DistrictID)_$($row.SchoolYear)"
    $financeLookup[$key] = $row
}

$lssMasterTable = @()

Write-Host "Merging Financial and Assessment Yields..." -ForegroundColor Cyan

foreach ($assmt in $assmtData) {
    $key = "$($assmt.DistrictID)_$($assmt.SchoolYear)"
    
    if ($financeLookup.ContainsKey($key)) {
        $fin = $financeLookup[$key]
        
        # Ensure we have valid math numbers
        $annualPPE = [double]($fin.TotalPPE -replace '[^\d.]', '')
        $testedCount = [double]$assmt.TestedCount
        $survivedQA = [double]$assmt.L3_Count + [double]$assmt.L4_Count
        
        if ($testedCount -gt 0 -and $survivedQA -gt 0) {
            # LSS Formula: Pipeline Investment (11 years) / First Pass Yield
            $firstPassYieldPct = $survivedQA / $testedCount
            $pipelineCost = $annualPPE * 11  # K-10 Pipeline
            
            $unitCostProficiency = $pipelineCost / $firstPassYieldPct
            
            $lssMasterTable += [PSCustomObject]@{
                SchoolYear            = $assmt.SchoolYear
                DistrictID            = $assmt.DistrictID
                GradeLevel            = $assmt.GradeLevel
                Subject               = $assmt.Subject
                FirstPassYield_Pct    = [math]::Round($firstPassYieldPct, 4)
                Annual_PPE            = $annualPPE
                Pipeline_Sunk_Cost    = $pipelineCost
                Unit_Cost_Proficiency = [math]::Round($unitCostProficiency, 2)
            }
        }
    }
}

$lssMasterTable | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "LSS Mapping Complete. True Unit Costs generated at $outputFile" -ForegroundColor Green

