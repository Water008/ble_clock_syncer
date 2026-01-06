# 蓝牙时钟对时工具 - Android版

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen?logo=github)](../../actions)

基于Flutter开发的Android应用，用于通过蓝牙连接并同步时钟设备的时间。

## 📱 下载APK

### 最新版本
查看 [Releases](../../releases) 页面下载最新版本的APK文件。

### 开发版本
从 [Actions](../../actions) 页面的"Artifacts"部分下载最新的构建版本。

## 功能特性

- ✅ 蓝牙设备扫描和连接
- ✅ 实时时间显示
- ✅ 可配置的时间偏移（支持正负值）
- ✅ 快捷偏移设置（-60s, -30s, -10s, 0s, +10s, +30s, +50s, +60s）
- ✅ 设备重启功能
- ✅ 详细的操作日志
- ✅ Material Design 3风格界面
- ✅ 权限自动请求

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **蓝牙库**: flutter_blue_plus 1.31.4
- **权限管理**: permission_handler 11.1.0
- **UI设计**: Material Design 3

## 环境要求

- **Flutter SDK**: 3.0.0 或更高版本
- **Android SDK**: 21 (Android 5.0 Lollipop) 或更高版本
- **编译SDK**: 34 (Android 14)
- **开发工具**: Android Studio / VS Code

## 安装步骤

### 1. 克隆项目

```bash
git clone <repository-url>
cd ble_clock_syncer
```

### 2. 获取依赖

```bash
flutter pub get
```

### 3. 运行应用

连接Android设备或启动模拟器：

```bash
flutter run
```

### 4. 打包APK

发布版本：

```bash
flutter build apk --release
```

调试版本：

```bash
flutter build apk --debug
```

## 项目结构

```
ble_clock_syncer/
├── lib/
│   └── main.dart              # 主应用文件
├── android/
│   ├── app/
│   │   ├── build.gradle       # 应用级Gradle配置
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml  # 权限配置
│   │           └── kotlin/     # Kotlin代码
│   ├── build.gradle           # 项目级Gradle配置
│   └── settings.gradle        # Gradle设置
├── pubspec.yaml              # 项目依赖配置
└── README.md                 # 本文件
```

## 核心类说明

### BluetoothManager

蓝牙管理器类，负责所有蓝牙操作：

- `requestPermissions()`: 请求蓝牙和位置权限
- `startScan()`: 开始扫描BLE设备
- `connectToDevice(deviceId)`: 连接到指定设备
- `syncTime(offsetSeconds)`: 同步时间到设备
- `restartDevice()`: 重启设备
- `disconnect()`: 断开设备连接

### BluetoothClockPage

主界面组件，包含：

- 状态显示卡片（时间、连接状态、设备名称）
- 蓝牙操作按钮（扫描、断开）
- 时间同步设置（偏移量、快捷按钮）
- 设备控制（重启）
- 操作日志显示

## 使用方法

### 1. 启动应用并授予权限

首次启动时，应用会自动请求以下权限：
- 蓝牙扫描权限
- 蓝牙连接权限
- 精确位置权限（用于BLE扫描）

### 2. 扫描并连接设备

1. 点击"扫描设备"按钮
2. 等待扫描完成（约15秒）
3. 从设备列表中选择目标设备
4. 等待连接成功

### 3. 同步时间

#### 基本同步（无偏移）

1. 确保时间偏移为 0
2. 点击"同步时间"按钮
3. 查看日志确认同步成功

#### 自定义偏移同步

1. 在"时间偏移"输入框中输入秒数
   - 正数：时间提前（如50表示同步当前时间+50秒）
   - 负数：时间延后（如-30表示同步当前时间-30秒）
2. 点击"同步时间"按钮

#### 快捷偏移

点击快捷按钮快速设置常用偏移值：
- `-60s`, `-30s`, `-10s`: 时间延后
- `0s`: 无偏移
- `+10s`, `+30s`, `+50s`, `+60s`: 时间提前

### 4. 重启设备

1. 确保设备已连接
2. 点击"重启设备"按钮
3. 在确认对话框中点击"确定"
4. 设备将重启并断开连接

### 5. 断开连接

点击"断开连接"按钮即可断开与设备的蓝牙连接。

## 技术参数

### BLE服务UUID

- 目标服务UUID: `00000001-0000-1000-8000-00805f9b34fb` (0x0001)
- 支持的短UUID: `ffe0`

### BLE特征UUID

- 目标特征UUID: `00000002-0000-1000-8000-00805f9b34fb` (0x0002)
- 支持的短UUID: `ffe1`
- 必须属性: WRITE

### 数据格式

#### 时间同步命令

| 字节 | 值 | 说明 |
|------|-----|------|
| 0 | 0xA5 | 起始标记（固定） |
| 1 | 0-59 | 秒 |
| 2 | 0-59 | 分 |
| 3 | 0-23 | 时 |
| 4 | 1-31 | 日 |
| 5 | 1-12 | 月 |
| 6 | 年-2000 | 年份偏移（如2025年=0x19） |

示例数据包：`A5 19 1E 0E 06 01 19` （表示 2025-01-06 14:30:25）

#### 重启命令

| 字节 | 值 | 说明 |
|------|-----|------|
| 0 | 0xA6 | 重启命令（固定） |

## 权限说明

应用需要以下Android权限：

| 权限 | 用途 | 必需 |
|------|------|------|
| `BLUETOOTH` | 基本蓝牙功能 | 是 |
| `BLUETOOTH_ADMIN` | 蓝牙管理 | 是 |
| `BLUETOOTH_SCAN` | BLE设备扫描 | 是 |
| `BLUETOOTH_CONNECT` | BLE设备连接 | 是 |
| `BLUETOOTH_ADVERTISE` | BLE广播 | 是 |
| `ACCESS_FINE_LOCATION` | BLE扫描需要位置信息 | 是 |
| `ACCESS_COARSE_LOCATION` | 粗略位置信息 | 是 |

**注意**: Android 6.0+ 需要在运行时动态请求权限。

## 常见问题

### Q: 为什么找不到设备？

A: 请确保：
1. 设备已开启蓝牙
2. 设备正在广播服务（工具支持UUID: 0x0001, ffe0等）
3. 设备在蓝牙范围内
4. 已授予应用所有必要的权限
5. 位置服务已开启（BLE扫描需要）

### Q: 为什么连接失败？

A: 可能的原因：
1. 设备已被其他应用连接
2. 设备信号弱或距离太远
3. 权限未授予
4. 设备不支持BLE（低功耗蓝牙）

### Q: 为什么时间同步不成功？

A:
1. 检查设备是否正常连接
2. 查看日志中的错误信息
3. 确认设备服务UUID和特征UUID是否正确
4. 尝试重新连接设备

### Q: 权限被拒绝怎么办？

A:
1. 进入手机设置 → 应用 → 蓝牙时钟对时工具
2. 授予所有必要的权限
3. 重新启动应用

## 开发说明

### 修改服务UUID

在 `lib/main.dart` 中的 `BluetoothManager` 类中修改：

```dart
static const targetServiceUuid = '00000001-0000-1000-8000-00805f9b34fb';
static const targetCharacteristicUuid = '00000002-0000-1000-8000-00805f9b34fb';
```

### 修改数据格式

在 `BluetoothManager` 类的 `_buildTimeData()` 方法中修改数据包构建逻辑。

### 自定义样式

修改 `lib/main.dart` 中的 Widget 构建方法，使用Flutter的Material Design组件。

## 故障排查

### 检查蓝牙权限

进入手机设置 → 应用 → 权限 → 位置，确认权限已授予。

### 查看详细日志

应用内的"操作日志"区域会显示所有操作的详细信息，包括错误信息。

### 清除应用数据

进入手机设置 → 应用 → 蓝牙时钟对时工具 → 存储 → 清除数据。

## 版本历史

- **v1.0.0** - 初始版本
  - 基本的蓝牙连接功能
  - 时间同步功能
  - 设备重启功能
  - 可配置的时间偏移
  - 操作日志记录
  - Material Design 3 UI

## 许可证

本项目基于 [MIT License](LICENSE) 开源。

## 致谢

感谢使用蓝牙时钟对时工具！

## GitHub Actions

本项目使用GitHub Actions自动构建APK文件。

### 自动构建

当您推送代码到以下分支时，会自动触发构建：
- `main` / `master`
- `develop`

### 下载构建产物

1. 进入 [Actions](../../actions) 页面
2. 选择最新的构建
3. 滚动到页面底部的"Artifacts"部分
4. 下载：
   - `app-debug` - 调试版本APK
   - `app-release` - 发布版本APK

### 创建Release

创建GitHub Release时，会自动附加APK文件到Release页面。

## 相关链接

- [Flutter官方文档](https://flutter.dev/docs)
- [flutter_blue_plus文档](https://pub.dev/packages/flutter_blue_plus)
- [permission_handler文档](https://pub.dev/packages/permission_handler)
