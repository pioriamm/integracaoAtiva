import 'dart:convert';
import 'package:baixa_arquivos/modelos/adquirentes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AdquirenteRepository {


  static Future<List<Adquirentes>> buscarAdquirentes() async {
    final String _baseUrl = dotenv.env['URL_BASE_LOGO'] ?? '';
    final String _key = dotenv.env['AUTH_TOKEN'] ?? '';

    try {
      final uri = Uri.parse(_baseUrl);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': _key,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {

        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> listaDeItens = decodedData['value'];
        return listaDeItens
            .map((item) => Adquirentes.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('Erro ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar adquirentes: $e');
      return [];
    }
  }
}