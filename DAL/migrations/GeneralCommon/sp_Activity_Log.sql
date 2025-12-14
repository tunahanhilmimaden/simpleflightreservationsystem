CREATE OR ALTER PROCEDURE [GeneralCommon].[sp_Activity_Log]
  @Action NVARCHAR(100),
  @Description NVARCHAR(MAX),
  @Payload NVARCHAR(MAX) = NULL,
  @UserID INT = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @cols TABLE (Name SYSNAME);
  INSERT INTO @cols(Name)
  SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'GeneralCommon' AND TABLE_NAME = 'ActivityLog';

  DECLARE @c NVARCHAR(MAX) = N'';
  DECLARE @v NVARCHAR(MAX) = N'';
  IF EXISTS (SELECT 1 FROM @cols WHERE Name='Action') BEGIN SET @c += N'[Action],'; SET @v += N'@Action,' END
  IF EXISTS (SELECT 1 FROM @cols WHERE Name='Description') BEGIN SET @c += N'[Description],'; SET @v += N'@Description,' END
  IF EXISTS (SELECT 1 FROM @cols WHERE Name='Payload') BEGIN SET @c += N'[Payload],'; SET @v += N'@Payload,' END
  IF EXISTS (SELECT 1 FROM @cols WHERE Name='UserID') BEGIN SET @c += N'[UserID]'; SET @v += N'@UserID' END
  IF EXISTS (SELECT 1 FROM @cols WHERE Name='LogDate') BEGIN SET @c += CASE WHEN LEN(@c)>0 THEN N',' ELSE N'' END + N' [LogDate]'; SET @v += CASE WHEN LEN(@v)>0 THEN N',' ELSE N'' END + N' SYSUTCDATETIME()' END
  IF EXISTS (SELECT 1 FROM @cols WHERE Name='CreatedAt') BEGIN SET @c += N', [CreatedAt]'; SET @v += N', SYSUTCDATETIME()' END
  IF RIGHT(@c,1)=',' SET @c=LEFT(@c,LEN(@c)-1);
  IF RIGHT(@v,1)=',' SET @v=LEFT(@v,LEN(@v)-1);

  DECLARE @sql NVARCHAR(MAX) = N'INSERT INTO GeneralCommon.ActivityLog ('+@c+') VALUES ('+@v+');';
  EXEC sp_executesql @sql,
    N'@Action NVARCHAR(100), @Description NVARCHAR(MAX), @Payload NVARCHAR(MAX), @UserID INT',
    @Action=@Action, @Description=@Description, @Payload=@Payload, @UserID=@UserID;
END
