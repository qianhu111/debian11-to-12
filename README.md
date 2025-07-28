# 🚀 Debian / Ubuntu OTA 升级脚本合集

本项目提供两个一键 Shell 脚本，分别用于：

- 将 **Debian 11 (bullseye)** 升级至 **Debian 12 (bookworm)**
- 将 **Ubuntu 20.04 / 22.04** 升级至 **Ubuntu 24.04 (noble)**

脚本支持自动修改系统源、执行完整升级流程、清理旧软件包，并可选自动重启，适合个人或批量部署使用。

---

## 📜 脚本说明

| 文件名 | 适用系统 | 升级目标 |
|--------|----------|-----------|
| `debian11-to-12.sh` | Debian 11 (bullseye) | Debian 12 (bookworm) |
| `ubuntu-upgrade-to-24.sh` | Ubuntu 20.04 / 22.04 | Ubuntu 24.04 (noble) |

每个脚本执行以下步骤：

1. 检查系统版本是否合法
2. 备份并替换官方软件源
3. 执行 `apt update`、`upgrade` 与 `full-upgrade`
4. 自动清理系统残留包（`autoremove`, `clean`）
5. 支持用户选择是否自动重启

---

## ✅ 使用方法

无需下载，直接运行脚本（建议使用 `screen` 或 `tmux` 以防中断）：

### 📦 Debian 11 ➜ Debian 12

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qianhu111/debian11-to-12/main/debian11-to-12.sh)
```

保持会话hold版：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qianhu111/debian11-to-12/main/debian11-to-12-hold.sh)
```
* 一旦启动，会话会被转入 screen 或 tmux 中，断开 SSH 后可用：

```bash
screen -r debian-upgrade
# 或
tmux attach -t debian-upgrade
```

### 📦 Ubuntu 20.04 / 22.04 ➜ Ubuntu 24.04

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qianhu111/debian11-to-12/main/ubuntu-upgrade-to-24.sh)
```

脚本会提示是否确认执行、是否自动重启等操作。

---

## ⚠️ 注意事项
* 升级操作涉及系统底层组件，强烈建议提前做好完整数据备份或快照！

* 升级后可能需要重新配置：

  * 网络（如 ifupdown → Netplan 或 NetworkManager）

  * 防火墙规则（如 iptables/nftables）

  * 虚拟化模块（如 VPS 的 virtio、KVM）

  * 特殊服务（如 Docker、xray/v2ray、BBR 等）

---

## 💡 升级后建议检查

```bash
cat /etc/os-release     # 查看系统发行版本
uname -r                # 查看当前内核版本
```

如遇问题请查看 /var/log/dist-upgrade/ 日志目录（Ubuntu）或 apt 日志（Debian）。

---

## 📄 License
本项目使用 [MIT License](https://chatgpt.com/c/LICENSE)。

---

## 🤝 鸣谢
感谢 [serokvip 的博客文章](https://blog.serokvip.top/debian-ota) 提供思路与参考

---

欢迎提交 Issue 或 PR 进行改进与补充 🎉
