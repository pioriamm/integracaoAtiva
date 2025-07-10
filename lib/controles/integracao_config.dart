import 'package:baixa_arquivos/enum/tipo_arquivo.dart';

import '../interfaces/Iconfig.dart';
import '../modelos/integracao_prametros.dart';

class IntegracaoConfig implements IConfig {
  final IntegracaoPrametros parametros;
  final TipoArquivo tipoDeArquivo;

  IntegracaoConfig({
    required int IdIntegracao,
    required String DataInicial,
    required String DataFinal,
    required List<int> ListaRefosPRs,
    required this.tipoDeArquivo,
  }) : parametros = IntegracaoPrametros(
         IdIntegracao: IdIntegracao,
         dataInicio: DataInicial,
         dataFim: DataFinal,
         listaRefosPrs: ListaRefosPRs,
       );

  @override
  Map<String, dynamic> gerarPayload() {
    final Map<String, dynamic> body = {
      'IdIntegracao': parametros.IdIntegracao,
      'Ids': parametros.listaRefosPrs,
      'DataInicial': parametros.dataInicio,
      'DataFinal': parametros.dataFim,
    };

    final chave = parametros.IdIntegracao == 68 ? 'Tipo' : 'step';
    body[chave] = tipoDeArquivo.valor;

    return body;
  }
}
