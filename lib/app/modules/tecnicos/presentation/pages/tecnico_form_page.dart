import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.service.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.validation.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/**
 * O TecnicoFormPage permite a criação de novos perfis ou atualização de existentes. A lógica de gravação
 * é encapsulada pelo executeCrudOperation, que solicita uma confirmação ao utilizador se configurado
 * e apresenta o indicador de progresso durante a persistência. Para a entrada de dados, são utilizados
 * os campos de texto padronizados CustomTextField
 */
class TecnicoController extends BaseController<Tecnico, TecnicoRepository,
    TecnicoValidation, TecnicoService> {
  TecnicoController(super.service, {super.model});

  @override
  Widget buildPage(BuildContext context, TecnicoService service) {
    return const SizedBox.shrink();
  }
}

class TecnicoFormPage extends StatefulWidget {
  final TecnicoService service;
  final Tecnico? tecnicoParaEdicao;

  const TecnicoFormPage(this.service, {super.key, this.tecnicoParaEdicao});

  @override
  State<TecnicoFormPage> createState() => _TecnicoFormPageState();
}

class _TecnicoFormPageState extends State<TecnicoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _especialidadeController = TextEditingController(); // Novo controlador
  
  late final TecnicoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TecnicoController(widget.service);
    
    if (widget.tecnicoParaEdicao != null) {
      _nomeController.text = widget.tecnicoParaEdicao!.nome;
      // Popula a especialidade se o modelo contiver esse campo
      // _especialidadeController.text = widget.tecnicoParaEdicao!.especialidade ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especialidadeController.dispose(); // Liberação de memória
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final tecnico = Tecnico(
      id: widget.tecnicoParaEdicao?.id,
      nome: _nomeController.text,
      // Se o seu model possuir a propriedade, descomente a linha abaixo:
      // especialidade: _especialidadeController.text.isEmpty ? null : _especialidadeController.text,
      ativo: widget.tecnicoParaEdicao?.ativo ?? true,
      isSync: 0,
    );

    final isUpdate = widget.tecnicoParaEdicao != null;
    final operation = isUpdate ? widget.service.update(tecnico) : widget.service.create(tecnico);

    final sucesso = await _controller.executeCrudOperation(
      context,
      operation as Future<void>,
      loadingMessage: 'Gravando dados do técnico...',
      successMessage: 'Técnico salvo com sucesso!',
    );

    if (sucesso) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tecnicoParaEdicao != null ? 'Editar Técnico' : 'Novo Técnico'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nomeController,
                label: 'Nome do Técnico',
                prefixIcon: AppIcons.person,
                validator: (value) => (value == null || value.isEmpty) ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              // Novo campo visual para capturar a especialidade do profissional
              CustomTextField(
                controller: _especialidadeController,
                label: 'Especialidade / Cargo',
                prefixIcon: AppIcons.build,
              ),
              const SizedBox(height: 24),
              CustomPrimaryButton(
                text: widget.tecnicoParaEdicao != null ? 'Atualizar' : 'Salvar',
                icon: AppIcons.save,
                onPressed: _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}