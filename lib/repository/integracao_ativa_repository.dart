import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../interfaces/Iconfig.dart';

class IntegracaoAtivaRepository {
  final Uri urlPath = Uri.http(
    'job.conciliadora.com.br:5004',
    '/api/Job/IntegracaoAtiva/Adquirente',
  );

  Future<void> enviarRequisicao(IConfig config) async {
    var bodyrequisicao = config;

    final response = await http.post(
      urlPath,
      headers: {'Content-Type': 'application/json'},
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
