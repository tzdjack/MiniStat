# MiniStat

macOS 极简的菜单栏系统监视器

<img width="86" height="36" alt="image" src="https://github.com/user-attachments/assets/36f0ac81-2a04-4cdb-a27e-52a6508a2afb" />

<img width="376" height="721" alt="image" src="https://github.com/user-attachments/assets/1b13d0d7-558d-47f3-9b05-4d3581933ba3" />

## 功能特性

### 系统监控
- **CPU**: 使用率、温度、核心数、频率
- **内存**: 使用率、详细内存信息(Active/Wired/Compressed)、Swap 使用情况
- **GPU**: 使用率、温度、GPU 型号、显示器刷新率
- **网络**: 实时网速(上传/下载)、多接口支持(Wi-Fi/以太网/VPN)、本地 IP/公网 IP
- **磁盘**: 使用情况、SSD 健康度
- **电池**: 电量百分比、充电状态、剩余时间、功耗
- **风扇**: 转速监控
- **系统**: 运行时间、进程数、内核版本、屏幕亮度

### 界面特性
- 精美的卡片式 UI 设计
- 明暗主题切换
- 实时历史趋势图表
- 点击卡片可快速打开相关系统应用
- 支持 Intel 和 Apple Silicon 芯片

### 多语言支持
- 中文
- English
- Türkçe (土耳其语)
- Deutsch (德语)
- Français (法语)
- Español (西班牙语)
- 日本語 (日语)

## 系统要求

- macOS 12.0 或更高版本
- 支持 Intel 和 Apple Silicon Mac

## 安装方法

### 方法一：直接下载
从 [Releases](https://github.com/lirongjie/MiniStat/releases) 页面下载最新版本

### 方法二：编译安装
```bash
swiftc -O -o MiniStat MiniStat.swift -framework Cocoa -framework IOKit -framework Metal
```

### 方法三：使用 Xcode
打开 `MiniStat.xcodeproj` 项目文件并编译运行

## 使用方法

1. 启动应用后，MiniStat 会出现在菜单栏
2. 点击菜单栏图标展开监控面板
3. 点击各卡片可打开对应的系统应用
4. 点击设置按钮可切换语言和主题

## 技术栈

- **语言**: Swift
- **框架**: Cocoa, IOKit, Metal
- **架构**: 原生 macOS App，无第三方依赖

## License

MIT License - 详见 [LICENSE](LICENSE) 文件

## 致谢

## 致谢

LiteStat 极简版：https://github.com/tzdjack/LiteStat

---

**提示**：如需极简功能，请使用 [LiteStat 极简版](https://github.com/tzdjack/LiteStat)。
