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
  INSERT INTO GeneralCommon.Users (FullName, Email, PasswordHash, Phone, RoleID)
  VALUES (@Name, @Email, @Hash, @Phone, @RoleId);
  SELECT SCOPE_IDENTITY() AS UserID, @RoleId AS RoleID;
END
