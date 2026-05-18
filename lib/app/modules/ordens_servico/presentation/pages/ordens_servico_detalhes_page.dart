import 'package:flutter/material.dart';
import 'dart:io';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/presentation/controllers/ordem_servico.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; 
import 'dart:developer' as developer;
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';

class OrdemServicoDetalhesPage extends StatefulWidget {
  final OrdemServicoService service;
  final OrdemServico ordem;

  const OrdemServicoDetalhesPage(this.service, {super.key, required this.ordem});

  @override
  State<OrdemServicoDetalhesPage> createState() => _OrdemServicoDetalhesPageState();
}

class _OrdemServicoDetalhesPageState extends State<OrdemServicoDetalhesPage> {
  String? _pathFotoDepois;
  final ImagePicker _picker = ImagePicker();
  late final OrdemServicoController _controller;
  late final OrdemServico _ordemAtual;

  final ClienteRepository _clienteRepo = ClienteRepository();
  final TecnicoRepository _tecnicoRepo = TecnicoRepository();

  String _clienteExibicao = "Carregando...";
  String _tecnicoExibicao = "Carregando...";

  @override
  void initState() {
    super.initState();
    _controller = OrdemServicoController(widget.service);
    _ordemAtual = widget.ordem;
    _pathFotoDepois = _ordemAtual.fotoDepois;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarNomesDeApoio();
    });
  }

  Future<void> _buscarNomesDeApoio() async {
    try {
      final clientes = await _clienteRepo.findAll();
      final tecnicos = await _tecnicoRepo.findAll();

      final clienteAlvo = clientes.firstWhere((c) => c.id == _ordemAtual.clienteId);
      final tecnicoAlvo = tecnicos.firstWhere((t) => t.id == _ordemAtual.tecnicoId);

      setState(() {
        _clienteExibicao = "${clienteAlvo.nome} (ID: ${clienteAlvo.id})";
        _tecnicoExibicao = "${tecnicoAlvo.nome} (ID: ${tecnicoAlvo.id})";
      });
    } catch (e, stackTrace) {
      // Proibido silenciar: O log registra o porquê de o cliente não ter sido localizado no SQLite
      developer.log(
        'Inconsistência relacional: O.S. aponta para cliente inexistente',
        error: e,
        stackTrace: stackTrace,
        name: 'ServiceFlow.Database'
      );
      setState(() { _clienteExibicao = "Cliente Indisponível (Erro de Vínculo)"; });
    }
  }

  Future<void> _capturarFotoDepois() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _pathFotoDepois = image.path;
        });
      }
    } catch (e) {
      _controller.showError(context, "Erro ao acessar a câmara.");
    }
  }

  Future<void> _concluirOS() async {
    if (_pathFotoDepois == null) {
      _controller.showError(context, "A foto do serviço concluído (Depois) é obrigatória para o encerramento.");
      return;
    }

    final ordemFinalizada = OrdemServico(
      id: _ordemAtual.id,
      clienteId: _ordemAtual.clienteId,
      tecnicoId: _ordemAtual.tecnicoId,
      itens: _ordemAtual.itens,
      observacao: _ordemAtual.observacao,
      pecasAplicadas: _ordemAtual.pecasAplicadas,
      valorPecas: _ordemAtual.valorPecas,
      fotoAntes: _ordemAtual.fotoAntes,
      fotoDepois: _pathFotoDepois,
      assinatura: _ordemAtual.assinatura,
      ativo: _ordemAtual.ativo, 
      isSync: 0, 
    );

    final sucesso = await _controller.finalizarOrdemServico(context, ordemFinalizada);
    if (sucesso) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciar O.S. #${_ordemAtual.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Resumo do Atendimento", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            
            // CORREÇÃO: Utilização do CustomListCard homologado no lugar do Card nativo do Flutter
            CustomListCard(
              isActive: _ordemAtual.ativo,
              title: Text("Cliente: $_clienteExibicao"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("Técnico: $_tecnicoExibicao"),
                  const SizedBox(height: 4),
                  Text("Peças: ${_ordemAtual.pecasAplicadas ?? 'Nenhuma peça informada'}"),
                  const SizedBox(height: 4),
                  Text("Valor das Peças: R\$ ${_ordemAtual.valorPecas.toStringAsFixed(2)}"),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text("Evidência Inicial (Antes)", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _ordemAtual.fotoAntes != null
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(File(_ordemAtual.fotoAntes!), fit: BoxFit.cover),
                  )
                : const Text("Nenhuma foto registrada na abertura chamado."),

            const SizedBox(height: 24),
            const Text("Conclusão do Trabalho (Depois)", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            
            // CORREÇÃO: Uso obrigatório do CustomPrimaryButton para ações de foto da entrega
            _pathFotoDepois == null
                ? CustomPrimaryButton(
                    text: "Registrar Entrega (Foto Depois)",
                    icon: AppIcons.camera,
                    onPressed: _capturarFotoDepois,
                  )
                : Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.file(File(_pathFotoDepois!), fit: BoxFit.cover),
                      ),
                      if (_ordemAtual.ativo) ...[
                        const SizedBox(height: 8),
                        CustomPrimaryButton(
                          text: "Substituir Foto Tirada",
                          icon: AppIcons.clear,
                          onPressed: () => setState(() => _pathFotoDepois = null),
                        ),
                      ],
                    ],
                  ),

            const SizedBox(height: 32),
            if (_ordemAtual.ativo)
              CustomPrimaryButton(
                text: 'CONCLUIR E FINALIZAR O.S.',
                icon: AppIcons.check,
                onPressed: _concluirOS,
              ),
          ],
        ),
      ),
    );
  }
}