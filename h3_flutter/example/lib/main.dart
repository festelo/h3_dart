import 'package:flutter/widgets.dart';
import 'package:h3_flutter/h3_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final h3 = await const H3Factory().loadAsync();
  runApp(MyApp(h3: h3));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.h3});

  final H3 h3;

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      restorationScopeId: 'h3_flutter_example',
      color: const Color(0xFF2196F3),
      builder: (context, child) => DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 16,
          decoration: TextDecoration.none,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Plugin example app'),
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
