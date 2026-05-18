import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';

/**
 * Camada de Repositorio, o qual fará a gestão direta do SQLite, 
 * por meio do DbHelper, isolando/desacoplando a lógica de persistência
 * local.
 */
class TecnicoRepository extends BaseRepository<Tecnico> {
  @override
  String get tableName => 'tecnicos';

  @override
  Tecnico fromMap(Map<String, dynamic> map) {
    return Tecnico.fromMap(map);
  }

  Future<bool> existsByNome(String nome) async {
    return await exists('nome = ?', [nome]);
  }
}