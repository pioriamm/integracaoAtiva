import 'package:baixa_arquivos/helps/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'helps/util.dart';
import 'paginas/adquirente_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: "appsettings_staging.env");
  runApp(const AdquirenteApp());
}

class AdquirenteApp extends StatelessWidget {
  const AdquirenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Roboto", "Mukta");
    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Integração Adquirentes',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: const AdquirentePage(),
    );
  }
}
