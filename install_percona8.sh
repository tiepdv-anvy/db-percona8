#!/bin/bash
#
# install_percona8.sh
# Tự động cài đặt Percona Server 8.0 trên Ubuntu 18.04
# Chạy với quyền root hoặc qua sudo:
#   sudo bash install_percona8.sh

set -euo pipefail

echo "--------------------------------------------------"
echo "Bắt đầu cài đặt Percona Server 8.0"
echo "Ubuntu `lsb_release -ds`"
echo "--------------------------------------------------"

# 1) Cập nhật hệ thống
echo "[Step 1] Cập nhật APT repositories..."
apt update -y
apt upgrade -y

# 2) Cài dependencies cần thiết
echo "[Step 2] Cài gnupg2, curl, lsb-release..."
apt install -y gnupg2 curl lsb-release

# 3) Tải và cài percona-release
echo "[Step 3] Tải percona-release package..."
PERCONA_PKG="percona-release_latest.generic_all.deb"
curl -fsSL -o "/tmp/${PERCONA_PKG}" \
    "https://repo.percona.com/apt/${PERCONA_PKG}"

echo "[Step 4] Cài percona-release..."
dpkg -i "/tmp/${PERCONA_PKG}"

# 4) Refresh APT và enable repo
echo "[Step 5] Refresh repository list..."
apt update -y

echo "[Step 6] Thiết lập Percona Server 8.0 repository..."
percona-release setup ps80 -y

# 5) Cài Percona Server
echo "[Step 7] Cài đặt Percona Server 8.0..."
apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y percona-server-server

# 6) Kiểm tra service
echo "[Step 8] Kích hoạt & kiểm tra MySQL service..."
systemctl enable mysql
systemctl start mysql

systemctl status mysql --no-pager

# 7) Secure installation
echo "[Step 9] Thiết lập bảo mật cơ bản..."
MYSQL_ROOT_PASSWORD="ChangeMe123!"
echo "Đặt password root (mặc định): ${MYSQL_ROOT_PASSWORD}"

# Chạy secure installation không tương tác
# Tự động remove anonymous, disallow remote root, remove test db
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF

echo "--------------------------------------------------"
echo "Cài đặt hoàn tất!"
echo "Root MySQL password: ${MYSQL_ROOT_PASSWORD}"
echo "Bạn có thể đăng nhập bằng:"
echo "  mysql -u root -p"
echo "--------------------------------------------------"
