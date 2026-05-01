
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

