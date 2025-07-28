#!/bin/bash

set -e

ORIGINAL_SOURCE=$(cat /etc/apt/sources.list)

echo "=== Ubuntu 20.04 / 22.04 ➜ 24.04 OTA 升级脚本 ==="
echo "⚠️ 请确保您已备份数据和系统快照"

read -p "是否继续升级？(y/N): " confirm
[[ $confirm != "y" && $confirm != "Y" ]] && echo "❌ 已取消" && exit 1

# 检查当前系统版本
version=$(lsb_release -rs)
if [[ "$version" != "20.04" && "$version" != "22.04" ]]; then
  echo "❌ 当前系统版本为 $version，本脚本仅支持 Ubuntu 20.04 或 22.04"
  exit 1
fi

# 选择镜像源
echo "请选择一个新的 Ubuntu 镜像源："
echo "1) 阿里云"
echo "2) 清华大学"
echo "3) 中科大"
read -p "请输入序号 [默认:1]: " source_id
source_id=${source_id:-1}

case $source_id in
  1)
    new_source="https://mirrors.aliyun.com"
    ;;
  2)
    new_source="https://mirrors.tuna.tsinghua.edu.cn"
    ;;
  3)
    new_source="https://mirrors.ustc.edu.cn"
    ;;
  *)
    echo "❌ 输入无效，退出"
    exit 1
    ;;
esac

echo "✅ 使用镜像源：$new_source"
sed -i.bak "s|http://.*.ubuntu.com|$new_source|g" /etc/apt/sources.list || {
  echo "❌ 替换源失败，退出"
  exit 1
}

# 更新系统
echo "🔄 正在更新系统..."
if ! apt update && apt upgrade -y && apt dist-upgrade -y; then
  echo "❌ 系统更新失败，恢复原始源..."
  echo "$ORIGINAL_SOURCE" > /etc/apt/sources.list
  exit 1
fi

# 安装升级工具
echo "📦 安装 update-manager-core..."
apt install -y update-manager-core

# 修改升级设置
echo "⚙️ 设置升级通道为 LTS..."
sed -i 's/^Prompt=.*/Prompt=lts/' /etc/update-manager/release-upgrades

# 检查是否可升级
echo "🔍 检查是否可升级到 24.04..."
do-release-upgrade -c

read -p "是否开始升级到 Ubuntu 24.04？(y/N): " confirm2
[[ $confirm2 != "y" && $confirm2 != "Y" ]] && echo "❌ 已取消" && exit 1

echo "🚀 正在升级至 Ubuntu 24.04 LTS（noble）..."
if ! do-release-upgrade -f DistUpgradeViewNonInteractive; then
  echo "❌ 升级过程中失败，建议手动检查"
  exit 1
fi

echo "✅ 升级完成，建议立即重启系统"
read -p "是否立即重启？(y/N): " reboot_confirm
if [[ $reboot_confirm == "y" || $reboot_confirm == "Y" ]]; then
  reboot
else
  echo "您可以稍后使用 reboot 命令手动重启系统"
fi
