import 'package:serviceflow/app/core/base/base.provider.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/core/http/app_client.dart';
import 'package:serviceflow/app/core/logging/log.service.dart';

class TecnicoProvider extends BaseProvider<Tecnico> {
  final AppClient _client = AppClient();
  final LogService _logger = LogService();

  @override
  String get endpoint => '/tecnicos';

  @override
  Future<List<Tecnico>> fetchFromCloud({DateTime? lastSync}) async {
    try {
      final response = await _client.get(endpoint);
      if (response.data is List) {
        return (response.data as List).map((item) => fromExternalFormat(item)).toList();
      }
      return [];
    } catch (e) {
      _logger.error('TecnicoProvider', 'fetchFromCloud', e.toString());
      return [];
    }
  }

  @override
  Future<bool> syncToCloud(Tecnico entity) async {
    try {
      final payload = toExternalFormat(entity);
      await _client.post(endpoint, data: payload);
      return true;
    } catch (e) {
      _logger.error('TecnicoProvider', 'syncToCloud', e.toString());
      return false;
    }
  }

  @override
  Map<String, dynamic> toExternalFormat(Tecnico entity) {
    return entity.toMap();
  }

  @override
  Tecnico fromExternalFormat(Map<String, dynamic> data) {
    return Tecnico.fromMap(data);
  }

  @override
  Future<bool> validateBeforeSync(Tecnico entity) async {
    if (entity.nome.isEmpty) {
      throw Exception('Nome do técnico não pode ser vazio para sincronização');
    }
    return true;
  }

  @override
  Future<Tecnico> resolveConflict(Tecnico local, Tecnico remote) async {
    // Usamos a lógica básica de resolução de conflitos por timestamp se implementado, senão local ganha.
    if (local.createdAt != null && remote.createdAt != null) {
      if (local.createdAt!.isAfter(remote.createdAt!)) {
        return local;
      }
      return remote;
    }
    return local;
  }

  @override
  void handleError(String operation, dynamic error) {
    _logger.error('TecnicoProvider', operation, error.toString());
  }
}
