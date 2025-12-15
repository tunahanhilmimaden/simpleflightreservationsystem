CREATE OR ALTER PROCEDURE [GeneralCommon].[sp_User_Register]
  @Name NVARCHAR(100),
  @Email NVARCHAR(200),
  @Password NVARCHAR(200),
  @Phone NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (SELECT 1 FROM GeneralCommon.Users WHERE Email = @Email)
  BEGIN
    RAISERROR('Email already exists', 16, 1);
    RETURN;
  END
  DECLARE @RoleId INT;
  SELECT @RoleId = RoleID FROM GeneralCommon.Roles WHERE RoleName = N'customer';
  IF @RoleId IS NULL
  BEGIN
    INSERT INTO GeneralCommon.Roles(RoleName) VALUES (N'customer');
    SELECT @RoleId = SCOPE_IDENTITY();
  END
  DECLARE @Hash VARBINARY(16) = HASHBYTES('MD5', CONVERT(VARBINARY(4000), @Password));
  DECLARE @HashHex NVARCHAR(32) = LOWER(SUBSTRING(master.dbo.fn_varbintohexstr(@Hash), 3, 32));
  DECLARE @hasPasswordHash BIT = CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='GeneralCommon' AND TABLE_NAME='Users' AND COLUMN_NAME='PasswordHash') THEN 1 ELSE 0 END;
  DECLARE @hasPassword BIT = CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='GeneralCommon' AND TABLE_NAME='Users' AND COLUMN_NAME='Password') THEN 1 ELSE 0 END;
  DECLARE @hasPhone BIT = CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='GeneralCommon' AND TABLE_NAME='Users' AND COLUMN_NAME='Phone') THEN 1 ELSE 0 END;
  DECLARE @hasRoleId BIT = CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='GeneralCommon' AND TABLE_NAME='Users' AND COLUMN_NAME='RoleID') THEN 1 ELSE 0 END;
  DECLARE @c NVARCHAR(MAX) = N'[FullName],[Email]';
  DECLARE @v NVARCHAR(MAX) = N'@Name,@Email';
  IF @hasPasswordHash = 1 BEGIN SET @c += N',[PasswordHash]'; SET @v += N',@Hash' END
  ELSE IF @hasPassword = 1 BEGIN SET @c += N',[Password]'; SET @v += N',@HashHex' END
  IF @hasPhone = 1 BEGIN SET @c += N',[Phone]'; SET @v += N',@Phone' END
  IF @hasRoleId = 1 BEGIN SET @c += N',[RoleID]'; SET @v += N',@RoleId' END
  DECLARE @sql NVARCHAR(MAX) = N'INSERT INTO GeneralCommon.Users ('+@c+') VALUES ('+@v+');';
  EXEC sp_executesql @sql,
    N'@Name NVARCHAR(100), @Email NVARCHAR(200), @Hash VARBINARY(16), @HashHex NVARCHAR(32), @Phone NVARCHAR(20), @RoleId INT',
    @Name=@Name, @Email=@Email, @Hash=@Hash, @HashHex=@HashHex, @Phone=@Phone, @RoleId=@RoleId;
  SELECT SCOPE_IDENTITY() AS UserID, @RoleId AS RoleID;
END
