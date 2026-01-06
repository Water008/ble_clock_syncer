# 快速入门指南

## 环境准备

### 1. 安装 Flutter SDK

下载并安装Flutter：https://flutter.dev/docs/get-started/install

验证安装：

```bash
flutter doctor
```

### 2. 配置 Android Studio

1. 安装 Android Studio
2. 安装 Android SDK 和模拟器
3. 配置 Android SDK 路径（在 `android/local.properties` 中）

## 构建和运行

### 1. 进入项目目录

```bash
cd ble_clock_syncer
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 连接设备或启动模拟器

**连接真实设备：**

```bash
# 启用USB调试（在手机开发者选项中）
# 连接USB线
flutter devices
```

**启动模拟器：**

```bash
flutter emulators
flutter emulators --launch <emulator_id>
```

### 4. 运行应用

```bash
# Debug模式（推荐用于开发）
flutter run

# Release模式（推荐用于发布）
flutter run --release
```

## 打包 APK

### Debug APK（用于测试）

```bash
flutter build apk --debug
```

生成的文件：`build/app/outputs/flutter-apk/app-debug.apk`

### Release APK（用于发布）

```bash
flutter build apk --release
```

生成的文件：`build/app/outputs/flutter-apk/app-release.apk`

### App Bundle（用于Google Play发布）

```bash
flutter build appbundle --release
```

生成的文件：`build/app/outputs/bundle/release/app-release.aab`

## 常见问题

### Q: flutter doctor 报错？

A: 根据提示安装缺少的工具：
- Android SDK
- Android Studio
- Flutter 插件
- Dart 插件

### Q: 设备不显示？

A:
1. 确认USB调试已开启
2. 确认授权了电脑的USB调试权限
3. 尝试更换USB线或USB接口
4. 运行 `flutter devices` 检查

### Q: 依赖安装失败？

A:
1. 检查网络连接
2. 尝试使用代理：`export PUB_HOSTED_URL=https://pub.flutter-io.cn`
3. 运行 `flutter clean` 后重试

### Q: 蓝牙功能无法使用？

A:
1. 确保使用真实设备（模拟器不支持蓝牙）
2. 确保设备已开启蓝牙
3. 确保已授予应用所有权限
4. 查看应用内日志了解详细信息

## 代码结构

```
lib/
└── main.dart          # 所有代码在一个文件中
    - BluetoothManager # 蓝牙管理器类
    - BluetoothClockPage  # 主界面组件
    - LogEntry         # 日志条目模型

android/
└── app/
    └── src/main/
        ├── AndroidManifest.xml  # 权限配置
        └── kotlin/      # 原生代码（仅MainActivity）
```

## 自定义修改

### 修改服务UUID

在 `lib/main.dart` 中修改：

```dart
class BluetoothManager {
  static const targetServiceUuid = '你的服务UUID';
  static const targetCharacteristicUuid = '你的特征UUID';
  ...
}
```

### 修改应用名称

1. 编辑 `android/app/src/main/res/values/strings.xml`
2. 修改 `<string name="app_name">你的应用名称</string>`

### 修改应用包名

1. 编辑 `android/app/build.gradle`
2. 修改 `applicationId "你的包名"`
3. 重命名包目录结构

### 修改应用图标

1. 准备图标文件（PNG格式）
2. 替换 `android/app/src/main/res/mipmap-*` 目录下的图标文件
3. 或使用 Android Studio 的 Image Asset 工具生成图标

## 发布到 Google Play

1. 配置签名密钥
2. 构建 App Bundle
3. 上传到 Google Play Console
4. 填写应用信息
5. 发布

详细步骤参考：https://flutter.dev/docs/deployment/android

## 技术支持

遇到问题？

1. 查看 `README.md` 了解详细说明
2. 查看 `README.md` 的"常见问题"部分
3. 检查应用内的日志显示
4. 运行 `flutter doctor -v` 检查环境
