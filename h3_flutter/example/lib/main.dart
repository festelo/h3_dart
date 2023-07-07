import 'package:flutter/material.dart';
import 'package:h3_flutter/h3_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final h3 = const H3Factory().load();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: "h3_flutter_example",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('180 degrees in radians is ${h3.degsToRads(180)}'),
            Text(
              '${h3.degsToRads(180)}',
              key: const ValueKey('degsToRadsText'),
            ),
          ],
        ),
      ),
    );
  }
}
