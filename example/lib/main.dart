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
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
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
                        borderRadius:
                            BorderRadius.circular(state == 1 ? 16 : 0),
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
                        borderRadius:
                            BorderRadius.circular(state == 1 ? 16 : 0),
                        borderOffset: BorderOffset.vertical(
                          top: state == 1 ? const Offset(-10, 0) : Offset.zero,
                          bottom:
                              state == 1 ? Offset.zero : const Offset(-10, 0),
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
                      color: Colors.amber,
                      shape: TrapeziumBorder(
                        side: const BorderSide(
                          color: Colors.amberAccent,
                          width: 2,
                        ),
                        borderRadius:
                            BorderRadius.circular(state == 1 ? 16 : 0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 100,
                    height: 20,
                    decoration: ShapeDecoration(
                      color: Colors.amber,
                      shape: TrapeziumBorder(
                        side: const BorderSide(
                          color: Colors.amberAccent,
                          width: 2,
                        ),
                        borderRadius:
                            BorderRadius.circular(state == 1 ? 16 : 0),
                        borderOffset: BorderOffset.vertical(
                          top: state == 1 ? const Offset(-10, 0) : Offset.zero,
                          bottom:
                              state == 1 ? Offset.zero : const Offset(-10, 0),
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
                    height: 20,
                    decoration: ShapeDecoration(
                      color: Colors.amber,
                      shape: TrapeziumBorder(
                        side: const BorderSide(
                          color: Colors.amberAccent,
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      color: Colors.pink,
                      shape: StampBorder.count(
                        side: const BorderSide(
                          color: Colors.pinkAccent,
                          width: 2,
                        ),
                        minGearCount: 5,
                        perforations: BorderPerforation(
                          inner: state == 1 ? true : false,
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
                  const SizedBox(width: 32),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      color: Colors.pink,
                      shape: StampBorder(
                        side: const BorderSide(
                          color: Colors.pinkAccent,
                          width: 2,
                        ),
                        gearRadius: const Radius.circular(8),
                        perforations: BorderPerforation.horizontal(
                          inner: state == 1 ? true : false,
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
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: GradientBorder.all(
                        width: 4,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD197), Color(0xFFBE7226)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      color: Colors.grey,
                      shape: GradientShapeBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(width: 4),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD197), Color(0xFFBE7226)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
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
                      color: Colors.indigo,
                      shape: DashedBorder.all(
                        color: Colors.indigoAccent[100]!,
                        width: 2,
                        dashStyle:
                            state == 1 ? BorderDash.dashed : BorderDash.dotted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Container with ShapeDecoration'),
                  ),
                  const SizedBox(width: 32),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      color: Colors.indigo,
                      shape: DashedBorder.all(
                        color: Colors.indigoAccent[100]!,
                        width: 4,
                        dashStyle:
                            state == 1 ? BorderDash.dotted : BorderDash.morse,
                        shape: BoxShape.circle,
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Container with ShapeDecoration'),
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
                      color: Colors.indigo,
                      shape: DashedBorder(
                        top: StyledBorderSide(
                          color: Colors.indigoAccent[100]!,
                          width: state == 1 ? 5 : 1,
                          dashStyle: state == 1
                              ? BorderDash.dashed
                              : BorderDash.dotted,
                        ),
                        left: StyledBorderSide(
                          color: Colors.indigoAccent[100]!,
                          width: state == 1 ? 5 : 1,
                          dashStyle: state == 1
                              ? BorderDash.dashed
                              : BorderDash.dotted,
                        ),
                        right: StyledBorderSide(
                          color: Colors.indigoAccent[100]!,
                          width: state == 1 ? 1 : 5,
                          strokeAlign: 1,
                          dashStyle: state == 1
                              ? BorderDash.dashed
                              : BorderDash.dotted,
                        ),
                        bottom: StyledBorderSide.none,
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('ShapeDecoration with different borders'),
                  ),
                  const SizedBox(width: 32),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      color: Colors.indigo,
                      shape: DashedBorder.all(
                        color: Colors.indigoAccent[100]!,
                        width: 4,
                        dashStyle:
                            state == 1 ? BorderDash.dotted : BorderDash.morse,
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Container with ShapeDecoration'),
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
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      border: DashedBoxBorder.all(
                        color: Colors.blueAccent[100]!,
                        width: 4,
                        dashStyle: BorderDash.dashed,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Container with BoxDecoration'),
                  ),
                  const SizedBox(width: 32),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      border: DashedBoxBorder.all(
                        color: Colors.blueAccent[100]!,
                        width: 4,
                        dashStyle: BorderDash.morse,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Container with BoxDecoration'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
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
