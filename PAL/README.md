# SkyRes Pro (Next.js)

## Çalıştırma
- `cd PAL`
- `npm install`
- `npm run dev`
- `http://localhost:3000` adresine gidin.

## Özellikler
- Giriş/Kayıt
- Uçuş arama ve listeleme
- Koltuk seçimi (First/Business/Economy)
- Otopark seçimi ve kapıda ödeme
- Ödeme formu ve biniş kartı
 - MSSQL bağlantı sağlığı (`/api/health`)

## Yapı
- `app/` sayfalar ve layout
- `lib/` veri ve durum yönetimi
- `components/` UI bileşenleri

## Veritabanı Bağlantısı (MSSQL)
- `.env.local` dosyası oluşturun (`.env.example` örneğini kullanın):
```
DB_SERVER=localhost
DB_PORT=1433
DB_DATABASE=AirportServicesDB
DB_USER=sa
DB_PASSWORD=Str0ngPassw0rd!2025
DB_ENCRYPT=true
DB_TRUST_SERVER_CERTIFICATE=true
```
- Alternatif olarak tek bir bağlantı dizesi kullanabilirsiniz:
```
DB_CONN_STR="Server=localhost,1433;Database=AirportServicesDB;User ID=sa;Password=Str0ngPassw0rd!2025;Encrypt=True;TrustServerCertificate=True"
```
- Sunucuyu başlatın ve `http://localhost:3000/api/health` adresini açarak bağlantıyı test edin.
