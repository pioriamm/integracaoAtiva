import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../controles/adquirente_config_factory.dart';
import '../enum/tipo_arquivo.dart';
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
  late final List<int> _adquirentesAtivasIds;
  bool _carregandoAdquirentes = true;
  String _filtro = '';
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    final String? idAdquirentes = dotenv.env['ADQUIRENTES_HABILITADAS'];
    _adquirentesAtivasIds = idAdquirentes!.isNotEmpty ? List<int>.from(jsonDecode(idAdquirentes)) : [];
    _carregarAdquirentes();
    super.initState();
  }

  Future<void> _carregarAdquirentes() async {
    setState(() => _carregandoAdquirentes = true);
    final adquirentes = await AdquirenteRepository.buscarAdquirentes();
    if (mounted) {
      setState(() {
        _listaAdquirentes = adquirentes..sort((a, b) => (a.nome ?? '').compareTo(b.nome ?? ''));
        _carregandoAdquirentes = false;
      });
    }
  }

  Future<void> _carregarSomenteAdquirentesHabilitadas() async {
    setState(() => _carregandoAdquirentes = true);
    final copiaAdquirente = _listaAdquirentes;
    if (mounted) {
      setState(() {
        _listaAdquirentes = copiaAdquirente.where((a) => _adquirentesAtivasIds.contains(a.codigo)).toList()
          ..sort((a, b) => (a.nome ?? '').compareTo(b.nome ?? ''));
        _carregandoAdquirentes = false;
      });
    }
  }

  void _filtrarAdquirentes(String query) {
    setState(() => _filtro = query.toLowerCase());
  }

  void _mostrarSnackBar(String mensagem, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              _tituloPagina(),
              _barraDePesquisa(),
              Expanded(child: _gridAdquirentes()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloPagina() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          Text(
            'Solicitação de Arquivos - ${dotenv.env['AMBIENTE']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecione uma adquirente para iniciar o processo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _barraDePesquisa() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _pesquisaController,
              onChanged: _filtrarAdquirentes,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xff97d945), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _botoesBarraPesquisa(
            Icons.refresh,
            'Recarregar Todas',
            _carregarAdquirentes,
          ),
          const SizedBox(width: 8),
          _botoesBarraPesquisa(
            Icons.filter_alt,
            'Filtrar Habilitadas',
            _carregarSomenteAdquirentesHabilitadas,
          ),
        ],
      ),
    );
  }

  Widget _botoesBarraPesquisa(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFF475569)),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _gridAdquirentes() {
    if (_carregandoAdquirentes) {
      return const Center(child: CircularProgressIndicator());
    }
    final filtrados = _listaAdquirentes
        .where((a) => (a.nome ?? '').toLowerCase().contains(_filtro))
        .toList();
    if (filtrados.isEmpty) {
      return const Center(child: Text('Nenhuma adquirente encontrada.'));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).floor().clamp(1, 5);

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: filtrados.length,
        itemBuilder: (context, index) {
          final adquirente = filtrados[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: crossAxisCount,
            duration: const Duration(milliseconds: 375),
            child: ScaleAnimation(
              child: FadeInAnimation(child: _adquirenteCard(adquirente)),
            ),
          );
        },
      ),
    );
  }

  Widget _adquirenteCard(Adquirentes adquirente) {
    final habilitada = _adquirentesAtivasIds.contains(adquirente.codigo);
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (habilitada) {
            _popupSolicitarArquivo(context, adquirente);
          } else {
            _mostrarSnackBar(
              'Adquirente "${adquirente.nome ?? ''}" não habilitada.',
              Colors.orange,
            );
          }
        },
        child: Opacity(
          opacity: habilitada ? 1.0 : 0.6,
          child: ColorFiltered(
            colorFilter: habilitada
                ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.network(
                        adquirente.urlImage ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.business,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    adquirente.nome ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${adquirente.codigo}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _popupSolicitarArquivo(
    BuildContext context,
    Adquirentes adquirente,
  ) async {
     final formKey = GlobalKey<FormState>();
    TipoArquivo tipoDeArquivo = TipoArquivo.pagamento;
    DateTime dataInicio = DateTime.now().subtract(const Duration(days: 1));
    DateTime dataFim = DateTime.now();
    final refController = TextEditingController();
    bool carregandoEnvio = false;
    String? erroMensagem;

    await showDialog(
      context: context,
      barrierDismissible: !carregandoEnvio,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            // SEUS MÉTODOS INTERNOS DO POPUP (INTACTOS)
            Future<void> selecionarData({required bool isInicio}) async {
              final selecionada = await showDatePicker(
                context: context,
                initialDate: isInicio ? dataInicio : dataFim,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selecionada != null) {
                setStateInDialog(() {
                  if (isInicio)
                    dataInicio = selecionada;
                  else
                    dataFim = selecionada;
                });
              }
            }

            void enviar() async {
              if (dataInicio.isAfter(dataFim)) {
                setStateInDialog(() {
                  erroMensagem = 'Data inicial não pode ser maior que a final.';
                });
                return; // Interrompe a execução se a validação falhar
              }

              if (refController.text.trim().isEmpty) {
                setStateInDialog(() {
                  erroMensagem = 'Informe ao menos um ID de referência.';
                });
                return; // Interrompe a execução se a validação falhar
              }

              // Se as validações passaram, limpa a mensagem de erro e inicia o carregamento
              setStateInDialog(() {
                erroMensagem = null;
                carregandoEnvio = true;
              });

              try {
                final refPRId = refController.text
                    .split(RegExp(r'[\s,]+'))
                    .where((e) => e.isNotEmpty)
                    .map((e) => int.tryParse(e.trim()))
                    .where((e) => e != null)
                    .cast<int>()
                    .toList();

                final config = AdquirenteConfigFactory.criar(
                  id: adquirente.codigo!,
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
                if (mounted) {
                  setStateInDialog(() => carregandoEnvio = false);
                }
              }
            }

            final inputBorderStyle = OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            );

            // AlertDialog com o novo design
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(24),
              actionsPadding: const EdgeInsets.all(24),
              title: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solicitar: ${adquirente.nome}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: carregandoEnvio
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: (adquirente.nome ?? '').toUpperCase(),
                          decoration: InputDecoration(
                            labelText: 'Adquirente',
                            border: inputBorderStyle,
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
                          decoration: InputDecoration(
                            labelText: 'Tipo de Arquivo',
                            border: inputBorderStyle,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _campoDataPtbr(
                                'Data Início',
                                dataInicio,
                                () => selecionarData(isInicio: true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _campoDataPtbr(
                                'Data Fim',
                                dataFim,
                                () => selecionarData(isInicio: false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: refController,
                          decoration: InputDecoration(
                            labelText: 'Repr (IDs)',
                            hintText: 'IDs separados por vírgula ou espaço',
                            border: inputBorderStyle,
                          ),
                          minLines: 2,
                          maxLines: 4,
                        ),
                        if (erroMensagem != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              erroMensagem!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // SEUS BOTÕES DE AÇÃO COM O NOVO DESIGN
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: carregandoEnvio ? null : enviar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: carregandoEnvio
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('ENVIAR'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: carregandoEnvio
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: const Text('CANCELAR'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _campoDataPtbr(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        ),
      ),
    );
  }
}
