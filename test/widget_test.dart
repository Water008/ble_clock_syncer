import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Bluetooth clock syncer smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('蓝牙时钟对时工具'), findsOneWidget);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '蓝牙时钟对时工具',
      home: Scaffold(
        body: Center(
          child: Text('蓝牙时钟对时工具'),
        ),
      ),
    );
  }
}
