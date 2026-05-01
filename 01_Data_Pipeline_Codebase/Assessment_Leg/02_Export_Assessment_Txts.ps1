# =============================================================================
# 02_Export_Assessment_TXT.ps1
# WA K12 Assessment Export -- AI Optimized (Pipe-Separated TXT)
# =============================================================================

param(
    [string]$SqlServer  = "localhost",
    [string]$Database   = "EdData",
    [string]$OutputPath = "D:\_AI_GITHUB\Assessment"
)

$ErrorActionPreference = "Continue"
$StartTime = Get-Date
$FileCount = 0
$RowCount  = 0
$Errors    = @()

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " WA K12 Assessment AI-Optimized Export (.txt)" -ForegroundColor Cyan
Write-Host " Started: $StartTime" -ForegroundColor Cyan
Write-Host " Server:  $SqlServer" -ForegroundColor Cyan
Write-Host " Output:  $OutputPath" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "Created output folder: $OutputPath" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Run a SQL query and return a DataTable
# ---------------------------------------------------------------------------
function Run-Query([string]$Sql) {
    $conn = New-Object System.Data.SqlClient.SqlConnection("Server=$SqlServer;Database=$Database;Integrated Security=True;")
    $conn.Open()
    $cmd             = $conn.CreateCommand()
    $cmd.CommandText = $Sql
    $cmd.CommandTimeout = 300
    $dt      = New-Object System.Data.DataTable
    $reader  = $cmd.ExecuteReader()
    $dt.Load($reader)
    $conn.Close()
    return ,$dt
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
# STEP 1: Master_Org_Index
# ---------------------------------------------------------------------------
Write-Host "STEP 1: Exporting Master_Org_Index..." -ForegroundColor Green

$idxSql = "SELECT OrgIndexId, OrgCodeKey, OrganizationLevel, ESDOrganizationId, ESDName, " +
          "DistrictCode, DistrictName, SchoolCode, SchoolName, DisplayName, [RowCount], FileIndex " +
          "FROM dbo.Master_Org_Index " +
          "ORDER BY OrganizationLevel, ESDOrganizationId, DistrictCode, SchoolCode"

try {
    $idxData = Run-Query $idxSql
    $idxPath = Join-Path $OutputPath "Master_Org_Index.txt"
    $n = Write-PipeText $idxData $idxPath
    Write-Host "  Master_Org_Index.txt -- $n rows" -ForegroundColor White
    $FileCount++
    $RowCount += $n
} catch {
    $msg = "ERROR exporting Master_Org_Index: $_"
    Write-Host $msg -ForegroundColor Red
    $Errors += $msg
}

# ---------------------------------------------------------------------------
# STEP 2: Get file list
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "STEP 2: Getting file list..." -ForegroundColor Green

$fileListSql = "SELECT DISTINCT FileIndex FROM dbo.Master_Org_Index WHERE FileIndex IS NOT NULL ORDER BY FileIndex"

try {
    $fileList = Run-Query $fileListSql
    Write-Host "  Found $($fileList.Rows.Count) files to export" -ForegroundColor White
} catch {
    Write-Host "ERROR getting file list: $_" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# STEP 3: Export one TXT per FileIndex
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "STEP 3: Exporting data files (.txt)..." -ForegroundColor Green
Write-Host ""

$dataSqlTemplate = "SELECT F.OrgIndexId, F.GradYear, F.SchoolYear, F.StudentGroup, F.GradeLevel, F.DAT, " +
    "F.[Count of Students Expected to Test] AS CountExpected, " +
    "F.CountMetStandard AS CountMet, " +
    "F.[Count of Students Expected to Test included previously passed] AS CountPrevPassed, " +
    "F.PercentMetStandard_OSPI AS PctMet_OSPI, " +
    "F.PercentMetStandard AS PctMet, " +
    "F.PercentLevel1 AS L1, F.PercentLevel2 AS L2, F.PercentLevel3 AS L3, F.PercentLevel4 AS L4, " +
    "F.[Percent Foundational Grade-Level Knowledge And Above] AS PctFoundational, " +
    "F.[Count Foundational Grade-Level Knowledge And Above] AS CountFoundational, " +
    "F.[Percent Taking Alternative Assessment] AS PctAltAssessment, " +
    "F.DataAsOf, F.PctMet_L3L4_Flag AS PctMet_Flag, F.PctMet_L3L4_Delta AS PctMet_Delta " +
    "FROM dbo.Assessment_Fact F " +
    "JOIN dbo.Master_Org_Index I ON I.OrgIndexId = F.OrgIndexId " +
    "WHERE I.FileIndex = '{FI}' " +
    "ORDER BY F.OrgIndexId, F.SchoolYear, F.GradeLevel, F.StudentGroup"

$i = 0
foreach ($row in $fileList.Rows) {
    $fi = $row[0].ToString()
    $i++
    $pct = [math]::Round(($i / $fileList.Rows.Count) * 100)
    Write-Progress -Activity "Exporting" -Status "$fi ($i of $($fileList.Rows.Count))" -PercentComplete $pct

    $sql      = $dataSqlTemplate.Replace("{FI}", $fi.Replace("'","''"))
    $filePath = Join-Path $OutputPath "$fi.txt"

    try {
        $data = Run-Query $sql
        if ($data.Rows.Count -eq 0) {
            Write-Host "  WARNING: $fi -- 0 rows, skipping" -ForegroundColor Yellow
            continue
        }
        $n = Write-PipeText $data $filePath
        Write-Host ("  {0,-55} {1,5} rows" -f "$fi.txt", $n) -ForegroundColor White
        $FileCount++
        $RowCount += $n
    } catch {
        $msg = "ERROR exporting $fi : $_"
        Write-Host $msg -ForegroundColor Red
        $Errors += $msg
    }
}

Write-Progress -Activity "Exporting" -Completed

# ---------------------------------------------------------------------------
# STEP 4: Summary
# ---------------------------------------------------------------------------
$Elapsed = (Get-Date) - $StartTime

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Export Complete" -ForegroundColor Cyan
Write-Host " Elapsed:  $([math]::Round($Elapsed.TotalMinutes,1)) minutes" -ForegroundColor Cyan
Write-Host " Files:    $FileCount" -ForegroundColor Cyan
Write-Host " Rows:     $RowCount" -ForegroundColor Cyan
if ($Errors.Count -gt 0) {
    Write-Host " Errors:   $($Errors.Count)" -ForegroundColor Red
    $Errors | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
} else {
    Write-Host " Errors:   0" -ForegroundColor Green
}
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""