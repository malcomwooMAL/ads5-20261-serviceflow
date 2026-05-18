import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';

/**
 * Camada de Validação 
 * Aplicação das regras que garantem a integridade dos dados antes da gravação,
 * sendo aqui apurados, segundo os requisitos, a obrigatoriedade e duplicidade
 * de nome
 */
class TecnicoValidation extends BaseValidation<Tecnico, TecnicoRepository> {
  TecnicoValidation(TecnicoRepository repository) : super(repository);

  @override
  void validateFields(Tecnico? model) {
    if (model == null || model.nome.trim().isEmpty) {
      throw Exception("O nome do técnico é obrigatório");
    }
  }

  @override
  Future<void> validateRulesCreate(Tecnico model) async {
    if (await repository.existsByNome(model.nome)) {
      throw Exception("Já existe um técnico cadastrado com este nome");
    }
  }
}