
??? Process Summary: The EdData "No-Fail" Pipeline
1. The Starting Point
We began with 11 years of raw OSPI S-275 Personnel Access Databases (.accdb). Initial scans revealed that while each database only contained one primary table, the headers were inconsistent. We identified three distinct versions (51, 52, and 54 columns) as the state added new data points like National Board expiry and Address Confidentiality over the decade.
2. The Lean Transformation
To eliminate Muda (waste), we abandoned a multi-stage staging/cleaning process in favor of a One-Step "No-Fail" Extractor. This script connects directly to the raw Access files on your D: drive and executes the following logic in a single pass:
* Targeting: Filtered strictly for Program 01 (General Education) and Certificated Staff ($certfte > 0$).
* Redaction: Dropped all First and Last names to ensure the public drive contains zero PII (Personally Identifiable Information).
* Standardization: Forced all output into a 5-digit County-District Code (CODIST) folder structure to prevent "101 vs 00101" mapping errors.
3. The "Smash" (Data Integration)
We built a parallel Assessment Parser that mirrors the S-275 structure. It takes the granular OSPI assessment shards and roll-ups and converts them into "AI-Ready" yield files.
* The Key: We used a 5-digit EntityKey to link Payroll to Performance.
* The Index: We generated a EdData_Master_Index.csv that acts as the "Card Catalog," allowing the AI to navigate directly to specific district files without loading the entire state into memory.
4. Trade-offs & Gains
* Limited: By isolating Program 01, we intentionally "underestimated" total spending by excluding Special Ed and Transportation. This was a strategic choice to close the "bureaucratic trap door"-preventing officials from using non-instructional costs to defend poor academic yields.
* Gained: We achieved Longitudinal Integrity. We can now track the "Yield Decay" of a specific cohort from 3rd grade to the 10th-grade "Graduation Minimum" while calculating the Best-Case Scenario Unit Cost for a successful student.

?? The Resultant Code Base: One-Step Master Extractor
This is the finalized logic that creates your "App-Ready" financial data.
PowerShell
<#
.SYNOPSIS
    S-275 ONE-STEP EXTRACTOR (Cycle 1 Goal)
    From Raw Access (.accdb) -> Redacted/Filtered District History (.csv)
#>

$sourceDir = "D:\PROJECTS\EdDataAI\GdriveShadow\S275"
$finalDir  = "D:\PROJECTS\EdDataAI\GdriveShadow\S275_APP_READY"

if (!(Test-Path $finalDir)) { New-Item -ItemType Directory -Path $finalDir | Out-Null }

$files = Get-ChildItem -Path $sourceDir -Filter "*.accdb"
$columns = "SchoolYear, codist, cert, certfte, certbase, tfinsal, prog, act, droot, grade, bldgn, asssal"

foreach ($file in $files) {
    Write-Host "`n>>> Processing Year: $($file.Name)" -ForegroundColor Cyan
    $connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$($file.FullName);"
    $conn = New-Object System.Data.OleDb.OleDbConnection($connString)

    try {
        $conn.Open()
        $schema = $conn.GetSchema("Tables")
        $tableName = ($schema.Rows | Where-Object { $_.TABLE_TYPE -eq "TABLE" -and $_.TABLE_NAME -notlike "MSys*" })[0].TABLE_NAME
        
        $testCmd = New-Object System.Data.OleDb.OleDbCommand("SELECT TOP 1 * FROM [$tableName]", $conn)
        $testReader = $testCmd.ExecuteReader()
        $colsPresent = for ($i=0; $i -lt $testReader.FieldCount; $i++) { $testReader.GetName($i) }
        $testReader.Close()
        
        $distCol = if ($colsPresent -contains "CountyDistrictCode") { "CountyDistrictCode" } else { "codist" }

        $distCmd = New-Object System.Data.OleDb.OleDbCommand("SELECT DISTINCT [$distCol] FROM [$tableName] WHERE [$distCol] IS NOT NULL", $conn)
        $distTable = New-Object System.Data.DataTable
        (New-Object System.Data.OleDb.OleDbDataAdapter($distCmd)).Fill($distTable) | Out-Null

        foreach ($row in $distTable.Rows) {
            $rawCodist = $row.$distCol
            $cleanCodist = "{0:D5}" -f [int]$rawCodist
            $historyFile = Join-Path $finalDir "History_Dist_${cleanCodist}.csv"

            # FILTER: Gen Ed (Prog 01) and Certificated Staff Only
            $sql = "SELECT $columns FROM [$tableName] WHERE [$distCol] = ? AND [prog] = '01' AND [certfte] > 0"
            $dataCmd = New-Object System.Data.OleDb.OleDbCommand($sql, $conn)
            $dataCmd.Parameters.Add("?", $rawCodist) | Out-Null

            $results = New-Object System.Data.DataTable
            (New-Object System.Data.OleDb.OleDbDataAdapter($dataCmd)).Fill($results) | Out-Null

            if ($results.Rows.Count -gt 0) {
                $results | Export-Csv -Path $historyFile -NoTypeInformation -Append
            }
            $results.Dispose()
        }
    } catch {
        Write-Host " -> ERROR: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $conn.Close()
    }
}

Next Step
Now that the EdData_Master_Index.csv is generated and your files are aligned, would you like me to perform the Final Vetting Sweep on the Seattle (17001) data to verify the $L1-L4$ counts and the Best-Case Scenario Unit Cost calculations?

