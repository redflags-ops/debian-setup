#!/bin/bash

# Script auto install network tracing tools cho Debian
# Bao gồm: ping, traceroute, dig, telnet, nmap, tcpdump

echo "=========================================="
echo "  AUTO INSTALL NETWORK TRACING TOOLS"
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

# Bước 1: Update package list
print_status "Đang update package list..."
apt update
if [ $? -eq 0 ]; then
    print_success "Package list đã được update thành công!"
else
    print_error "Lỗi khi update package list!"
    exit 1
fi

echo ""

# Bước 2: Upgrade system
print_status "Đang upgrade system (có thể mất vài phút)..."
apt upgrade -y
if [ $? -eq 0 ]; then
    print_success "System đã được upgrade thành công!"
else
    print_warning "Có lỗi trong quá trình upgrade, nhưng tiếp tục cài đặt tools..."
fi

echo ""

# Danh sách các package cần cài đặt
PACKAGES=(
    "iputils-ping"      # ping command
    "traceroute"        # traceroute command  
    "dnsutils"          # dig, nslookup commands
    "telnet"            # telnet command
    "nmap"              # nmap network scanner
    "tcpdump"           # tcpdump packet analyzer
    "net-tools"         # netstat, ifconfig, arp commands
    "curl"              # curl command
    "wget"              # wget command
    "netcat-openbsd"    # nc (netcat) command
)

# Bước 3: Cài đặt từng package
print_status "Bắt đầu cài đặt network tools..."
echo ""

FAILED_PACKAGES=()
SUCCESS_COUNT=0

for package in "${PACKAGES[@]}"; do
    print_status "Đang cài đặt $package..."
    
    # Kiểm tra xem package đã được cài đặt chưa
    if dpkg -l | grep -q "^ii  $package "; then
        print_success "$package đã được cài đặt từ trước!"
        ((SUCCESS_COUNT++))
    else
        # Cài đặt package
        apt install -y "$package"
        
        if [ $? -eq 0 ]; then
            print_success "$package đã được cài đặt thành công!"
            ((SUCCESS_COUNT++))
        else
            print_error "Lỗi khi cài đặt $package!"
            FAILED_PACKAGES+=("$package")
        fi
    fi
    echo ""
done

# Bước 4: Báo cáo kết quả
echo "=========================================="
echo "           KẾT QUẢ CÀI ĐẶT"
echo "=========================================="
echo ""

print_success "Đã cài đặt thành công: $SUCCESS_COUNT/${#PACKAGES[@]} packages"

if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
    print_error "Các package cài đặt thất bại:"
    for failed in "${FAILED_PACKAGES[@]}"; do
        echo "  - $failed"
    done
    echo ""
fi

# Bước 5: Kiểm tra các tools đã cài đặt
echo "=========================================="
echo "        KIỂM TRA TOOLS ĐÃ CÀI ĐẶT"
echo "=========================================="
echo ""

TOOLS=(
    "ping"
    "traceroute" 
    "dig"
    "telnet"
    "nmap"
    "tcpdump"
    "netstat"
    "ifconfig"
    "curl"
    "wget"
    "nc"
)

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        VERSION=$(timeout 2s $tool --version 2>/dev/null | head -n1 || echo "Available")
        print_success "$tool: $VERSION"
    else
        print_error "$tool: Không tìm thấy!"
    fi
done

echo ""
echo "=========================================="
echo "           CÀI ĐẶT HOÀN TẤT"
echo "=========================================="
echo ""

print_success "Tất cả network tracing tools đã được cài đặt!"
echo ""
echo "Bạn có thể sử dụng các lệnh sau để trace network:"
echo "  - ping <host>              : Test connectivity"
echo "  - traceroute <host>        : Trace route to host"  
echo "  - dig <domain>             : DNS lookup"
echo "  - telnet <host> <port>     : Test port connection"
echo "  - nmap <host>              : Network scanning"
echo "  - tcpdump -i <interface>   : Packet capture"
echo "  - netstat -tuln            : Show listening ports"
echo "  - curl -I <url>            : HTTP header check"
echo ""
print_status "Script hoàn thành!"