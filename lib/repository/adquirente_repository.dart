import 'dart:convert';
import 'package:baixa_arquivos/modelos/adquirentes.dart';
import 'package:http/http.dart' as http;

class AdquirenteRepository {


  static Future<List<Adquirentes>> buscarAdquirentes() async {
    final String _baseUrl = 'https://api.conciliadora.com.br/api/Adquirentes';
    final String _authToken = 'b6f05efd-e899-425b-8933-2f6ac4165b99';

    try {
      final uri = Uri.parse(_baseUrl);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': _authToken,
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