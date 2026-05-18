import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart'; // Obrigatório para capturar a exceção PlatformException
import 'dart:developer' as developer;
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/presentation/controllers/ordem_servico.controller.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';

import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';

class OrdemServicoFormPage extends StatefulWidget {
  final OrdemServicoService service;
  const OrdemServicoFormPage(this.service, {super.key});

  @override
  State<OrdemServicoFormPage> createState() => _OrdemServicoFormPageState();
}

class _OrdemServicoFormPageState extends State<OrdemServicoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _obsController = TextEditingController();
  final _pecasController = TextEditingController();
  final _valorPecasController = TextEditingController();

  final ClienteRepository _clienteRepo = ClienteRepository();
  final TecnicoRepository _tecnicoRepo = TecnicoRepository();
  final ServicoRepository _servicoRepo = ServicoRepository();

  List<Cliente> _clientesDisponiveis = [];
  List<Tecnico> _tecnicosDisponiveis = [];
  List<Servico> _servicosDisponiveis = [];

  final List<Servico> _itensSelecionados = [];
  String? _pathFotoAntes; 
  late SignatureController _signatureController;
  Uint8List? _assinaturaBytes;
  
  final ImagePicker _picker = ImagePicker();
  late final OrdemServicoController _controller;  
  
  int? _clienteId;
  int? _tecnicoId;

  @override
  void initState() {
    super.initState();
    _controller = OrdemServicoController(widget.service);
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: AppColors.primary, // Ajustado para o token de cor correto
      exportBackgroundColor: Colors.white,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosDeApoio();
    });
  }

  @override
  void dispose() {
    _obsController.dispose();
    _pecasController.dispose();
    _valorPecasController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosDeApoio() async {
    try {
      final clientes = await _clienteRepo.findAll();
      final tecnicos = await _tecnicoRepo.findAll();
      final servicos = await _servicoRepo.findAll();

      setState(() {
        _clientesDisponiveis = clientes.where((c) => c.ativo).toList();
        _tecnicosDisponiveis = tecnicos.where((t) => t.ativo).toList();
        _servicosDisponiveis = servicos.where((s) => s.ativo).toList();
      });
    } catch (e, stackTrace) {
      // REGRA: Proibido silenciar. Registra o erro físico do banco de dados local com a StackTrace
      developer.log(
        'Falha ao ler tabelas de apoio (Clientes/Técnicos/Serviços) no SQLite',
        error: e,
        stackTrace: stackTrace,
        name: 'ServiceFlow.OrdemServico',
      );
      _controller.showError(context, "Erro de infraestrutura ao carregar tabelas de apoio.");
    }
  }

  void _exibirSeletorServicos() {
    if (_servicosDisponiveis.isEmpty) {
      _controller.showError(context, "Nenhum serviço ativo encontrado no catálogo.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        Servico? servicoSelecionado = _servicosDisponiveis.first;
        
        return AlertDialog(
          title: const Text("Selecionar Serviço"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return DropdownButtonFormField<Servico>(
                value: servicoSelecionado,
                decoration: const InputDecoration(labelText: 'Serviço disponível'),
                items: _servicosDisponiveis.map((s) {
                  return DropdownMenuItem<Servico>(
                    value: s,
                    child: Text("${s.descricao} (R\$ ${s.preco.toStringAsFixed(2)})"),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    servicoSelecionado = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (servicoSelecionado != null) {
                  setState(() {
                    _itensSelecionados.add(servicoSelecionado!);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Adicionar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _capturarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _pathFotoAntes = image.path;
        });
      }
    } catch (e) {
      _controller.showError(context, "Erro ao acessar a câmara.");
    }
  }

  void _limparAssinatura() {
    _signatureController.clear();
    setState(() {
      _assinaturaBytes = null;
    });
  }

  Future<void> _exportarAssinatura() async {
    if (_signatureController.isNotEmpty) {
      final bytes = await _signatureController.toPngBytes();
      setState(() {
        _assinaturaBytes = bytes;
      });
    }
  }

  Future<void> _salvarOS() async {
    if (_clienteId == null || _tecnicoId == null) {
      _controller.showError(context, "Selecione o Cliente e o Técnico.");
      return;
    }

    await _exportarAssinatura();

    final novaOS = OrdemServico(
      clienteId: _clienteId!,
      tecnicoId: _tecnicoId!,
      itens: _itensSelecionados,
      observacao: _obsController.text,
      pecasAplicadas: _pecasController.text,
      valorPecas: double.tryParse(_valorPecasController.text) ?? 0.0,
      fotoAntes: _pathFotoAntes,
      fotoDepois: null, 
      assinatura: _assinaturaBytes != null ? _assinaturaBytes.hashCode.toString() : null,
    );

    final sucesso = await _controller.salvarNovaOrdem(context, novaOS);
    if (sucesso) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(title: const Text('Nova O.S.')),
      body: SafeArea( 
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(24.0), 
          child: Form( 
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Dados Principais", style: AppTextStyles.h3),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<int>(
                  value: _clienteId,
                  decoration: const InputDecoration(
                    labelText: 'Selecionar Cliente',
                    prefixIcon: Icon(AppIcons.person),
                  ),
                  items: _clientesDisponiveis.map((cliente) {
                    return DropdownMenuItem<int>(
                      value: cliente.id,
                      child: Text(cliente.nome),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _clienteId = value),
                  validator: (value) => value == null ? 'Por favor, selecione um cliente' : null,
                ),
                
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: _tecnicoId,
                  decoration: const InputDecoration(
                    labelText: 'Selecionar Técnico',
                    prefixIcon: Icon(AppIcons.handyman),
                  ),
                  items: _tecnicosDisponiveis.map((tecnico) {
                    return DropdownMenuItem<int>(
                      value: tecnico.id,
                      child: Text(tecnico.nome),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _tecnicoId = value),
                  validator: (value) => value == null ? 'Por favor, selecione um técnico' : null,
                ),

                const SizedBox(height: 24),
                const Text("Serviços Realizados", style: AppTextStyles.h3),
                
                ..._itensSelecionados.asMap().entries.map((entry) {
                  return CustomListCard(
                    title: Text(entry.value.descricao),
                    subtitle: Text("R\$ ${entry.value.preco}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: AppColors.danger),
                      onPressed: () => setState(() => _itensSelecionados.removeAt(entry.key)),
                    ),
                  );
                }),
                
                const SizedBox(height: 8),
                // CORREÇÃO: Uso do componente homologado em substituição ao TextButton.icon
                CustomPrimaryButton(
                  text: "Adicionar Serviço ao Histórico",
                  icon: Icons.add,
                  onPressed: _exibirSeletorServicos,
                ),

                const SizedBox(height: 24),
                CustomTextField(controller: _obsController, label: "Observações Gerais", prefixIcon: AppIcons.notes),
                const SizedBox(height: 16),
                CustomTextField(controller: _pecasController, label: "Peças Aplicadas", prefixIcon: AppIcons.build),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _valorPecasController, 
                  label: "Valor Total das Peças", 
                  prefixIcon: AppIcons.money,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),
                const Text("Evidência Fotográfica Inicial", style: AppTextStyles.h3),
                const SizedBox(height: 16),
                
                // CORREÇÃO: Uso do componente homologado para disparo da câmera
                _pathFotoAntes == null 
                  ? CustomPrimaryButton(
                      text: "Registrar Estado Inicial (Antes)",
                      icon: AppIcons.camera,
                      onPressed: _capturarFoto,
                    )
                  : Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(File(_pathFotoAntes!), fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 8),
                        CustomPrimaryButton(
                          text: "Remover Foto Registrada",
                          icon: AppIcons.clear,
                          onPressed: () => setState(() => _pathFotoAntes = null),
                        ),
                      ],
                    ),

                const SizedBox(height: 24),
                const Text("Assinatura do Cliente", style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    color: AppColors.light,
                  ),
                  child: Signature(
                    controller: _signatureController,
                    height: 150,
                    backgroundColor: AppColors.light,
                  ),
                ),
                const SizedBox(height: 12),
                // CORREÇÃO: Linha de botões adaptada estritamente para os componentes da biblioteca
                Row(
                  children: [
                    Expanded(
                      child: CustomPrimaryButton(
                        text: "Limpar",
                        icon: AppIcons.clear,
                        onPressed: _limparAssinatura,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomPrimaryButton(
                        text: "Confirmar",
                        icon: AppIcons.check,
                        onPressed: _exportarAssinatura,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                CustomPrimaryButton(
                  text: 'FINALIZAR E SALVAR',
                  icon: AppIcons.save,
                  onPressed: _salvarOS,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}