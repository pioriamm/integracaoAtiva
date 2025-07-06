class Helper {

  static String formatarData(DateTime? data) {
    if (data == null || data.year < 1) {
      throw ArgumentError('Data inválida: ano fora do intervalo');
    }

    var dataFormatada = '${data.year.toString().padLeft(4, '0')}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}T00:00:00';

    return dataFormatada;
  }

}