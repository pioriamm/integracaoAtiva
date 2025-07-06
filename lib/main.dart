import 'package:flutter/material.dart';

import 'paginas/adquirente_page.dart';

void main() {
  runApp(const AdquirenteApp());
}

class AdquirenteApp extends StatelessWidget {
  const AdquirenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Integração Adquirentes',
      theme: ThemeData.light(),
      home: const AdquirentePage(),
    );
  }
}