# 🚀 Debian OTA 升级脚本：Debian 11 ➜ Debian 12

本项目提供一个用于将 **Debian 11 (bullseye)** 系统一键升级到 **Debian 12 (bookworm)** 的 Shell 脚本，支持自动修改源、升级系统并清理旧包，适合自用或批量部署。

---

## 📜 脚本说明

**文件名：** `debian11-to-12.sh`

该脚本执行以下操作：

1. 检查当前系统是否为 Debian 11
2. 备份当前 `sources.list`
3. 替换为 Debian 12 官方源（含安全更新、固件）
4. 执行 `apt update`、`apt upgrade` 和 `apt full-upgrade`
5. 自动清理系统残留包
6. 支持自动重启（可选）

---

## ✅ 使用方法

1. 下载脚本：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qianhu111/debian11-to-12/main/debian11-to-12.sh)
```

2. 根据提示确认是否执行升级与重启。

## ⚠️ 注意事项
* 本脚本 仅适用于 Debian 11 (bullseye)，请勿在其他版本上使用。

* 升级操作涉及系统底层组件，请提前做好完整备份或快照。

* 升级后可能需要重新配置：

  * 网络（如 ifupdown → NetworkManager）

  * 防火墙/iptables

  * 特殊内核模块（如 VPS 的 virtio、KVM 等）

* 如使用了 Docker、xray/v2ray、BBR 等第三方工具，请确保它们兼容 Debian 12。

## 💡 建议
升级完成后，可执行以下命令确认版本：
```bash
cat /etc/os-release
uname -r
```

## 📄 License
MIT License

## 🤝 鸣谢
* serokvip 的博客文章 提供了原始思路

