# Fix Railway MySQL Connection Error

## Lỗi Thường Gặp
```
2002 - Can't connect to server on 'mysql.railway.internal' (10060)
```

## Nguyên Nhân
- `mysql.railway.internal` chỉ dùng được **bên trong Railway network**
- Cần dùng **Public hostname** để connect từ bên ngoài

## Cách Fix - Lấy Đúng Connection Info

### Bước 1: Vào Railway Dashboard
1. Truy cập [railway.app](https://railway.app)
2. Chọn project có MySQL service
3. Click vào **MySQL service**

### Bước 2: Lấy Public Connection Info
Trong MySQL service, tìm **Connect** tab hoặc **Variables** tab:

#### ✅ SỬ DỤNG CÁC THÔNG TIN NÀY:
```bash
# Public connection info (dùng để connect từ ngoài)
MYSQL_PUBLIC_URL=mysql://root:password@containers-us-west-123.railway.app:6543/railway

# Hoặc từng thông tin riêng lẻ:
HOST=containers-us-west-123.railway.app  # ← Quan trọng!
PORT=6543
USER=root
PASSWORD=your-actual-password
DATABASE=railway
```

#### ❌ KHÔNG DÙNG:
```bash
# Internal connection (chỉ dùng trong Railway network)
MYSQL_PRIVATE_URL=mysql://root:password@mysql.railway.internal:3306/railway
HOST=mysql.railway.internal  # ← KHÔNG dùng từ bên ngoài
```

### Bước 3: Test Connection
```bash
# Test với thông tin đúng
mysql -h containers-us-west-123.railway.app -P 6543 -u root -p

# Nếu không có MySQL client, test bằng telnet
telnet containers-us-west-123.railway.app 6543
```

## Cấu Hình Render Environment Variables

Với thông tin Railway đúng, set trong Render:

```bash
# Environment Variables trong Render
DB_HOST=containers-us-west-123.railway.app  # Public hostname
DB_PORT=6543                                 # Public port  
DB_NAME=railway                             # Hoặc database bạn tạo
DB_USERNAME=root
DB_PASSWORD=your-actual-railway-password    # Từ Railway dashboard
```

## Cách Tìm Thông Tin Connection Chính Xác

### Phương Pháp 1: Variables Tab
1. Railway Dashboard → MySQL Service
2. **Variables** tab
3. Copy `MYSQL_PUBLIC_URL` hoặc từng variable riêng lẻ

### Phương Pháp 2: Connect Tab  
1. Railway Dashboard → MySQL Service
2. **Connect** tab
3. Chọn **External** (không phải Internal)
4. Copy connection string

### Phương Pháp 3: Settings Tab
1. Railway Dashboard → MySQL Service  
2. **Settings** → **Public Networking**
3. Xem public domain và port

## MySQL Workbench Connection

Với thông tin đúng:
```
Connection Name: Railway OneShop
Hostname: containers-us-west-123.railway.app  # Public hostname
Port: 6543                                     # Public port
Username: root
Password: [your-railway-password]
```

## Troubleshooting

### Vẫn không connect được?

1. **Kiểm tra Railway Service Status**
   - Đảm bảo MySQL service đang "Running"
   - Không bị "Sleeping" hoặc "Crashed"

2. **Verify Networking**
   - Railway MySQL phải có "Public Networking" enabled
   - Check trong Settings → Public Networking

3. **Test từ Command Line**
   ```bash
   # Test port có mở không
   nc -zv containers-us-west-123.railway.app 6543
   
   # Hoặc với PowerShell (Windows)
   Test-NetConnection -ComputerName containers-us-west-123.railway.app -Port 6543
   ```

4. **Check Firewall**
   - Firewall local có block port 6543 không
   - Một số mạng công ty block các port không standard

## Import Data Sau Khi Connect Thành Công

```bash
# Khi đã connect được, import data:
mysql -h containers-us-west-123.railway.app -P 6543 -u root -p railway < DB_MySQL.sql

# Hoặc tạo database mới trước:
mysql -h containers-us-west-123.railway.app -P 6543 -u root -p -e "CREATE DATABASE oneshop_db;"
mysql -h containers-us-west-123.railway.app -P 6543 -u root -p oneshop_db < DB_MySQL.sql
```

## Lưu Ý Quan Trọng

⚠️ **Railway có thể thay đổi hostname và port** khi service restart
- Luôn check lại connection info trong Railway dashboard
- Cập nhật environment variables trong Render khi cần

💡 **Production Tips:**
- Sử dụng Railway environment variables thay vì hardcode
- Setup monitoring cho database connection
- Backup database định kỳ
