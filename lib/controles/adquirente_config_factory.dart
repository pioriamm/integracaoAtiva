import 'package:baixa_arquivos/enum/tipo_adquirente.dart';
import 'package:baixa_arquivos/enum/tipo_arquivo.dart';
import 'package:baixa_arquivos/helps/help.dart';

import '../interfaces/Iconfig.dart';
import 'integracao_config.dart';

class AdquirenteConfigFactory {

  static IConfig criar({
    required TipoAdquirente tipoAdquirente,
    required DateTime dataInicio,
    required DateTime dataFim,
    required TipoArquivo tipoDeArquivo,
    required List<int> refPRId,
    required int id,
  }) {
    return IntegracaoConfig(
      IdIntegracao: id,
      DataInicial: Helper.formatarData(dataInicio),
      DataFinal: Helper.formatarData(dataFim),
      tipoDeArquivo: tipoDeArquivo,
      ListaRefosPRs: refPRId,
    );
  }

}
