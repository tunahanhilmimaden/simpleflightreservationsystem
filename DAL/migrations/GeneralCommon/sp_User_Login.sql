CREATE OR ALTER PROCEDURE [GeneralCommon].[sp_User_Login]
  @Email NVARCHAR(200),
  @Password NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Hash VARBINARY(16) = HASHBYTES('MD5', CONVERT(VARBINARY(4000), @Password));
  IF NOT EXISTS (SELECT 1 FROM GeneralCommon.Users WHERE Email = @Email AND PasswordHash = @Hash)
  BEGIN
    RAISERROR('Invalid credentials', 16, 1);
    RETURN;
  END
  SELECT UserID AS userId, FullName AS Name, Email, Phone, RoleID
  FROM GeneralCommon.Users WHERE Email = @Email;
END
