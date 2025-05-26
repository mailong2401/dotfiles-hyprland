#!/bin/bash

# Màu sắc
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Tiêu đề
echo -e "${BLUE}==== Thông tin dung lượng ổ đĩa ====${NC}"
echo -e "${YELLOW}Filesystem         Size  Used  Avail Use% Mounted on${NC}"
df -h --output=source,size,used,avail,pcent | grep "^/dev" | awk '{printf "%-17s %-5s %-5s %-5s %-5s\n", $1, $2, $3, $4, $5}'
echo ""

# Tiêu đề
echo -e "${BLUE}==== Dung lượng từng thư mục chính ====${NC}"
echo -e "${YELLOW}Dung lượng   Thư mục${NC}"
du -sh /* 2>/dev/null | sort -hr | head -n 10 | awk '{printf "%-10s %-20s\n", $1, $2}'
echo ""

# Hoàn tất
echo -e "${GREEN}✓ Kiểm tra hoàn tất.${NC}"
