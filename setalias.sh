#!/bin/bash

# 1. Các phím tắt cơ bản
git config --global alias.fscpush "push origin fsc-claude"
git config --global alias.lg "log --graph --oneline --decorate --all"
git config --global alias.back "reset --soft"
git config --global alias.snap "reset --hard"

# 1.1 Các phím tắt Update & Sync (Mới)
# Cập nhật từ chính nhánh đang đứng
git config --global alias.up "!git pull origin $(git branch --show-current)"
# Đồng bộ từ main vào nhánh hiện tại
git config --global alias.sync "pull origin main"

# 1.2. Xem thay đổi SAU KHI PULL/SYNC (Mới)
# Xem danh sách các commit vừa được kéo về
git config --global alias.what "log ORIG_HEAD..HEAD --oneline --graph --decorate"
# Xem danh sách các file đã bị thay đổi
git config --global alias.what-files "diff --stat ORIG_HEAD..HEAD"
# Xem chi tiết từng dòng code thay đổi
git config --global alias.what-diff "diff ORIG_HEAD..HEAD"

# 2. Liệt kê các điểm đánh dấu (Marks)
git config --global alias.marks "tag --sort=-creatordate --format='%(creatordate:short) %(refname:short) - %(contents:subject)' --list 'mark_*'"

# 3. Siêu Alias CM: Kiểm tra bảo mật + Commit + Tag + Push
# Sử dụng dấu nháy đơn bao ngoài để tránh Shell máy khách can thiệp vào các biến nội bộ
git config --global alias.cm '!f() { \
    echo "🔍 Đang kiểm tra bảo mật..."; \
    if git status --porcelain | grep -Ei "^\s*(A|M).*\.env" > /dev/null; then \
        echo "❌ LỖI: Phát hiện file .env đang nằm trong vùng commit!"; \
        return 1; \
    fi; \
    if git diff --cached | grep -Ei "api_key|secret|password|token" | grep "^+ " > /dev/null; then \
        echo "⚠️ CẢNH BÁO: Phát hiện từ khóa nhạy cảm trong code mới."; \
        read -p "Bạn có chắc chắn muốn tiếp tục? (y/n): " confirm; \
        if [ "$confirm" != "y" ]; then echo "Đã hủy commit."; return 1; fi; \
    fi; \
    msg="${1:-update}"; \
    tag_name="mark_$(date +%Y%m%d_%H%M%S)"; \
    git add . && \
    git commit -m "$msg" && \
    git tag -a "$tag_name" -m "$msg" && \
    git push origin fsc-claude && \
    git push origin "$tag_name" && \
    echo "\n✅ Đã lưu an toàn: $msg"; \
    echo "📍 Point: $tag_name"; \
}; f'

# 4. Alias RB: Rollback thông minh (Sửa lỗi sed bằng cách bọc tham số sạch sẽ)
git config --global alias.rb '!f() { \
    idx=${1:-1}; \
    target=$(git tag --sort=-creatordate --list "mark_*" | sed -n "${idx}p"); \
    if [ -z "$target" ]; then \
        echo "Không tìm thấy điểm đánh dấu số $idx!"; \
    else \
        echo "Trở về điểm: $target..."; \
        git reset --hard "$target"; \
    fi; \
}; f'

echo "✅ Đã thiết lập xong các Git Alias cho fsc-workspace!"
echo "Sử dụng: git cm 'tin nhắn' để lưu hoặc git rb [số] để quay lại."
