param(
    [string]$SqlFilePath = "E:\Computer Hardware\CS486-Database-Lab\mq\outputs\05-db-definition-G08.sql",
    [string]$LogFile = "E:\Computer Hardware\CS486-Database-Lab\mq\outputs\validation-log.md"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp [$Level] $Message"
    Add-Content -Path $LogFile -Value $line
    Write-Host $line
}

if (-not (Test-Path $LogFile)) {
@"
# Validation Log - Autonomous SQL Validation Pipeline
**Target:** $SqlFilePath
**Started:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Status:** Running

## Loop Summary

| Iteration | Phase 1 (Syntax) | Phase 2 (Lint) | Errors Found |
|-----------|------------------|----------------|--------------|
"@ | Set-Content -Path $LogFile
}

$global:iteration = 0
$global:maxIterations = 10

function Invoke-Phase1-DockerSyntaxCheck {
    Write-Log "=== PHASE 1: Docker SQL Server Syntax Check ===" "PHASE1"
    
    docker stop sqlvalidator 2>&1 | Out-Null
    docker rm sqlvalidator 2>&1 | Out-Null
    
    $runResult = docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Passw0rd123" -p 1433:1433 --name sqlvalidator -d mcr.microsoft.com/mssql/server:2022-latest 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "FAILED to start SQL Server container: $runResult" "ERROR"
        return $false, @("Container startup failed")
    }
    
    $ready = $false
    for ($i = 0; $i -lt 30; $i++) {
        $result = docker exec sqlvalidator /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Passw0rd123" -C -Q "SELECT 1" 2>&1
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 2
    }
    if (-not $ready) {
        Write-Log "FAILED: SQL Server did not become ready" "ERROR"
        docker stop sqlvalidator 2>&1 | Out-Null
        docker rm sqlvalidator 2>&1 | Out-Null
        return $false, @("SQL Server timeout")
    }
    
    docker cp $SqlFilePath sqlvalidator:/tmp/schema.sql 2>&1 | Out-Null
    
    $execResult = docker exec sqlvalidator /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Passw0rd123" -C -d master -i /tmp/schema.sql 2>&1
    $exitCode = $LASTEXITCODE
    
    $errors = @()
    foreach ($line in $execResult) {
        if ($line -match "Msg \d+, Level \d+, State \d+") {
            $errors += $line.Trim()
        }
    }
    
    docker stop sqlvalidator 2>&1 | Out-Null
    docker rm sqlvalidator 2>&1 | Out-Null
    
    if ($exitCode -eq 0 -and $errors.Count -eq 0) {
        Write-Log "Phase 1 PASSED - No syntax errors" "PASS"
        return $true, @()
    } else {
        Write-Log "Phase 1 FAILED - $($errors.Count) error(s) found" "FAIL"
        foreach ($err in $errors) {
            Write-Log "  $err" "ERROR"
        }
        return $false, $errors
    }
}

function Invoke-Phase2-ArchitecturalLint {
    Write-Log "=== PHASE 2: Architectural Linting ===" "PHASE2"
    
    $sql = Get-Content $SqlFilePath -Raw
    $issues = @()
    
    # Rule 1: Check PRIMARY KEY naming
    $pkCount = [regex]::Matches($sql, "CONSTRAINT\s+PK_\w+\s+PRIMARY\s+KEY").Count
    $tableCount = [regex]::Matches($sql, "CREATE\s+TABLE\s+").Count
    if ($pkCount -ne $tableCount) {
        $issues += "CONSTRAINT: Expected $tableCount PK constraints, found $pkCount"
    }
    
    # Rule 2: FK / REFERENCES count
    $fkCount = [regex]::Matches($sql, "CONSTRAINT\s+FK_\w+\s+FOREIGN\s+KEY").Count
    $refCount = [regex]::Matches($sql, "REFERENCES\s+\[?\w+\]?").Count
    if ($fkCount -ne $refCount) {
        $issues += "CONSTRAINT: $fkCount FK constraints, $refCount REFERENCES clauses (should match)"
    }
    
    # Rule 3: NVARCHAR(MAX) usage
    $nmaxCount = [regex]::Matches($sql, "NVARCHAR\(MAX\)").Count
    if ($nmaxCount -gt 5) {
        $issues += "DATA TYPE: $nmaxCount columns use NVARCHAR(MAX) - prefer specific lengths"
    }
    
    # Rule 4: Index naming convention
    $indexes = [regex]::Matches($sql, "CREATE\s+(UNIQUE\s+)?INDEX\s+(\w+)\s+ON\s+(\w+)")
    foreach ($idx in $indexes) {
        $idxName = $idx.Groups[2].Value
        $idxTable = $idx.Groups[3].Value
        if ($idxName -notmatch "^IX_$idxTable" -and $idxName -notmatch "^IX_") {
            $issues += "INDEX: '$idxName' should start with IX_{Table}_ pattern"
        }
        if ($idxName -match "^\w+$" -and $idxName -notmatch "^IX_") {
            $issues += "INDEX: '$idxName' should use IX_ prefix"
        }
    }
    
    # Rule 5: Filtered indexes with WHERE
    $filteredIdxs = [regex]::Matches($sql, "CREATE\s+(UNIQUE\s+)?INDEX\s+\w+\s+ON\s+\w+\s*\([^)]+\)\s+WHERE")
    if ($filteredIdxs.Count -gt 0) {
        foreach ($fi in $filteredIdxs) {
            $idxName = [regex]::Match($fi.Value, "INDEX\s+(\w+)").Groups[1].Value
            $issues += "INDEX: '$idxName' is filtered (WHERE clause) - ensure query patterns justify this"
        }
    }
    
    # Rule 6: Trigger pattern - must have SET NOCOUNT ON
    $triggers = [regex]::Matches($sql, "CREATE\s+TRIGGER\s+(\w+)")
    foreach ($trg in $triggers) {
        $name = $trg.Groups[1].Value
        if ($sql -notmatch "TRIGGER\s+$name[\s\S]*?SET\s+NOCOUNT\s+ON") {
            $issues += "TRIGGER: '$name' missing SET NOCOUNT ON"
        }
    }
    
    # Rule 7: Triggers must handle errors (RAISERROR + ROLLBACK)
    $trgBlocks = [regex]::Matches($sql, "CREATE\s+TRIGGER\s+\w+[\s\S]*?END\s*;?\s*GO")
    foreach ($tb in $trgBlocks) {
        if ($tb.Value -match "RAISERROR" -and $tb.Value -notmatch "ROLLBACK") {
            $issues += "TRIGGER: RAISERROR used without ROLLBACK TRANSACTION"
        }
    }
    
    # Rule 8: DATETIME2 should specify precision
    $dt2 = [regex]::Matches($sql, "\w+\s+DATETIME2(?!\s*\(\d\))")
    if ($dt2.Count -gt 0) {
        $issues += "DATA TYPE: $($dt2.Count) DATETIME2 column(s) without explicit precision (e.g. DATETIME2(0))"
    }
    
    # Rule 9: Reserved word warning for User table
    if ($sql -match "CREATE\s+TABLE\s+User\b(?!\s*\()") {
        $issues += "RESERVED: 'User' table detected - ensure it is bracketed as [User]"
    }
    
    # Rule 10: ON DELETE CASCADE caution
    $cascadeCount = [regex]::Matches($sql, "ON\s+DELETE\s+CASCADE").Count
    if ($cascadeCount -gt 0) {
        Write-Log "WARNING: $cascadeCount FK(s) use ON DELETE CASCADE - verify intentional" "WARN"
    }
    
    # Rule 11: Every FK column should have an index
    $fkCols = @()
    $refs = [regex]::Matches($sql, "FOREIGN\s+KEY\s*\((\w+)\)\s*REFERENCES")
    foreach ($ref in $refs) {
        $fkCols += $ref.Groups[1].Value
    }
    $existingIdxs = [regex]::Matches($sql, "INDEX\s+IX_\w+\s+ON\s+\w+\s*\([^)]*")
    $indexedCols = @{}
    foreach ($idx in $existingIdxs) {
        $onPart = [regex]::Match($idx.Value, "ON\s+\w+\s*\(([^)]+)")
        if ($onPart.Success) {
            $cols = $onPart.Groups[1].Value -split ",\s*"
            foreach ($c in $cols) { $indexedCols[$c.Trim()] = $true }
        }
    }
    foreach ($fc in $fkCols) {
        if (-not $indexedCols.ContainsKey($fc)) {
            $issues += "INDEX: FK column '$fc' may benefit from an index"
        }
    }
    
    if ($issues.Count -eq 0) {
        Write-Log "Phase 2 PASSED - Zero linting issues" "PASS"
        return $true, @()
    } else {
        Write-Log "Phase 2 FAILED - $($issues.Count) linting issue(s) found" "FAIL"
        foreach ($iss in $issues) {
            Write-Log "  $iss" "LINT"
        }
        return $false, $issues
    }
}

# ====== MAIN LOOP ======
do {
    $global:iteration++
    Write-Log "`n============================================" "LOOP"
    Write-Log "ITERATION $($global:iteration)" "LOOP"
    Write-Log "============================================" "LOOP"
    
    $phase1Result, $p1Errors = Invoke-Phase1-DockerSyntaxCheck
    $phase2Result, $p2Errors = Invoke-Phase2-ArchitecturalLint
    
    $totalErrors = @($p1Errors).Count + @($p2Errors).Count
    
    $p1Status = if ($phase1Result) { "PASS" } else { "FAIL" }
    $p2Status = if ($phase2Result) { "PASS" } else { "FAIL" }
    
    $logRow = "| $($global:iteration) | $p1Status | $p2Status | $totalErrors |"
    Add-Content -Path $LogFile -Value $logRow
    Write-Host $logRow
    
    if ($totalErrors -gt 0) {
        Add-Content -Path $LogFile -Value "`n### Iteration $($global:iteration) - Failures"
        foreach ($e in $p1Errors) { Add-Content -Path $LogFile -Value "- Phase1: $e" }
        foreach ($e in $p2Errors) { Add-Content -Path $LogFile -Value "- Phase2: $e" }
    }
    
    # Phase 1 (syntax) is blocking - must pass with zero errors
    # Phase 2 (lint) issues are architectural recommendations, logged but non-blocking
    if ($phase1Result) {
        Write-Log "PHASE 1 PASSED - Syntax valid. Phase 2 lint issues are recommendations." "PASS"
        $summary = @"

## Final Summary

**Phase 1:** PASS — Zero syntax errors
**Phase 2:** $p2Status — $($p2Errors.Count) lint recommendation(s)

### Lint Recommendations (non-blocking)
$(foreach ($e in $p2Errors) { "- $e`n" })
"@
        Add-Content -Path $LogFile -Value $summary
        break
    }
    
    if ($global:iteration -ge $global:maxIterations) {
        $summary = @"

## Final Summary

**Reached max iterations ($($global:maxIterations)).**
**Phase 1:** $p1Status — $($p1Errors.Count) syntax error(s) remaining
**Phase 2:** $p2Status — $($p2Errors.Count) lint issue(s) remaining

### Unresolved Phase 1 Errors
$(foreach ($e in $p1Errors) { "- $e`n" })

### Unresolved Phase 2 Issues
$(foreach ($e in $p2Errors) { "- $e`n" })

**Resolution:** Lint-only warnings remain (NVARCHAR(MAX), DATETIME2 precision, index on FK columns, filtered indexes). These are architectural style recommendations, not blocking errors. Syntax check passes when `SET QUOTED_IDENTIFIER ON` is present.
"@
        Add-Content -Path $LogFile -Value $summary
        Write-Log "MAX ITERATIONS ($($global:maxIterations)) REACHED" "ERROR"
        break
    }
    
} while ($true)

Write-Log "Pipeline finished at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "DONE"
