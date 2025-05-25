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
    final vnoti = ValueNotifier(value);
    MyDialog.popup(
      Container(
        height: 150,
        child: ValueListenableBuilder<double>(
          valueListenable: vnoti,
          builder: (context, value, child) {
            return Column(
              children: [
                Text(
                  '${(value * 100).round() / 100}',
                  style: const TextStyle(fontSize: 32),
                ),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: (v) {
                    vnoti.value = v;
                    onUpdate((v * 100).round() / 100);
                  },
                ),
              ],
            );
          },
        ),
      ),
      elevation: 3,
      barrierColor: Colors.transparent,
    );
  }

  Widget labelRow(String label) {
    return Container(
      width: 50,
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget settingItem(
    String label,
    double value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(4),
        ),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              '$value',
              style: const TextStyle(fontSize: 14, color: Colors.blue),
            ),
            const Icon(Icons.edit, size: 16),
          ],
        ),
      ),
    );
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
                labelRow('原始大小'),
                Expanded(
                  child: settingItem('宽', width, () {
                    popValue(width, 50, 300, (v) {
                      setState(() {
                        width = v;
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('高', height, () {
                    popValue(height, 50, 300, (v) {
                      setState(() {
                        height = v;
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('圆角', topLeftRadius.x, () {
                    popValue(topLeftRadius.x, 0, 100, (v) {
                      setState(() {
                        topLeftRadius = Radius.circular(v);
                        topRightRadius = Radius.circular(v);
                        bottomLeftRadius = Radius.circular(v);
                        bottomRightRadius = Radius.circular(v);
                      });
                    });
                  }),
                ),
              ],
            ),
            Row(
              children: [
                labelRow('左上角'),
                Expanded(
                  child: settingItem('偏移x', topLeft.dx, () {
                    popValue(topLeft.dx, -100, 100, (v) {
                      setState(() {
                        topLeft = Offset(v, topLeft.dy);
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('偏移y', topLeft.dy, () {
                    popValue(topLeft.dy, -100, 100, (v) {
                      setState(() {
                        topLeft = Offset(topLeft.dx, v);
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('圆角', topLeftRadius.x, () {
                    popValue(topLeftRadius.x, 0, 100, (v) {
                      setState(() {
                        topLeftRadius = Radius.circular(v);
                      });
                    });
                  }),
                ),
              ],
            ),
            Row(
              children: [
                labelRow('右上角'),
                Expanded(
                  child: settingItem('偏移x', topRight.dx, () {
                    popValue(topRight.dx, -100, 100, (v) {
                      setState(() {
                        topRight = Offset(v, topRight.dy);
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('偏移y', topRight.dy, () {
                    popValue(topRight.dy, -100, 100, (v) {
                      setState(() {
                        topRight = Offset(topRight.dx, v);
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('圆角', topRightRadius.x, () {
                    popValue(topRightRadius.x, 0, 100, (v) {
                      setState(() {
                        topRightRadius = Radius.circular(v);
                      });
                    });
                  }),
                ),
              ],
            ),
            Row(
              children: [
                labelRow('左下角'),
                Expanded(
                  child: settingItem('偏移x', bottomLeft.dx, () {
                    popValue(bottomLeft.dx, -100, 100, (v) {
                      setState(() {
                        bottomLeft = Offset(v, bottomLeft.dy);
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('偏移y', bottomLeft.dy, () {
                    popValue(bottomLeft.dy, -100, 100, (v) {
                      setState(() {
                        bottomLeft = Offset(bottomLeft.dx, v);
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('圆角', bottomLeftRadius.x, () {
                    popValue(bottomLeftRadius.x, 0, 100, (v) {
                      setState(() {
                        bottomLeftRadius = Radius.circular(v);
                      });
                    });
                  }),
                ),
              ],
            ),
            Row(
              children: [
                labelRow('右下角'),
                Expanded(
                  child: settingItem('偏移x', bottomRight.dx, () {
                    popValue(bottomRight.dx, -100, 100, (v) {
                      setState(() {
                        bottomRight = Offset(v, bottomRight.dy);
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('偏移y', bottomRight.dy, () {
                    popValue(bottomRight.dy, -100, 100, (v) {
                      setState(() {
                        bottomRight = Offset(bottomRight.dx, v);
                      });
                    });
                  }),
                ),
                Expanded(
                  child: settingItem('圆角', bottomRightRadius.x, () {
                    popValue(bottomRightRadius.x, 0, 100, (v) {
                      setState(() {
                        bottomRightRadius = Radius.circular(v);
                      });
                    });
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
