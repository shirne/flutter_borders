import 'package:borders/borders.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Borders Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Borders Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int state = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.purple,
                    shape: ChamferBorder(
                      side: const BorderSide(
                        color: Colors.purpleAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      borderChamfer: BorderChamfer.vertical(
                          top: state == 1 ? true : false),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.purple,
                    shape: ChamferBorder(
                      side: const BorderSide(
                        color: Colors.purpleAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(state == 1 ? 16 : 0),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.amber,
                    shape: TrapeziumBorder(
                      side: const BorderSide(
                        color: Colors.amberAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(state == 1 ? 16 : 0),
                      borderOffset: const BorderOffset.vertical(
                        top: Offset(-10, 0),
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.pink,
                    shape: TrapeziumBorder(
                      side: const BorderSide(
                        color: Colors.pinkAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(state == 1 ? 16 : 0),
                      borderOffset: const BorderOffset.diagonal(
                        tlbr: Offset(-10, 0),
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.blue,
                    shape: TrapeziumBorder(
                      side: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                      borderOffset: BorderOffset.vertical(
                        top: state == 1 ? const Offset(-10, 0) : Offset.zero,
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.blue,
                    shape: TrapeziumBorder(
                      side: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                      borderOffset: BorderOffset.diagonal(
                        tlbr: state == 1 ? const Offset(-10, 0) : Offset.zero,
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.amber,
                    shape: TrapeziumBorder(
                      side: const BorderSide(
                        color: Colors.amberAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(state == 1 ? 16 : 0),
                      borderOffset: BorderOffset.vertical(
                        top: state == 1 ? const Offset(-10, 0) : Offset.zero,
                        bottom: state == 1 ? Offset.zero : const Offset(-10, 0),
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.pink,
                    shape: TrapeziumBorder(
                      side: const BorderSide(
                        color: Colors.pinkAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(state == 1 ? 16 : 0),
                      borderOffset: BorderOffset.diagonal(
                        tlbr: state == 1 ? const Offset(-10, 0) : Offset.zero,
                        trbl: state == 1 ? Offset.zero : const Offset(-10, 0),
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            state = state == 1 ? 0 : 1;
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
