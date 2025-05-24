import 'package:borders/borders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

const preserveList = {
  '梯形(横)': [Offset(-20, 0), Offset(-20, 0), Offset.zero, Offset.zero],
  '梯形(竖)': [Offset(0, -20), Offset.zero, Offset.zero, Offset(0, -20)],
  '平行四边形': [Offset(-20, 0), Offset.zero, Offset(-20, 0), Offset.zero],
  '不规则四边形': [Offset(20, 20), Offset.zero, Offset(20, 20), Offset.zero],
};

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

  void popValue(
    double value,
    double min,
    double max,
    Function(double) onUpdate,
  ) {
    MyDialog.popup(Container(
      child: Column(
        children: [
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) {
              onUpdate(v);
            },
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trapezium Test'),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return CupertinoActionSheet(
                    actions: [
                      for (var entry in preserveList.entries)
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.of(context).pop(entry.value);
                          },
                          child: Text(entry.key),
                        ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              );
              if (result != null) {
                update(() {
                  topLeft = result[0];
                  topRight = result[1];
                  bottomRight = result[2];
                  bottomLeft = result[3];
                });
              }
            },
            child: const Text('预设'),
          ),
        ],
      ),
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
                  child: GestureDetector(
                    onTap: () {
                      popValue(width, 50, 300, (v) {
                        setState(() {
                          width = v;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('宽'),
                        Text('$width'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(height, 50, 300, (v) {
                        setState(() {
                          height = v;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('高'),
                        Text('$height'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(topLeftRadius.x, 50, 300, (v) {
                        setState(() {
                          topLeftRadius = Radius.circular(v);
                          topRightRadius = Radius.circular(v);
                          bottomLeftRadius = Radius.circular(v);
                          bottomRightRadius = Radius.circular(v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('圆角'),
                        Text('${topLeftRadius.x}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('左上角'),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(topLeft.dx, 0, 100, (v) {
                        setState(() {
                          topLeft = Offset(v, topLeft.dy);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('偏移x'),
                        Text('${topLeft.dx}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(topLeft.dy, 0, 100, (v) {
                        setState(() {
                          topLeft = Offset(topLeft.dx, v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('偏移y'),
                        Text('${topLeft.dy}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(topLeftRadius.x, 0, 100, (v) {
                        setState(() {
                          topLeftRadius = Radius.circular(v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('圆角'),
                        Text('${topLeftRadius.x}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('右上角'),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(topRight.dx, 0, 100, (v) {
                        setState(() {
                          topRight = Offset(v, topRight.dy);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('偏移x'),
                        Text('${topRight.dx}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(topRight.dy, 0, 100, (v) {
                        setState(() {
                          topRight = Offset(topRight.dx, v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('偏移y'),
                        Text('${topRight.dy}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(topRightRadius.x, 0, 100, (v) {
                        setState(() {
                          topRightRadius = Radius.circular(v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('圆角'),
                        Text('${topRightRadius.x}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('左下角'),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(bottomLeft.dx, 0, 100, (v) {
                        setState(() {
                          bottomLeft = Offset(v, bottomLeft.dy);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('偏移x'),
                        Text('${bottomLeft.dx}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(bottomLeft.dy, 0, 100, (v) {
                        setState(() {
                          bottomLeft = Offset(bottomLeft.dx, v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('偏移y'),
                        Text('${bottomLeft.dy}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(bottomLeftRadius.x, 0, 100, (v) {
                        setState(() {
                          bottomLeftRadius = Radius.circular(v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('圆角'),
                        Text('${bottomLeftRadius.x}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('右下角'),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(bottomRight.dx, 0, 100, (v) {
                        setState(() {
                          bottomRight = Offset(v, bottomRight.dy);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('偏移x'),
                        Text('${bottomRight.dx}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(bottomRight.dy, 0, 100, (v) {
                        setState(() {
                          bottomRight = Offset(bottomRight.dx, v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('偏移y'),
                        Text('${bottomRight.dy}'),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      popValue(bottomRightRadius.x, 0, 100, (v) {
                        setState(() {
                          bottomRightRadius = Radius.circular(v);
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Text('圆角'),
                        Text('${bottomRightRadius.x}'),
                        const Icon(Icons.edit),
                      ],
                    ),
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
