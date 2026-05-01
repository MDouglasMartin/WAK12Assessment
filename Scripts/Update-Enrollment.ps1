PowerShell
# ==============================================================================
# LSS Pipeline: GitHub-Autonomous Enrollment & Sharding
# ==============================================================================
$outputFolder = "./Enrollment"
$shardFolder = "./Enrollment/Shards"
if (-not (Test-Path $shardFolder)) { New-Item -ItemType Directory -Path $shardFolder -Force | Out-Null }

$masterData = @()
$datasetIds = @{
    "2023-24" = "q4ba-s3jc"; "2022-23" = "dij7-mbxg"; "2021-22" = "ymi4-syjv";
    "2020-21" = "nvpc-yr7b"; "2019-20" = "gtd3-scga"; "2018-19" = "u4gd-6wxx";
    "2017-18" = "fs63-sd8y"; "2016-17" = "y85c-tmgt"; "2015-16" = "ajpq-2bg9";
    "2014-15" = "i9gq-g35m"
}
$validGrades = @("Kindergarten", "1st Grade", "2nd Grade", "3rd Grade", "4th Grade", "5th Grade", "6th Grade", "7th Grade", "8th Grade", "9th Grade", "10th Grade", "11th Grade", "12th Grade")

foreach ($year in $datasetIds.Keys | Sort-Object -Descending) {
    $id = $datasetIds[$year]
    $url = "https://data.wa.gov/resource/${id}.csv?`$limit=150000"
    try {
        $csvData = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "Mozilla/5.0" } -TimeoutSec 300
        $currentYearRecords = $csvData | Where-Object { $_.organizationlevel -eq 'District' -and $validGrades -contains $_.gradelevel } | Group-Object -Property districtcode | ForEach-Object {
            $propNames = $_.Group[0].psobject.properties.name
            $allCol = $propNames | Where-Object { $_ -match "all.*student" } | Select-Object -First 1
            [PSCustomObject]@{ SchoolYear = $_.Group[0].schoolyear; DistrictCode = $_.Group[0].districtcode; Total_K12_Enrollment = (($_.Group | Measure-Object -Property $allCol -Sum).Sum) }
        }
        if ($currentYearRecords.Count -ge 250) { $masterData += $currentYearRecords }
    } catch { Write-Host "FAIL: ${year}" }
    Start-Sleep -Seconds 2
}

$districts = $masterData | Select-Object -ExpandProperty DistrictCode -Unique
foreach ($code in $districts) {
    $districtData = $masterData | Where-Object { $_.DistrictCode -eq $code } | Sort-Object SchoolYear
    $districtData | Export-Csv -Path "$shardFolder/Enrollment_D_${code}.csv" -NoTypeInformation
}
$masterData | Sort-Object SchoolYear, DistrictCode | Export-Csv -Path "$outputFolder/Enrollment_Fact_AllYears.csv" -NoTypeInformation
