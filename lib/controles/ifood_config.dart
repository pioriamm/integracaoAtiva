import 'package:baixa_arquivos/enum/tipo_arquivo.dart';

import 'adquirente_config.dart';
import '../modelos/integracao_prametros.dart';

class IntegracaoConfig implements AdquirenteConfig {
  final IntegracaoPrametros parametros;
  final TipoArquivo tipoDeArquivo;

  IntegracaoConfig({
    required int IdIntegracao,
    required String DataInicial,
    required String DataFinal,
    required List<int> Ids,
    required this.tipoDeArquivo,
  }) : parametros = IntegracaoPrametros(
    IdIntegracao: IdIntegracao,
    dataInicio: DataInicial,
    dataFim: DataFinal,
    Ids: Ids,
  );

  @override
  Map<String, dynamic> toBody() {

    final Map<String, dynamic> body = {
      'IdIntegracao': parametros.IdIntegracao,
      'Ids': parametros.Ids,
      'DataInicial': parametros.dataInicio,
      'DataFinal': parametros.dataFim,
    };

    final chave = parametros.IdIntegracao == 68 ? 'Tipo' : 'step';
    body[chave] = tipoDeArquivo.valor;

    return body;
  }
}
