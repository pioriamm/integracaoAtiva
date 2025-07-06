
class Adquirentes {
  int? codigo;
  String? nome;
  String? urlImage;

  Adquirentes({this.codigo, this.nome});

  Adquirentes.fromJson(Map<String, dynamic> json) {
    codigo = json['Codigo'];
    nome = json['Nome'];
    urlImage = 'https://app.conciliadora.com.br/Img/Operadoras/${json['Codigo']}_64x64.png';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Codigo'] = codigo;
    data['Nome'] = nome;
    data['UrlImage'] = urlImage;
    return data;
  }
}