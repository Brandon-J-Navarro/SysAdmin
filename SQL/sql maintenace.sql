-- Weekly or Monthly
EXECUTE [dbo].[IndexOptimize]
@Database = 'USER_DATABASES',
@FragmentationMedium = 'INDEX_REORGANIZE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REORGANIZE',
@FragmentationLevel1 = 50,
@FragmentationLevel2 = 80,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y',
@PageCountLevel = 5000,
@LogToTable = 'Y'

-- Nightly
EXECUTE [dbo].[IndexOptimize]
@Database = 'USER_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = NULL,
@FragmentationHigh = NULL,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y',
@LogToTable = 'Y'


EXECUTE [dbo].[DatabaseBackup]
@Databases = '',
@Directory = '',
@BackupType = 'FULL',
@Compress = 'Y',
@CheckSum = 'Y',
@NumberOfFiles = 4,
@MinBackupSizeForMultipleFiles = 10240 --MB
