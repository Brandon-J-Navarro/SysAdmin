-- This is for Restoring and Encrypted Database to another server or instance

-- Source
USE master;
GO

SELECT * FROM sys.certificates;

BACKUP CERTIFICATE MyCertificateName
TO FILE = 'C:\Temp\Backups\TransparentDataEncryption_Cert' -- Cert File Name 'TransparentDataEncryption_Cert'
WITH PRIVATE KEY (FILE = 'C:\Temp\Backups\TransparentDataEncryption_CertKey.pvk', -- Private Key File Name 'TransparentDataEncryption_CertKey.pvk'
ENCRYPTION BY PASSWORD = 'SuperStrongPasswordHere');
GO

-- Destination
USE Master;
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SuperStrongPasswordHere';
GO

CREATE CERTIFICATE BackupMyCertificateName
FROM FILE = 'C:\Temp\Backups\TransparentDataEncryption_Cert'
WITH PRIVATE KEY (FILE = 'C:\Temp\Backups\TransparentDataEncryption_CertKey.pvk',
DECRYPTION BY PASSWORD = 'SuperStrongPasswordHere');
GO

-- I RAN INTO "The certificate, asymmetric key, or private key file is not valid or does not exist; or you do not have permissions for it." ERROR
-- How I got around that was set the Destination Instance in SQL Server Configuration Manger change "log on as" to "Local Service", 
-- and give Local Service permissions on the two files Import then change back the "log on as".
-- Then during the Restore in the Files tab on the right side check the "Relocate all file to folders" check box
