CREATE OR ALTER PROCEDURE [GeneralCommon].[sp_User_Login]
  @Email NVARCHAR(200),
  @Password NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Hash VARBINARY(16) = HASHBYTES('MD5', CONVERT(VARBINARY(4000), @Password));
  DECLARE @HashHex NVARCHAR(32) = LOWER(SUBSTRING(master.dbo.fn_varbintohexstr(@Hash), 3, 32));
  DECLARE @hasPasswordHash BIT = CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='GeneralCommon' AND TABLE_NAME='Users' AND COLUMN_NAME='PasswordHash') THEN 1 ELSE 0 END;
  DECLARE @hasPassword BIT = CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='GeneralCommon' AND TABLE_NAME='Users' AND COLUMN_NAME='Password') THEN 1 ELSE 0 END;
  DECLARE @sql NVARCHAR(MAX) = N'SELECT @cntOut = COUNT(*) FROM GeneralCommon.Users WHERE Email = @Email';
  IF @hasPasswordHash = 1 SET @sql += N' AND PasswordHash = @Hash';
  IF @hasPassword = 1 SET @sql += N' OR (Email = @Email AND (Password = @Password OR Password = @HashHex))';
  DECLARE @cnt INT;
  EXEC sp_executesql @sql,
    N'@Email NVARCHAR(200), @Password NVARCHAR(200), @Hash VARBINARY(16), @HashHex NVARCHAR(32), @cntOut INT OUTPUT',
    @Email=@Email, @Password=@Password, @Hash=@Hash, @HashHex=@HashHex, @cntOut=@cnt OUTPUT;
  IF @cnt = 0
  BEGIN
    RAISERROR('Invalid credentials', 16, 1);
    RETURN;
  END
  SELECT UserID AS userId, FullName AS Name, Email, Phone, RoleID
  FROM GeneralCommon.Users WHERE Email = @Email;
END
