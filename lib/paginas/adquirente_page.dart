import 'package:baixa_arquivos/enum/tipo_adquirente.dart';
import 'package:baixa_arquivos/enum/tipo_arquivo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../controles/adquirente_config_factory.dart';
import '../modelos/adquirentes.dart';
import '../repository/adquirente_repository.dart';
import '../repository/integracao_ativa_repository.dart';

class AdquirentePage extends StatefulWidget {
  const AdquirentePage({super.key});

  @override
  State<AdquirentePage> createState() => _AdquirentePageState();
}

class _AdquirentePageState extends State<AdquirentePage> {
  late List<Adquirentes> _listaAdquirentes = [];
  final List<int> _adquirentesAtivasIds = [
    07,
    68,
    45,
    16,
    97,
    53,
    95,
    3,
    109,
    112,
    76,
  ];
  bool _carregandoAdquirentes = true;

  final TextEditingController _pesquisaController = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _carregarAdquirentes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF103239),
      appBar: AppBar(
        backgroundColor: Color(0xFF103239),
        centerTitle: true,
        title: const Text(
          'Selecione uma Adquirente',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.10,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _pesquisaController,
                      onChanged: (_) => _filtrarAdquirentes(),
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar Adquirente',
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.refresh),
                    onPressed: _carregarAdquirentes,
                    tooltip: 'Recarregar Lista',
                  ),
                ],
              ),
            ),
            Expanded(child: _buildGridAdquirentes()),
          ],
        ),
      ),
    );
  }

  Future<void> _carregarAdquirentes() async {
    setState(() => _carregandoAdquirentes = true);
    final adquirentes = await AdquirenteRepository.buscarAdquirentes();
    if (mounted) {
      setState(() {
        _listaAdquirentes = adquirentes
          ..sort((a, b) => (a.nome ?? '').compareTo(b.nome ?? ''));
        _carregandoAdquirentes = false;
      });
    }
  }

  void _filtrarAdquirentes() {
    setState(() {
      _filtro = _pesquisaController.text.toLowerCase();
    });
  }

  void _mostrarSnackBar(String mensagem, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
  }

  Widget _buildGridAdquirentes() {
    if (_carregandoAdquirentes) {
      return const Center(child: CircularProgressIndicator());
    }

    final adquirentesFiltrados = _listaAdquirentes
        .where((a) => (a.nome ?? '').toLowerCase().contains(_filtro))
        .toList();

    if (adquirentesFiltrados.isEmpty) {
      return const Center(child: Text('Nenhuma adquirente encontrada.'));
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.2,
        ),
        itemCount: adquirentesFiltrados.length,
        itemBuilder: (context, index) {
          final adquirente = adquirentesFiltrados[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(child: _buildAdquirenteCard(adquirente)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdquirenteCard(Adquirentes adquirente) {
    final bool estaHabilitada = _adquirentesAtivasIds.contains(
      adquirente.codigo,
    );
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (adquirente.codigo != null && estaHabilitada) {
            _mostrarFormularioPopup(context, adquirente);
          } else {
            _mostrarSnackBar(
              'Adquirente "${adquirente.nome ?? ''}" com integração não implementada.',
              Colors.orange,
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: estaHabilitada
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.overlay,
                    )
                  : const ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
              child: Image.network(
                adquirente.urlImage ?? '',
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.business,
                    size: 60,
                    color: Colors.grey,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                adquirente.nome ?? 'Nome Indisponível',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                adquirente.codigo.toString() ?? 'Nome Indisponível',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarFormularioPopup(
    BuildContext context,
    Adquirentes adquirente,
  ) async {
    final tipoAdquirente = TipoAdquirente.values.firstWhere(
      (e) => e.name.toLowerCase() == (adquirente.nome ?? '').toLowerCase(),
      orElse: () => TipoAdquirente.Default,
    );

    final formKey = GlobalKey<FormState>();
    TipoArquivo tipoDeArquivo = TipoArquivo.pagamento;
    DateTime dataInicio = DateTime.now().subtract(const Duration(days: 1));
    DateTime dataFim = DateTime.now();
    List<int> refPRId = [];
    int? idAdquirente = adquirente.codigo;
    final refController = TextEditingController();
    bool carregandoEnvio = false;

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            bool isFormValido() {
              return tipoDeArquivo != null &&
                  !dataInicio.isAfter(dataFim) &&
                  refPRId.isNotEmpty;
            }

            Future<void> enviar() async {
              if (!formKey.currentState!.validate()) return;
              setStateInDialog(() => carregandoEnvio = true);
              try {
                final config = AdquirenteConfigFactory.criar(
                  id: idAdquirente!,
                  tipoAdquirente: tipoAdquirente,
                  dataInicio: dataInicio,
                  dataFim: dataFim,
                  tipoDeArquivo: tipoDeArquivo,
                  refPRId: refPRId,
                );
                await IntegracaoAtivaRepository().enviarRequisicao(config);
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                _mostrarSnackBar(
                  'Solicitação agendada com sucesso!',
                  Colors.green,
                );
              } catch (e) {
                _mostrarSnackBar('Erro ao enviar requisição.', Colors.red);
              } finally {
                if (mounted) setStateInDialog(() => carregandoEnvio = false);
              }
            }

            Future<void> selecionarData({required bool isInicio}) async {
              final selecionada = await showDatePicker(
                context: context,
                initialDate: isInicio ? dataInicio : dataFim,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selecionada != null) {
                setStateInDialog(
                  () => isInicio
                      ? dataInicio = selecionada
                      : dataFim = selecionada,
                );
              }
            }

            return AlertDialog(
              title: Text(
                'Solicitar arquivo ${adquirente.nome ?? "Adquirente"}',
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.5,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: (adquirente.nome ?? '').toUpperCase(),
                          decoration: const InputDecoration(
                            labelText: 'Adquirente',
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TipoArquivo>(
                          value: tipoDeArquivo,
                          items: TipoArquivo.values
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setStateInDialog(() => tipoDeArquivo = v!),
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Operação',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => selecionarData(isInicio: true),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Data Início',
                                  ),
                                  child: Text(
                                    '${dataInicio.day.toString().padLeft(2, '0')}/${dataInicio.month.toString().padLeft(2, '0')}/${dataInicio.year}',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => selecionarData(isInicio: false),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Data Fim',
                                  ),
                                  child: Text(
                                    '${dataFim.day.toString().padLeft(2, '0')}/${dataFim.month.toString().padLeft(2, '0')}/${dataFim.year}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: refController,
                          decoration: const InputDecoration(
                            labelText: 'Repr (IDs separados por vírgula)',
                            hintText: 'Ex: 123,456,789',
                          ),
                          onChanged: (value) {
                            refPRId = value
                                .split(',')
                                .map((e) => int.tryParse(e.trim()))
                                .where((e) => e != null)
                                .cast<int>()
                                .toList();
                            setStateInDialog(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                if (carregandoEnvio)
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: CircularProgressIndicator(),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: carregandoEnvio || !isFormValido() ? null : enviar,
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
