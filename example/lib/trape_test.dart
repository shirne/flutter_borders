import 'package:borders/borders.dart';
import 'package:flutter/material.dart';

class TrapeTestPage extends StatefulWidget {
  const TrapeTestPage({super.key});

  @override
  State<TrapeTestPage> createState() => _TrapeTestPageState();
}

class _TrapeTestPageState extends State<TrapeTestPage> {
  double width = 100;
  double height = 100;

  Offset topLeft = Offset.zero;
  Offset topRight = Offset.zero;
  Offset bottomRight = Offset.zero;
  Offset bottomLeft = Offset.zero;

  Radius topLeftRadius = Radius.zero;
  Radius topRightRadius = Radius.zero;
  Radius bottomRightRadius = Radius.zero;
  Radius bottomLeftRadius = Radius.zero;

  final changed = ValueNotifier(0);

  void update(VoidCallback callback) {
    callback();
    changed.value = changed.value + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trapezium Test')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ValueListenableBuilder(
                    valueListenable: changed,
                    builder: (context, value, child) {
                      return AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: width,
                        height: height,
                        decoration: ShapeDecoration(
                          color: Colors.amber,
                          shape: TrapeziumBorder(
                            side: const BorderSide(
                              color: Colors.amberAccent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: topLeftRadius,
                              topRight: topRightRadius,
                              bottomRight: bottomRightRadius,
                              bottomLeft: bottomLeftRadius,
                            ),
                            borderOffset: BorderOffset(
                              topLeft: topLeft,
                              topRight: topRight,
                              bottomRight: bottomRight,
                              bottomLeft: bottomLeft,
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
                      );
                    }),
              ),
            ),
            Row(
              children: [
                const Text('原始大小'),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '$width'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        width = double.tryParse(value) ?? 100;
                      });
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Text('宽'),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '$height'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        height = double.tryParse(value) ?? 100;
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('高')),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('左上角'),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '${topLeft.dx}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        topLeft =
                            Offset(double.tryParse(value) ?? 0, topLeft.dy);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('偏移x')),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '${topLeft.dy}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        topLeft =
                            Offset(topLeft.dx, double.tryParse(value) ?? 0);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('偏移y')),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: '${topLeftRadius.x}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        topLeftRadius =
                            Radius.circular(double.tryParse(value) ?? 0);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('圆角')),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('右上角'),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '${topRight.dx}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        topRight =
                            Offset(double.tryParse(value) ?? 0, topRight.dy);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('偏移x')),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '${topRight.dy}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        topRight =
                            Offset(topRight.dx, double.tryParse(value) ?? 0);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('偏移y')),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: '${topRightRadius.x}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        topRightRadius =
                            Radius.circular(double.tryParse(value) ?? 0);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('圆角')),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('左下角'),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '${bottomLeft.dx}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        bottomLeft =
                            Offset(double.tryParse(value) ?? 0, bottomLeft.dy);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('偏移x')),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '${bottomLeft.dy}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        bottomLeft =
                            Offset(bottomLeft.dx, double.tryParse(value) ?? 0);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('偏移y')),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: '${bottomLeftRadius.x}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        bottomLeftRadius =
                            Radius.circular(double.tryParse(value) ?? 0);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('圆角')),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('右下角'),
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: '${bottomRight.dx}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        bottomRight =
                            Offset(double.tryParse(value) ?? 0, bottomRight.dy);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('偏移x')),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: '${bottomRight.dy}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        bottomRight =
                            Offset(bottomRight.dx, double.tryParse(value) ?? 0);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('偏移y')),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: '${bottomRightRadius.x}'),
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      update(() {
                        bottomRightRadius =
                            Radius.circular(double.tryParse(value) ?? 0);
                      });
                    },
                    decoration: const InputDecoration(prefixIcon: Text('圆角')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
