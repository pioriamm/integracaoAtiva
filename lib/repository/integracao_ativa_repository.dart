import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../controles/adquirente_config.dart';

class IntegracaoAtivaRepository {

  final String url = 'job.conciliadora.com.br:5004/api/Job/IntegracaoAtiva/Adquirente';

  Future<void> enviarRequisicao(AdquirenteConfig config) async {

    var bodyrequisicao = config;

    final uri = Uri(
      scheme: 'http',
      host: 'job.conciliadora.com.br',
      port: 5004,
      path: 'api/Job/IntegracaoAtiva/Adquirente',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyrequisicao.toBody()),
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
