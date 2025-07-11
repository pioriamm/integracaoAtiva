import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'paginas/adquirente_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: "appsettings_staging.env");
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