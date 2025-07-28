#!/bin/bash

set -e

echo "=== 🛠 Ubuntu 20.04 / 22.04 ➜ 24.04 OTA 升级脚本（增强版） ==="
echo "⚠️ 本脚本仅适用于 Ubuntu 20.04 或 22.04，请确保已备份数据！"

read -p "是否继续升级？(y/N): " confirm
[[ $confirm != "y" && $confirm != "Y" ]] && echo "❌ 已取消。" && exit 1

# 检查版本
version=$(lsb_release -rs)
if [[ "$version" != "20.04" && "$version" != "22.04" ]]; then
  echo "❌ 当前系统版本为 $version，本脚本仅支持 Ubuntu 20.04 或 22.04"
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

echo "🔁 正在备份原始源文件..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak

echo "✍️ 正在替换源为 $MIRROR ..."
sed -i "s|http://.*.ubuntu.com|https://$MIRROR|g" /etc/apt/sources.list
sed -i "s|http://security.ubuntu.com|https://$MIRROR|g" /etc/apt/sources.list

# 安装 screen
echo "🧰 安装 screen 保持 SSH 会话不中断..."
apt update && apt install -y screen

echo "💡 即将进入 screen 会话，若中断可用 'screen -r ubuntu-upgrade' 恢复会话"
sleep 2
screen -S ubuntu-upgrade bash -c '
  echo "🔄 更新系统..."
  apt update && apt upgrade -y && apt dist-upgrade -y

  echo "📦 安装 upgrade-manager..."
  apt install -y update-manager-core

  echo "⚙️ 设置 release-upgrades 为 lts"
  sed -i "s/^Prompt=.*/Prompt=lts/" /etc/update-manager/release-upgrades

  echo "🔍 检查升级通道..."
  do-release-upgrade -c

  read -p "确认是否开始升级到 Ubuntu 24.04？(y/N): " confirm2
  if [[ $confirm2 != "y" && $confirm2 != "Y" ]]; then
    echo "❌ 升级已取消。"
    exit 1
  fi

  echo "🚀 开始升级 Ubuntu 24.04（noble）..."
  do-release-upgrade -f DistUpgradeViewNonInteractive

  echo "✅ 升级命令完成。建议执行 reboot 重启系统。"
  read -p "是否立即重启？(y/N): " reboot_confirm
  if [[ $reboot_confirm == "y" || $reboot_confirm == "Y" ]]; then
    reboot
  else
    echo "请稍后手动运行 reboot 命令。"
  fi
'

