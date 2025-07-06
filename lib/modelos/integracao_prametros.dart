
import 'package:baixa_arquivos/enum/tipo_arquivo.dart';

class IntegracaoPrametros {
  final int IdIntegracao;
  final List<int> Ids;
  final String dataInicio;
  final String dataFim;
  final TipoArquivo? tipoDeArquivo;

  IntegracaoPrametros({
    required this.IdIntegracao,
    required this.Ids,
    required this.dataInicio,
    required this.dataFim,
    this.tipoDeArquivo = TipoArquivo.venda
  });
}
