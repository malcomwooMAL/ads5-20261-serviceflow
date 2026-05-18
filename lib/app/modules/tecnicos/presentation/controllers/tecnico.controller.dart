import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.service.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.validation.dart';

/// Controller para o módulo de Técnicos.
/// 
/// Estende [BaseController] para herdar capacidades de:
/// - LoaderMixin: showLoading(), hideLoading()
/// - MessagesMixin: showSuccess(), showError(), showConfirmation()
/// - Operações centralizadas: executeListOperation, executeCrudOperation
class TecnicoController extends BaseController<Tecnico, TecnicoRepository,
    TecnicoValidation, TecnicoService> {
  
  TecnicoController(super.service, {super.model});

  @override
  Widget buildPage(BuildContext context, TecnicoService service) {
    // Como o ServiceFlow utiliza rotas nomeadas no AppRoutes para instanciar
    // as páginas diretamente, este método atua como um placeholder obrigatório.
    // O estado da tela é gerido pelas subclasses de StatefulWidget (Pages).
    return const SizedBox.shrink();
  }
}