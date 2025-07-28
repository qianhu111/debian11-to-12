#!/bin/bash

set -e

# === 保持升级过程不中断：使用 screen 或 tmux ===
if [[ -z "$INSIDE_SESSION" ]]; then
  echo "💡 即将进入持久会话 (screen/tmux)，升级过程中可安全断开 SSH"
  export INSIDE_SESSION=1

  # 优先使用 screen
  if ! command -v screen >/dev/null 2>&1; then
    echo "📦 未检测到 screen，尝试安装中..."
    apt update && apt install -y screen || true
  fi

  if command -v screen >/dev/null 2>&1; then
    echo "➡️ 使用 screen 启动会话：debian-upgrade"
    exec screen -S debian-upgrade bash "$0"
    exit
  fi

  # 退而求其次使用 tmux
  if ! command -v tmux >/dev/null 2>&1; then
    echo "📦 未检测到 tmux，尝试安装中..."
    apt update && apt install -y tmux || true
  fi

  if command -v tmux >/dev/null 2>&1; then
    echo "➡️ 使用 tmux 启动会话：debian-upgrade"
    exec tmux new-session -s debian-upgrade "$0"
    exit
  fi

  echo "❌ 无法安装 screen 或 tmux，请手动安装后重试。"
  exit 1
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
