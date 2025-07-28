#!/bin/bash

set -e

echo "=== Ubuntu 20.04 / 22.04 ➜ 24.04 OTA 升级脚本 ==="
echo "⚠️ 本脚本适用于 Ubuntu 20.04 LTS 或 Ubuntu 22.04 LTS 系统"
echo "请确保您已完成数据和系统快照备份。"
read -p "是否继续升级？(y/N): " confirm
[[ $confirm != "y" && $confirm != "Y" ]] && echo "已取消。" && exit 1

# Step 1: 检查当前版本
version=$(lsb_release -rs)

if [[ "$version" != "20.04" && "$version" != "22.04" ]]; then
  echo "❌ 当前系统版本为 $version，此脚本仅支持 Ubuntu 20.04 或 22.04"
  exit 1
fi

# 选择源
echo "🌐 请选择镜像源:"
echo "  1) 阿里云（推荐）"
echo "  2) 清华大学"
echo "  3) 中科大"
echo "  4) 腾讯云"
read -p "输入数字选择镜像源 [默认: 1]: " mirror_choice
mirror_choice=${mirror_choice:-1}

case $mirror_choice in
  1) MIRROR="mirrors.aliyun.com" ;;
  2) MIRROR="mirrors.tuna.tsinghua.edu.cn" ;;
  3) MIRROR="mirrors.ustc.edu.cn" ;;
  4) MIRROR="mirrors.cloud.tencent.com" ;;
  *) echo "❌ 输入无效，已取消。" && exit 1 ;;
esac

# Step 2: 更新现有系统
echo "🔄 正在更新现有系统..."
apt update && apt upgrade -y && apt dist-upgrade -y

# Step 3: 安装升级工具
echo "📦 安装升级工具 update-manager-core..."
apt install -y update-manager-core

# Step 4: 设置允许升级到下一个 LTS
echo "⚙️ 配置 do-release-upgrade..."
sed -i 's/^Prompt=.*/Prompt=lts/' /etc/update-manager/release-upgrades

# Step 5: 检查可用升级并提示
echo "🔍 检查升级通道..."
do-release-upgrade -c

read -p "确认是否开始升级到 Ubuntu 24.04？(y/N): " confirm2
[[ $confirm2 != "y" && $confirm2 != "Y" ]] && echo "已取消。" && exit 1

# Step 6: 正式开始升级
echo "🚀 正在升级至 Ubuntu 24.04 LTS（noble）..."
do-release-upgrade -f DistUpgradeViewNonInteractive

# Step 7: 完成提示
echo "✅ 系统升级命令已完成，建议重启系统："
echo "执行命令 reboot"

read -p "是否立即重启？(y/N): " reboot_confirm
if [[ $reboot_confirm == "y" || $reboot_confirm == "Y" ]]; then
  echo "正在重启..."
  reboot
else
  echo "请稍后手动运行 reboot 命令以完成升级。"
fi
