#!/bin/bash

# Script đổi timezone hệ thống sang giờ Việt Nam (UTC+7)

echo "=========================================="
echo "     ĐỔI TIMEZONE SANG GIỜ VIỆT NAM"
echo "=========================================="
echo ""

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "Script này cần chạy với quyền root (sudo)"
    exit 1
fi

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function để in màu
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Hiển thị thông tin timezone hiện tại
echo "=========================================="
echo "         THÔNG TIN HIỆN TẠI"
echo "=========================================="
print_status "Timezone hiện tại:"
timedatectl status
echo ""

# Kiểm tra xem timezone Việt Nam có sẵn không
print_status "Kiểm tra timezone Asia/Ho_Chi_Minh..."
if [ -f "/usr/share/zoneinfo/Asia/Ho_Chi_Minh" ]; then
    print_success "Timezone Asia/Ho_Chi_Minh có sẵn!"
else
    print_error "Timezone Asia/Ho_Chi_Minh không tìm thấy!"
    print_status "Đang cài đặt tzdata..."
    apt update && apt install -y tzdata
    
    if [ $? -eq 0 ]; then
        print_success "tzdata đã được cài đặt!"
    else
        print_error "Lỗi khi cài đặt tzdata!"
        exit 1
    fi
fi

echo ""

# Đổi timezone sang Việt Nam
print_status "Đang đổi timezone sang Asia/Ho_Chi_Minh (UTC+7)..."
timedatectl set-timezone Asia/Ho_Chi_Minh

if [ $? -eq 0 ]; then
    print_success "Đã đổi timezone thành công!"
else
    print_error "Lỗi khi đổi timezone!"
    exit 1
fi

echo ""

# Đồng bộ thời gian với NTP
print_status "Đang bật đồng bộ NTP..."
timedatectl set-ntp true

if [ $? -eq 0 ]; then
    print_success "Đã bật đồng bộ NTP!"
else
    print_warning "Có lỗi khi bật NTP, nhưng timezone đã được đổi!"
fi

echo ""

# Cập nhật hardware clock
print_status "Đang đồng bộ hardware clock..."
hwclock --systohc

if [ $? -eq 0 ]; then
    print_success "Hardware clock đã được đồng bộ!"
else
    print_warning "Có lỗi khi đồng bộ hardware clock!"
fi

echo ""

# Hiển thị thông tin sau khi thay đổi
echo "=========================================="
echo "         THÔNG TIN SAU KHI ĐỔI"
echo "=========================================="
print_success "Timezone đã được đổi thành công!"
echo ""

print_status "Thông tin chi tiết:"
timedatectl status

echo ""
print_status "Thời gian hiện tại:"
date "+%Y-%m-%d %H:%M:%S %Z (UTC%z)"

echo ""

# Kiểm tra múi giờ
CURRENT_TZ=$(timedatectl show --property=Timezone --value)
if [ "$CURRENT_TZ" = "Asia/Ho_Chi_Minh" ]; then
    print_success "✓ Timezone: $CURRENT_TZ"
else
    print_error "✗ Timezone: $CURRENT_TZ (không phải Asia/Ho_Chi_Minh)"
fi

# Kiểm tra UTC offset
UTC_OFFSET=$(date "+%z")
if [ "$UTC_OFFSET" = "+0700" ]; then
    print_success "✓ UTC Offset: $UTC_OFFSET (đúng UTC+7)"
else
    if [ "$UTC_OFFSET" = "+0800" ]; then
        print_warning "⚠ UTC Offset: $UTC_OFFSET (có thể do daylight saving time)"
    else
        print_error "✗ UTC Offset: $UTC_OFFSET (không đúng)"
    fi
fi

# Kiểm tra NTP
NTP_STATUS=$(timedatectl show --property=NTP --value)
if [ "$NTP_STATUS" = "yes" ]; then
    print_success "✓ NTP: Đã bật (thời gian sẽ tự động đồng bộ)"
else
    print_warning "⚠ NTP: Chưa bật (thời gian có thể không chính xác)"
fi

echo ""
echo "=========================================="
echo "              HOÀN THÀNH"
echo "=========================================="
echo ""

print_success "Hệ thống đã được đổi sang giờ Việt Nam!"
print_status "Thời gian hiện tại: $(date '+%A, %d/%m/%Y %H:%M:%S %Z')"
echo ""

print_status "Ghi chú:"
echo "  - Timezone: Asia/Ho_Chi_Minh (UTC+7)"
echo "  - NTP đã được bật để đồng bộ thời gian tự động"
echo "  - Hardware clock đã được cập nhật"
echo "  - Không cần restart hệ thống"
echo ""

print_status "Để kiểm tra lại sau này, sử dụng:"
echo "  timedatectl status"
echo "  date"
echo ""

print_success "Script hoàn thành!"
