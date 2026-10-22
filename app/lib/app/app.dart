import 'package:flutter/material.dart';

import 'flavor.dart';

class KhataApp extends StatelessWidget {
  const KhataApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Khata',
      debugShowCheckedModeBanner: config.flavor == Flavor.prod ? false : true,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: Scaffold(
        appBar: AppBar(title: const Text('Vehicle Khata')),
        body: Center(child: Text('Flavor: ${config.name}')),
      ),
    );
  }
}
