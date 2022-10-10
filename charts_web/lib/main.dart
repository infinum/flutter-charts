import 'package:charts_web/ui/common/respo/respo.dart';
import 'package:charts_web/ui/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'InterTight',
        primarySwatch: Colors.blue,
      ),
      builder: _builder,
      home: HomeScreen(),
    );
  }
}

Widget _builder(BuildContext context, Widget? child) {
  return Respo(child: child ?? const SizedBox.shrink());
}
