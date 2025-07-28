#!/bin/bash

set -e

echo "=== Ubuntu 20.04 / 22.04 ➜ 24.04 OTA 升级脚本 ==="
echo "⚠️ 本脚本适用于 Ubuntu 20.04 LTS 或 Ubuntu 22.04 LTS 系统"
echo "请确保您已完成数据和系统快照备份。"
read -p "是否继续升级？(y/N): " confirm
[[ $confirm != "y" && $confirm != "Y" ]] && echo "已取消。" && exit 1

# Step 0: 检查 screen 是否存在，不存在则安装
if ! command -v screen >/dev/null 2>&1; then
  echo "📦 未检测到 screen，正在安装..."
  apt update && apt install -y screen
fi

# Step 1: 检查当前版本
version=$(lsb_release -rs)

if [[ "$version" != "20.04" && "$version" != "22.04" ]]; then
  echo "❌ 当前系统版本为 $version，此脚本仅支持 Ubuntu 20.04 或 22.04"
  exit 1
fi

# Step 2: 提供镜像源选项
echo "🌐 请选择一个国内的 Ubuntu 软件源进行替换："
echo "1) 阿里云 (Aliyun)"
echo "2) 清华大学 (TUNA)"
echo "3) 中科大 (USTC)"
echo "4) 华为云 (Huawei)"
read -p "请输入对应数字（默认1）: " mirror_choice
mirror_choice=${mirror_choice:-1}

case $mirror_choice in
  1)
    mirror_url="https://mirrors.aliyun.com/ubuntu"
    ;;
  2)
    mirror_url="https://mirrors.tuna.tsinghua.edu.cn/ubuntu"
    ;;
  3)
    mirror_url="https://mirrors.ustc.edu.cn/ubuntu"
    ;;
  4)
    mirror_url="https://mirrors.huaweicloud.com/repository/ubuntu"
    ;;
  *)
    echo "❌ 无效选择，已取消。"
    exit 1
    ;;
esac

echo "🔧 正在备份并替换软件源为: $mirror_url"
cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%s)
sed -i "s|http://.*.ubuntu.com|$mirror_url|g" /etc/apt/sources.list
sed -i "s|http://security.ubuntu.com|$mirror_url|g" /etc/apt/sources.list

# Step 3: 更新现有系统
echo "🔄 正在更新现有系统..."
apt update && apt upgrade -y && apt dist-upgrade -y

# Step 4: 安装升级工具
echo "📦 安装升级工具 update-manager-core..."
apt install -y update-manager-core

# Step 5: 设置允许升级到下一个 LTS
echo "⚙️ 配置 do-release-upgrade..."
sed -i 's/^Prompt=.*/Prompt=lts/' /etc/update-manager/release-upgrades

# Step 6: 检查可用升级
echo "🔍 检查升级通道..."
do-release-upgrade -c

# Step 7: 提示是否继续升级
read -p "确认是否开始升级到 Ubuntu 24.04？(y/N): " confirm2
[[ $confirm2 != "y" && $confirm2 != "Y" ]] && echo "已取消。" && exit 1

# Step 8: 使用 screen 开始升级
echo "💡 即将进入 screen 会话，若中断可用 'screen -r ubuntu-upgrade' 恢复会话"
sleep 3
screen -S ubuntu-upgrade bash -c "do-release-upgrade -f DistUpgradeViewNonInteractive; echo '✅ 升级完成！可运行 reboot 重启'; exec bash"
