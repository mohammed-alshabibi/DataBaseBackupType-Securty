/*
====================================================
           BACKUP TYPES SUMMARY
====================================================

1. FULL BACKUP
----------------------------------------------------
- When Used: Regular baseline (e.g., weekly)
- Includes: Entire database (data + transaction log at backup time)
- Pros: Simple, reliable recovery point
- Cons: Slow for large DBs, storage-heavy
- Example: Weekly backup of hospital database

2. DIFFERENTIAL BACKUP
----------------------------------------------------
- When Used: Daily after full backup
- Includes: All changes since last full backup
- Pros: Faster and smaller than full backups
- Cons: Requires latest full backup to restore
- Example: Daily differential for student records

3. TRANSACTION LOG BACKUP
----------------------------------------------------
- When Used: Frequently (e.g., hourly) for PIT recovery
- Includes: Transactions since last log backup
- Pros: Enables point-in-time recovery
- Cons: Requires FULL recovery model, complex restore
- Example: Hourly logs for a banking system

4. COPY-ONLY BACKUP
----------------------------------------------------
- When Used: Ad-hoc/testing without breaking backup chain
- Includes: Snapshot of current state
- Pros: Doesn’t interfere with backup schedule
- Cons: Not part of restore chain
- Example: Backup before testing a hospital patch

5. FILE or FILEGROUP BACKUP
----------------------------------------------------
- When Used: Large databases, targeted filegroups
- Includes: Only specified file/filegroup
- Pros: Efficient for big DBs with partitions
- Cons: More complex to restore, not common in small DBs
- Example: Backup only patient imaging filegroup

====================================================
End of Backup Summary Documentation
====================================================
*/

-- ================================
-- PART 1 & PART 2: PRACTICE BACKUPS
-- ================================

-- Step 1: Create Test Database
CREATE DATABASE TrainingDB;
GO

USE TrainingDB;
GO

-- Step 2: Create Sample Table
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FullName NVARCHAR(100),
    EnrollmentDate DATE
);

-- Step 3: Insert Sample Data
INSERT INTO Students VALUES  
(1, 'Sara Ali', '2023-09-01'),
(2, 'Mohammed Nasser', '2023-10-15');

-- Step 4: Full Backup
BACKUP DATABASE TrainingDB 
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\TrainingDB_Full.bak';
GO

-- Step 5: Simulate Data Change
INSERT INTO Students VALUES 
(3, 'Fatma Said', '2024-01-10');
GO

-- Step 6: Differential Backup
BACKUP DATABASE TrainingDB 
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\TrainingDB_Diff.bak' 
WITH DIFFERENTIAL;
GO

-- Step 7: Set Recovery Model to FULL for Log Backup
ALTER DATABASE TrainingDB 
SET RECOVERY FULL;
GO

-- Step 8: Transaction Log Backup
BACKUP LOG TrainingDB 
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\TrainingDB_Log.trn';
GO

-- Step 9: Copy-Only Backup
BACKUP DATABASE TrainingDB 
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\TrainingDB_CopyOnly.bak' 
WITH COPY_ONLY;
GO

-- Drop DB
DROP DATABASE TrainingDB;

-- 1. Restore FULL backup 
RESTORE DATABASE TrainingDB  
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\TrainingDB_Full.bak' 
WITH NORECOVERY;

-- 2. Restore DIFFERENTIAL backup (if you created one) 
RESTORE DATABASE TrainingDB  
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\TrainingDB_Diff.bak' 
WITH NORECOVERY; 

-- 3. Restore TRANSACTION LOG backup (if you created one) 
RESTORE LOG TrainingDB  
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\TrainingDB_Log.trn' 
WITH RECOVERY; 

RESTORE LOG TrainingDB  
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\TrainingDB_Log.trn' 
WITH NORECOVERY; 

--Step 3: Verify the Restored Data 
USE TrainingDB; 
SELECT * FROM Students; -- All data here with last record add

/*
===============================================
 Reflection Questions — Backup & Restore
===============================================

1️ What would happen if you skipped the differential backup step?
-------------------------------------------------------------------
- If you skip the differential backup, recovery would require:
   → The latest full backup
   → All transaction log backups since that full backup
- This results in:
   → Longer restore times
   → Increased risk of data loss if any log backup is missing
- Differential backups reduce the number of log files needed during recovery.

2️ What’s the difference between restoring a full vs. copy-only backup?
------------------------------------------------------------------------
- Full Backup:
   → Sets the base for differential and log backups.
   → Used in normal backup/restore sequences.
- Copy-Only Backup:
   → Doesn’t impact the backup chain.
   → Used for ad-hoc or manual backups (testing, auditing).
   → Cannot be used as a base for differential backups.

3️ What happens if you use WITH RECOVERY in the middle of a restore chain?
---------------------------------------------------------------------------
- WITH RECOVERY makes the database operational and ends the restore sequence.
- If used before applying all required backups (e.g., logs/differentials), remaining backups CANNOT be restored.
- You should only use WITH RECOVERY in the final restore step.
- Use WITH NORECOVERY for intermediate steps.

4️ Which backup types are optional and which are mandatory for full recovery?
------------------------------------------------------------------------------

| Backup Type         | Required? | Notes                                            |
|---------------------|-----------|--------------------------------------------------|
| Full Backup         | Yes       | Foundation of all restores                       |
| Transaction Log     | Yes       | Enables point-in-time recovery                   |
| Differential Backup | No        | Optional, speeds up restore                      |
| Copy-Only Backup    | No        | Used for special scenarios (audits, testing)     |
| File/Filegroup      | No        | Used for large databases with partitioning       |

 Summary:
- Required for full recovery: Full Backup + Transaction Log Backups
- Optional but helpful: Differential, Copy-Only, File/Filegroup

=================================================
End of Reflection Summary
=================================================
*/

-- ================================
-- PART 3: HOSPITAL SYSTEM BACKUP PLAN
-- ================================

-- SUNDAY FULL BACKUP (Weekly)
BACKUP DATABASE HospitalDB 
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\HospitalDB_Full_20250525.bak';
GO

-- MONDAY TO SATURDAY DIFFERENTIAL BACKUPS (Daily)
BACKUP DATABASE HospitalDB 
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\HospitalDB_Diff_20250526.bak' 
WITH DIFFERENTIAL;
GO

-- HOURLY TRANSACTION LOG BACKUP
BACKUP LOG HospitalDB 
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\HospitalDB_Log_20250526_0800.trn';
GO

-- Repeat the LOG backup command every hour (e.g., via SQL Agent)
-- Change the date/time string in filename for each backup.
