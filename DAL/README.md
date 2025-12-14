# DAL (Database Abstraction Layer)

## Amaç
- Mevcut veritabanı şemalarını ve tüm stored procedure/function tanımlarını migration dosyaları olarak tutmak.
- Dağıtım için `SqlPackage` veya `sqlcmd` ile çalıştırılabilir.

## Dağıtım
- SqlPackage örneği:
```
SqlPackage /Action:Publish /TargetConnectionString "Server=localhost,1433;Database=AirportServicesDB;User ID=sa;Password=Str0ngPassw0rd!2025;Encrypt=True;TrustServerCertificate=True" /SourceFile:./build.dacpac
```
- sqlcmd örneği:
```
sqlcmd -S localhost,1433 -d AirportServicesDB -U sa -P Str0ngPassw0rd!2025 -i migrations\GeneralCommon\sp_User_Register.sql
```
