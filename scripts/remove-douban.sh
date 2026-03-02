#!/bin/bash
# 子代理任务脚本 - 删除豆瓣链接

set -e

REPO_DIR="/root/.openclaw/workspace/90s-anime"

# 1. 确保本地仓库存在
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "克隆仓库..."
    git clone git@github.com:Dandy233/90s-anime.git "$REPO_DIR"
fi

cd "$REPO_DIR"

# 2. 更新代码
echo "更新代码..."
git stash
git pull
git stash pop 2>/dev/null || true

# 3. 修改 README.md - 删除豆瓣链接
echo "修改 README.md..."
sed -i 's/ \[\[豆瓣\]([^)]*)\]//g' README.md
sed -i 's/\[\[豆瓣\]\]//g' README.md

# 4. 修改 index.html - 删除豆瓣链接相关代码
echo "修改 index.html..."
# 删除豆瓣链接的 HTML
sed -i '/doubanLink/d' index.html
sed -i '/豆瓣/d' index.html

# 5. 提交并推送
echo "提交..."
git add README.md index.html
git commit -m "remove: 删除豆瓣链接，只保留百科" || echo "无变更"
git push origin main

echo "完成！"
