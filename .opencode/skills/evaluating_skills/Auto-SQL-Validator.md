# SKILL: Autonomous SQL Validation Pipeline

**Description:** This skill executes a two-phase compilation and linting loop to guarantee PostgreSQL compliance and architectural best practices for database definition scripts.
**Target File:** `outputs/05-db-definition-G<GroupNumber>.sql`
**Log File:** `outputs/logs/05-validation-log.md`

## CORE DIRECTIVES

1. **Never skip Phase 1.** A file must pass Phase 1 with 0 errors before Phase 2 begins.
2. **Strict Logging:** Every time a script fails, you must append the error, your analysis, and the fix to the log file before rewriting the `.sql` file.
3. **Max Retries:** You have a maximum of 4 attempts per phase. If you fail 4 times, halt execution and ask the human for help.

---

## PHASE 1: Native Syntax Compilation Loop

**Goal:** Eliminate all hard syntax errors and dialect mismatches (e.g., T-SQL vs PostgreSQL).

### Step 1.1: Execute Test

Run the following PowerShell block to test the file natively in PostgreSQL. (Replace `[FILE]` with the actual filename):

```powershell
docker run --name pg-test -e POSTGRES_PASSWORD=admin -d postgres:15
Start-Sleep -Seconds 5
docker cp [FILE] pg-test:/test.sql
docker exec pg-test psql -U postgres -f /test.sql
docker rm -f pg-test
```

### Step 1.2: Evaluate Output

IF PASS: The output only contains CREATE TABLE, CREATE INDEX, etc., and contains NO ERROR: strings. Proceed to Phase 2.

IF FAIL: The output contains ERROR:.

Log the exact error line to 05-validation-log.md.

Analyze why the PostgreSQL compiler rejected it.

Rewrite the [FILE] to fix the error.

Loop back to Step 1.1.

## PHASE 2: Atlas Architectural Linting Loop

**Goal**: Enforce database design best practices (indexing, constraints, nullability).

### Step 2.1: Execute Linting

Run the following PowerShell command to evaluate the architecture:

```PowerShell
atlas schema lint --dev-url "docker://postgres/15/dev" --url "file://[FILE]"
```

### Step 2.2: Evaluate Output

IF PASS: Atlas returns no warnings or errors. The pipeline is fully complete.

IF FAIL: Atlas outputs architectural warnings (e.g., missing index on foreign key).

Log the warnings to 05-validation-log.md.

Modify the [FILE] to satisfy the architectural requirements (e.g., add CREATE INDEX statements).
Loop back to Step 2.1.
