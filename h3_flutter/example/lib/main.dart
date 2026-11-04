import 'package:flutter/material.dart';
import 'package:h3_flutter/h3_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final h3 = await const H3Factory().loadAsync();
  runApp(MyApp(h3: h3));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.h3});

  final H3 h3;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  H3 get h3 => widget.h3;

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
