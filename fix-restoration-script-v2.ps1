# More robust script to add user_id
$inputFile = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA.sql"
$outputFile = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA-FIXED.sql"
$userId = "f7fdf4cf-7101-45ab-86db-5248a7ac58c1"

# Read each line to process individually
$lines = Get-Content $inputFile -Encoding UTF8
$output = New-Object System.Collections.ArrayList

$inInsertStatement = $false
$insertLineCount = 0

foreach ($line in $lines) {
    if ($line -match '^\-\- \d+/\d+:') {
        # This is a comment before an INSERT, reset counter
        $insertLineCount = 0
        [void]$output.Add($line)
    }
    elseif ($line -match '^INSERT INTO clientes \(') {
        # This is the start of an INSERT statement
        $inInsertStatement = $true
        $insertLineCount = 1
        [void]$output.Add($line)
    }
    elseif ($inInsertStatement -and $insertLineCount -eq 1 -and $line -match '^\s*id, empresa_id,') {
        # This is the column list line - add user_id
        $newLine = $line -replace 'id, empresa_id,', 'id, user_id, empresa_id,'
        [void]$output.Add($newLine)
        $insertLineCount++
    }
    elseif ($inInsertStatement -and $line -match '^\) VALUES \(') {
        # This is the VALUES keyword
        [void]$output.Add($line)
        $insertLineCount++
    }
    elseif ($inInsertStatement -and $insertLineCount -ge 3 -and $line -match "^\s*'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',") {
        # This is the first value line with the ID UUID
        [void]$output.Add($line)
        # Add the user_id line right after
        [void]$output.Add("  '$userId',")
        $insertLineCount++
    }
    elseif ($inInsertStatement -and $line -match '^\);') {
        # End of INSERT statement
        $inInsertStatement = $false
        $insertLineCount = 0
        [void]$output.Add($line)
    }
    else {
        # Regular line
        [void]$output.Add($line)
        if ($inInsertStatement) {
            $insertLineCount++
        }
    }
}

# Write output
$output | Set-Content $outputFile -Encoding UTF8

Write-Host "Fixed SQL file created: $outputFile" -ForegroundColor Green
Write-Host "Total lines processed: $($lines.Count)" -ForegroundColor Cyan
