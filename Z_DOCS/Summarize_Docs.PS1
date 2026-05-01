# ==============================================================================
# LSS Documentation Pipeline: .doc to .md Converter & Indexer
# ==============================================================================
$sourceDir = "D:\_AI_GITHUB\DOCS\OtherDocuments\"
$targetDir = "D:\_AI_GITHUB\DOCS\MarkdownDocs\"
$indexFile = Join-Path -Path $targetDir -ChildPath "00_Master_Document_Index.md"
$cutoffDate = Get-Date "2026-02-07"

# Create target directory
if (!(Test-Path -Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }

# Initialize Master Index
"# Washington State K-12 AI Portal: Document Index`n*Generated on $(Get-Date -Format 'yyyy-MM-dd')*`n" | Out-File $indexFile -Encoding utf8

Write-Host "Initializing Word COM Object..." -ForegroundColor Cyan
$word = New-Object -ComObject Word.Application
$word.Visible = $false

# Fetch docs, filter by date, and sort
$docs = Get-ChildItem -Path $sourceDir -Filter *.doc* | 
        Where-Object { $_.CreationTime -ge $cutoffDate } | 
        Sort-Object Name

foreach ($doc in $docs) {
    $datePrefix = $doc.CreationTime.ToString("yyyy-MM-dd")
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($doc.Name)
    $newName = "${datePrefix}_${baseName}.md"
    $targetPath = Join-Path -Path $targetDir -ChildPath $newName
    
    Write-Host "Processing: $newName" -ForegroundColor Yellow

    try {
        $document = $word.Documents.Open($doc.FullName)
        
        # 1. Extract text for the Index Summary
        $fullText = $document.Content.Text
        $lines = $fullText -split "`r`n|`r|`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        $summary = if ($lines.Count -gt 0) { $lines[0] } else { "No readable text found." }
        
        # Truncate summary if it's too long
        if ($summary.Length -gt 250) { $summary = $summary.Substring(0, 247) + "..." }
        
        # 2. Append to Master Index
        "- **[$newName]($newName)**: *$summary*`n" | Out-File $indexFile -Append -Encoding utf8

        # 3. Save as plain text (.md)
        $document.SaveAs([ref]$targetPath, [ref]2) # 2 = wdFormatText
        $document.Close()
    } catch {
        Write-Host "Failed to process: $($doc.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

$word.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "Conversion complete. Index and files saved to $targetDir" -ForegroundColor Green