import 'package:baixa_arquivos/helps/help.dart';
import 'package:baixa_arquivos/enum/tipo_adquirente.dart';
import 'package:baixa_arquivos/enum/tipo_arquivo.dart';

import 'adquirente_config.dart';
import 'ifood_config.dart';

class AdquirenteConfigFactory {

  static AdquirenteConfig criar({
    required TipoAdquirente tipoAdquirente,
    required DateTime dataInicio,
    required DateTime dataFim,
    required TipoArquivo tipoDeArquivo,
    required List<int> refPRId,
  }) {
    switch (tipoAdquirente) {
      case TipoAdquirente.Ifood:
        return IntegracaoConfig(
            IdIntegracao: 68,
            DataInicial: Helper.formatarData(dataInicio),
            DataFinal: Helper.formatarData(dataFim),
            Ids: refPRId,
            tipoDeArquivo: tipoDeArquivo
        );

      default:
        throw UnsupportedError('Adquirente não suportado: $tipoAdquirente');
    }
  }
}
