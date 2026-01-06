import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蓝牙时钟对时工具',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BluetoothClockPage(),
    );
  }
}

class BluetoothManager {
  static const targetServiceUuid = '00000001-0000-1000-8000-00805f9b34fb';
  static const targetCharacteristicUuid = '00000002-0000-1000-8000-00805f9b34fb';

  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  bool _isScanning = false;
  bool _isConnected = false;
  final Function(String, LogType) _logCallback;
  final Function(bool) _connectionStatusCallback;
  final Function(String) _deviceNameCallback;

  BluetoothManager({
    required Function(String, LogType) logCallback,
    required Function(bool) connectionStatusCallback,
    required Function(String) deviceNameCallback,
  })  : _logCallback = logCallback,
        _connectionStatusCallback = connectionStatusCallback,
        _deviceNameCallback = deviceNameCallback;

  Future<bool> requestPermissions() async {
    try {
      _logCallback('正在请求蓝牙和位置权限...', LogType.info);

      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();

      bool allGranted = true;
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          _logCallback('权限被拒绝: ${permission.toString()}', LogType.error);
          allGranted = false;
        }
      });

      if (allGranted) {
        _logCallback('所有权限已授予', LogType.success);
        return true;
      }

      return false;
    } catch (e) {
      _logCallback('请求权限失败: ${e.toString()}', LogType.error);
      return false;
    }
  }

  Future<void> startScan() async {
    if (_isScanning) {
      _logCallback('正在扫描中，请稍候...', LogType.warning);
      return;
    }

    try {
      _isScanning = true;
      _logCallback('开始扫描蓝牙设备...', LogType.info);

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      final subscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.platformName.isNotEmpty) {
            _logCallback('发现设备: ${r.device.platformName}', LogType.info);
          }
        }
      });

      await Future.delayed(const Duration(seconds: 15));
      await FlutterBluePlus.stopScan();
      subscription.cancel();

      _isScanning = false;
      _logCallback('扫描完成，请选择设备', LogType.success);
    } catch (e) {
      _isScanning = false;
      _logCallback('扫描失败: ${e.toString()}', LogType.error);
    }
  }

  Future<void> connectToDevice(String deviceId) async {
    try {
      _logCallback('正在连接设备...', LogType.info);

      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(timeout: const Duration(seconds: 15));

      _device = device;
      _isConnected = true;

      _logCallback('设备已连接: ${device.platformName}', LogType.success);
      _connectionStatusCallback(true);
      _deviceNameCallback(device.platformName);

      await _discoverServices();
    } catch (e) {
      _logCallback('连接失败: ${e.toString()}', LogType.error);
      _connectionStatusCallback(false);
    }
  }

  Future<void> _discoverServices() async {
    if (_device == null) {
      _logCallback('设备未连接', LogType.error);
      return;
    }

    try {
      _logCallback('正在发现服务...', LogType.info);

      final services = await _device!.discoverServices();

      BluetoothService? targetService;
      for (var service in services) {
        // _logCallback('发现服务: ${service.uuid}', LogType.info);

        if (service.uuid.toString().toLowerCase().contains('0001') ||
            service.uuid.toString().toLowerCase().contains('ffe0')) {
          targetService = service;
          _logCallback('找到目标服务: ${service.uuid}', LogType.success);
          break;
        }
      }

      if (targetService == null) {
        _logCallback('未找到目标服务 (0x0001)', LogType.error);
        await disconnect();
        return;
      }

      for (var characteristic in targetService.characteristics) {
        // _logCallback('发现特征值: ${characteristic.uuid}', LogType.info);

        if (characteristic.uuid.toString().toLowerCase().contains('0002') ||
            characteristic.uuid.toString().toLowerCase().contains('ffe1')) {
          if (characteristic.properties.write) {
            _characteristic = characteristic;
            _logCallback('找到目标特征值 (WRITE): ${characteristic.uuid}', LogType.success);
            return;
          }
        }
      }

      if (_characteristic == null) {
        _logCallback('未找到可写的特征值', LogType.error);
        await disconnect();
      }
    } catch (e) {
      _logCallback('发现服务失败: ${e.toString()}', LogType.error);
      await disconnect();
    }
  }

  Future<void> syncTime(int offsetSeconds) async {
    if (!_isConnected || _characteristic == null) {
      _logCallback('设备未连接', LogType.error);
      return;
    }

    try {
      final now = DateTime.now();
      final syncTime = now.add(Duration(seconds: offsetSeconds));

      // _logCallback('准备同步时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(syncTime)} (偏移: ${offsetSeconds}s)', LogType.info);

      final data = _buildTimeData(offsetSeconds);
      // _logCallback('发送数据: ${_formatDataPacket(data)}', LogType.info);

      await _characteristic!.write(data);

      _logCallback('时间同步成功: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(syncTime)}', LogType.success);
    } catch (e) {
      _logCallback('时间同步失败: ${e.toString()}', LogType.error);
    }
  }

  Future<void> restartDevice() async {
    if (!_isConnected || _characteristic == null) {
      _logCallback('设备未连接', LogType.error);
      return;
    }

    try {
      final restartCommand = Uint8List.fromList([0xA6]);
      await _characteristic!.write(restartCommand);
      _logCallback('重启成功', LogType.success);
    } catch (e) {
      _logCallback('重启成功', LogType.success);
    }
    await disconnect();
  }

  Future<void> disconnect() async {
    try {
      if (_device != null) {
        await _device!.disconnect();
      }
      _device = null;
      _characteristic = null;
      _isConnected = false;

      _logCallback('设备已断开连接', LogType.info);
      _connectionStatusCallback(false);
      _deviceNameCallback('--');
    } catch (e) {
      _logCallback('断开连接失败: ${e.toString()}', LogType.error);
    }
  }

  Uint8List _buildTimeData(int offsetSeconds) {
    final now = DateTime.now();
    final syncTime = now.add(Duration(seconds: offsetSeconds));

    return Uint8List.fromList([
      0xA5,
      syncTime.second,
      syncTime.minute,
      syncTime.hour,
      syncTime.day,
      syncTime.month,
      syncTime.year - 2000,
    ]);
  }

  String _formatDataPacket(Uint8List data) {
    return data.map((byte) => byte.toRadixString(16).toUpperCase().padLeft(2, '0')).join(' ');
  }

  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
}

enum LogType { info, success, warning, error }

class BluetoothClockPage extends StatefulWidget {
  const BluetoothClockPage({super.key});

  @override
  State<BluetoothClockPage> createState() => _BluetoothClockPageState();
}

class _BluetoothClockPageState extends State<BluetoothClockPage> {
  late BluetoothManager _bluetoothManager;
  final List<LogEntry> _logs = [];
  final TextEditingController _offsetController = TextEditingController(text: '0');
  final ScrollController _logScrollController = ScrollController();

  bool _isConnected = false;
  String _deviceName = '--';
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _bluetoothManager = BluetoothManager(
      logCallback: _addLog,
      connectionStatusCallback: (connected) {
        setState(() {
          _isConnected = connected;
        });
      },
      deviceNameCallback: (name) {
        setState(() {
          _deviceName = name;
        });
      },
    );
    _addLog('欢迎使用蓝牙时钟对时工具', LogType.info);
    _addLog('请授予蓝牙和位置权限', LogType.info);
  }

  @override
  void dispose() {
    _offsetController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  void _addLog(String message, LogType type) {
    setState(() {
      _logs.add(LogEntry(
        message: message,
        type: type,
        timestamp: DateTime.now(),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _requestPermissions() async {
    final granted = await _bluetoothManager.requestPermissions();
    if (granted) {
      _startScan();
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
    });

    await _bluetoothManager.startScan();

    setState(() {
      _isScanning = false;
    });

    _showDeviceList();
  }

  void _showDeviceList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择设备'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(child: Text('未发现设备'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final result = snapshot.data![index];
                  final deviceName = result.device.platformName.isNotEmpty
                      ? result.device.platformName
                      : '未知设备';

                  return ListTile(
                    title: Text(deviceName),
                    subtitle: Text(result.device.remoteId.toString()),
                    onTap: () {
                      Navigator.pop(context);
                      _connectToDevice(result.device.remoteId.toString());
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice(String deviceId) async {
    await _bluetoothManager.connectToDevice(deviceId);
  }

  void _disconnect() {
    _bluetoothManager.disconnect();
  }

  void _syncTime() {
    final offset = int.tryParse(_offsetController.text) ?? 0;
    if (offset.abs() > 86400) {
      _addLog('偏移值超过1天，请确认是否正确', LogType.warning);
    }
    _bluetoothManager.syncTime(offset);
  }

  void _restartDevice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重启'),
        content: const Text('确定要重启设备吗？重启后设备将断开连接。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _bluetoothManager.restartDevice();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _clearOffset() {
    setState(() {
      _offsetController.text = '0';
    });
    _addLog('时间偏移已清零', LogType.info);
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    _addLog('日志已清空', LogType.info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('蓝牙时钟对时工具'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusSection(),
            const SizedBox(height: 20),
            _buildBluetoothSection(),
            const SizedBox(height: 20),
            _buildTimeSyncSection(),
            const SizedBox(height: 20),
            _buildDeviceControlSection(),
            const SizedBox(height: 20),
            _buildLogSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('当前系统时间', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                  style: const TextStyle(fontSize: 18),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('连接状态', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(_isConnected ? '已连接' : '未连接'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('设备名称', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_deviceName),
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('🔵 蓝牙操作', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _requestPermissions,
              icon: _isScanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isScanning ? '扫描中...' : '扫描设备'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isConnected ? _disconnect : null,
              icon: const Icon(Icons.close),
              label: const Text('断开连接'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSyncSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('⏰ 时间同步设置', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _offsetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '时间偏移（秒）',
                      border: OutlineInputBorder(),
                      helperText: '正数为提前，负数为延后',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _clearOffset,
                  child: const Text('清零'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isConnected ? _syncTime : null,
              icon: const Icon(Icons.sync),
              label: const Text('同步时间'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceControlSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('⚡ 设备控制', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isConnected ? _restartDevice : null,
              icon: const Icon(Icons.refresh),
              label: const Text('重启设备'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text('⚠️ 警告：重启设备将断开连接', style: TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📋 操作日志', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: _clearLogs,
                  child: const Text('清空日志'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                controller: _logScrollController,
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return _buildLogItem(log);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(LogEntry log) {
    Color textColor;
    switch (log.type) {
      case LogType.info:
        textColor = Colors.black;
        break;
      case LogType.success:
        textColor = Colors.green;
        break;
      case LogType.warning:
        textColor = Colors.orange;
        break;
      case LogType.error:
        textColor = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('HH:mm:ss').format(log.timestamp),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              log.message,
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class LogEntry {
  final String message;
  final LogType type;
  final DateTime timestamp;

  LogEntry({
    required this.message,
    required this.type,
    required this.timestamp,
  });
}
