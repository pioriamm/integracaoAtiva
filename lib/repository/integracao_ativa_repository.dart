import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../interfaces/Iconfig.dart';

class IntegracaoAtivaRepository {


  Future<void> enviarRequisicao(IConfig config) async {
    var bodyrequisicao = config;

    final response = await http.post(
      Uri.parse(dotenv.env['URL_BASE_INTEGRACAO']!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['AUTH_TOKEN']}',
      },
      body: jsonEncode(bodyrequisicao.gerarPayload()),
    );


    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Sucesso: ${response.body}');
      }
    } else {
      if (kDebugMode) {
        print('Erro: ${response.statusCode} => ${response.body}');
      }
    }
  }
}
