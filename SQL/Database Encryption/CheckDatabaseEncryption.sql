SELECT db.name,
    db.is_encrypted,
    dm.encryption_state,
    dm.percent_complete,
    dm.key_algorithm,
    dm.key_length,
    db.database_id
FROM sys.databases AS db
LEFT OUTER JOIN sys.dm_database_encryption_keys AS dm
ON db.database_id = dm.database_id;
GO
