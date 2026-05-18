import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.service.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.validation.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/**
 * A página TecnicoListPage é responsável por exibir todos os profissionais registrados no sistema. 
 * Ela utiliza o método executeListOperation para gerir automaticamente o estado de carregamento e a
 * exibição de mensagens caso ococrra algum erro na base de dados SQLite. A interface utiliza o
 * CustomListCard para manter a consistência visual com o restante da aplicação
 */
class TecnicosListPage extends BaseController<Tecnico, TecnicoRepository,
    TecnicoValidation, TecnicoService> {
  TecnicosListPage(super.service);

  @override
  Widget buildPage(BuildContext context, TecnicoService service) {
    return _TecnicosListView(service: service, controller: this);
  }
}

class _TecnicosListView extends StatefulWidget {
  final TecnicoService service;
  final TecnicosListPage controller;

  const _TecnicosListView({required this.service, required this.controller});

  @override
  State<_TecnicosListView> createState() => _TecnicosListViewState();
}

class _TecnicosListViewState extends State<_TecnicosListView> {
  List<Tecnico> _tecnicos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarTecnicos();
    });
  }

  Future<void> _carregarTecnicos() async {
    final result = await widget.controller.executeListOperation(
      context,
      widget.service.findAll(),
      loadingMessage: 'Carregando equipe técnica...',
    );
    setState(() => _tecnicos = result);
  }

  Future<void> _excluirTecnico(Tecnico tecnico) async {
    if (tecnico.id == null) return;

    final sucesso = await widget.controller.executeCrudOperation(
      context,
      widget.service.delete(tecnico.id!), // Invoca a remoção na base local
      loadingMessage: 'Removendo técnico...',
      successMessage: 'Técnico removido com sucesso!',
    );

    if (sucesso) _carregarTecnicos(); // Recarrega a listagem atualizada
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipe de Técnicos'),
        actions: [
          IconButton(icon: const Icon(AppIcons.refresh), onPressed: _carregarTecnicos),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: AppIcons.add,
        tooltip: 'Novo Técnico',
        onPressed: () => Navigator.pushNamed(context, '/tecnico/novo').then((value) {
          if (value == true) _carregarTecnicos();
        }),
      ),
      body: _tecnicos.isEmpty
          ? const CustomEmptyStateCard(
              icon: AppIcons.person,
              title: 'Nenhum técnico cadastrado',
              message: 'Toque no botão + para adicionar profissionais à equipe.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _tecnicos.length,
              itemBuilder: (context, index) {
                final tecnico = _tecnicos[index];
                
                return CustomListCard(
                  // Indicativo visual de ativo/inativo repassado para o card
                  isActive: tecnico.ativo, 
                  // Exibição combinada do ID do técnico junto ao seu nome
                  title: Text(
                    '#${tecnico.id} - ${tecnico.nome}', 
                    style: AppTextStyles.h4.copyWith(
                      color: tecnico.ativo ? Colors.black : Colors.grey,
                    ),
                  ),
                  subtitle: Text(tecnico.ativo ? 'Disponível' : 'Inativo / Afastado'),
                  trailing: CrudPopupMenuButton<Tecnico>(
                    item: tecnico,
                    isActive: tecnico.ativo,
                    onSelected: (action) {
                      if (action == 'editar') {
                        Navigator.pushNamed(context, '/tecnico/editar', arguments: tecnico).then((value) {
                          if (value == true) _carregarTecnicos();
                        });
                      } else if (action == 'excluir') {
                        _excluirTecnico(tecnico);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}