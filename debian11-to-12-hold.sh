#!/bin/bash

set -e

#!/bin/bash
set -e

SESSION_NAME="debian-upgrade"

# 检测是否已在 screen 或 tmux 会话中
if [ -n "$STY" ] || [ -n "$TMUX" ]; then
    echo "✅ 已在 screen 或 tmux 会话中，继续执行脚本..."
    # 继续执行主逻辑
    return 0 2>/dev/null || true
fi

# 检查 screen 和 tmux 是否存在
HAS_SCREEN=$(command -v screen >/dev/null 2>&1 && echo yes || echo no)
HAS_TMUX=$(command -v tmux >/dev/null 2>&1 && echo yes || echo no)

# 如果两者都不存在，提示选择
if [ "$HAS_SCREEN" = "no" ] && [ "$HAS_TMUX" = "no" ]; then
    echo "❌ 未检测到 screen 或 tmux"
    echo "请选择你要安装的会话管理工具："
    echo "1. 安装并使用 screen（推荐）"
    echo "2. 安装并使用 tmux"
    read -rp "请输入选项 [1/2]: " choice
    if [ "$choice" = "1" ]; then
        apt update && apt install -y screen
        echo "✅ 已安装 screen，正在进入会话..."
        screen -S "$SESSION_NAME" -dm bash "$0"
        echo "👉 请使用 'screen -r $SESSION_NAME' 查看进度"
        exit 0
    elif [ "$choice" = "2" ]; then
        apt update && apt install -y tmux
        echo "✅ 已安装 tmux，正在进入会话..."
        tmux new-session -d -s "$SESSION_NAME" "$0"
        echo "👉 请使用 'tmux attach -t $SESSION_NAME' 查看进度"
        exit 0
    else
        echo "⚠️ 输入错误，退出。"
        exit 1
    fi
fi

# 若只存在其中一个，则直接使用
if [ "$HAS_SCREEN" = "yes" ]; then
    echo "💡 检测到 screen，自动进入会话..."
    screen -S "$SESSION_NAME" -dm bash "$0"
    echo "👉 请使用 'screen -r $SESSION_NAME' 查看进度"
    exit 0
elif [ "$HAS_TMUX" = "yes" ]; then
    echo "💡 检测到 tmux，自动进入会话..."
    tmux new-session -d -s "$SESSION_NAME" "$0"
    echo "👉 请使用 'tmux attach -t $SESSION_NAME' 查看进度"
    exit 0
fi

echo "=== Debian 11 -> Debian 12 OTA 升级脚本 ==="
echo "本脚本仅适用于 Debian 11 bullseye 系统！请先备份数据和系统快照！"
read -p "是否继续？(y/N): " confirm
[[ $confirm != "y" && $confirm != "Y" ]] && echo "已取消。" && exit 1

# Step 1: 确认系统版本
if ! grep -q "bullseye" /etc/os-release; then
  echo "错误：此脚本仅适用于 Debian 11 (bullseye) 系统"
  exit 1
fi

# Step 2: 备份现有源列表
echo "备份源列表..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%F-%H%M%S)

# Step 3: 替换为 Debian 12 (bookworm) 源
echo "更新为 Debian 12 bookworm 源..."
cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF

# Step 4: 更新软件包列表
echo "更新软件包列表..."
apt update

# Step 5: 最小升级
echo "执行最小系统升级..."
apt upgrade -y

# Step 6: 完整系统升级
echo "执行完整系统发行版本升级..."
apt full-upgrade -y

# Step 7: 清理旧版本和多余包
echo "清理旧版本软件包..."
apt autoremove -y
apt clean

# Step 8: 检查内核版本
echo "当前内核版本：$(uname -r)"
echo "建议升级后重启系统。"

# Step 9: 提示重启
read -p "是否立即重启？(y/N): " reboot_confirm
if [[ $reboot_confirm == "y" || $reboot_confirm == "Y" ]]; then
  echo "正在重启..."
  reboot
else
  echo "请手动运行 reboot 命令以完成升级。"
fi
