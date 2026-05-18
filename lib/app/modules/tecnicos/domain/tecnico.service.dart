import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/domain/tecnico.validation.dart';

class TecnicoService extends BaseService<Tecnico, TecnicoRepository, TecnicoValidation> {
  TecnicoService(TecnicoValidation validation, TecnicoRepository repository)
      : super(validation, repository);

  @override
  Tecnico cloneModelWithId(Tecnico model, int id) {
    return model.copyWith(id: id, createdAt: DateTime.now());
  }
}