import 'package:serviceflow/app/modules/usuarios/usuario.schedule.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.schedule.dart';

/// Gerenciador central de schedules
///
/// Responsável por:
/// - Registrar e coordenar todos os schedules do sistema
/// - Inicializar/parar schedules em grupo
/// - Monitorar status geral de sincronização
/// - Facilitar debugging e logs centralizados
class ScheduleManager {
  static final ScheduleManager _instance = ScheduleManager._init();
  factory ScheduleManager() => _instance;
  ScheduleManager._init();

  final List<dynamic> _schedules = [];
  bool _isInitialized = false;

  /// Inicializar todos os schedules registrados
  Future<void> initialize() async {
    if (_isInitialized) {
      _log('ScheduleManager já inicializado');
      return;
    }

    _log('Inicializando ScheduleManager...');

    // Auto-registrar schedules conhecidos
    await _autoRegisterSchedules();

    // Iniciar todos os schedules
    for (final schedule in _schedules) {
      try {
        await schedule.start();
        _log('Schedule ${schedule.featureName} iniciado');
      } catch (e) {
        _log('Erro ao iniciar schedule ${schedule.featureName}: $e');
      }
    }

    _isInitialized = true;
    _log('ScheduleManager inicializado com ${_schedules.length} schedules');
  }

  /// Parar todos os schedules
  Future<void> stopAll() async {
    _log('Parando todos os schedules...');

    for (final schedule in _schedules) {
      try {
        schedule.stop();
        _log('Schedule ${schedule.featureName} parado');
      } catch (e) {
        _log('Erro ao parar schedule ${schedule.featureName}: $e');
      }
    }

    _schedules.clear();
    _isInitialized = false;
    _log('Todos os schedules foram parados');
  }

  /// Forçar sincronização de todos os schedules
  Future<Map<String, bool>> syncAll() async {
    _log('Iniciando sincronização forçada de todos os schedules...');

    final results = <String, bool>{};

    for (final schedule in _schedules) {
      try {
        final success = await schedule.syncNow();
        results[schedule.featureName] = success;
        _log('Sync ${schedule.featureName}: ${success ? 'SUCCESS' : 'FAILED'}');
      } catch (e) {
        results[schedule.featureName] = false;
        _log('Erro no sync ${schedule.featureName}: $e');
      }
    }

    final successCount = results.values.where((success) => success).length;
    _log('Sync completo: $successCount/${results.length} sucessos');

    return results;
  }

  /// Sincronizar schedule específico por nome
  Future<bool> syncFeature(String featureName) async {
    final schedule =
        _schedules.where((s) => s.featureName == featureName).firstOrNull;

    if (schedule == null) {
      _log('Schedule não encontrado: $featureName');
      return false;
    }

    _log('Iniciando sync específico: $featureName');

    try {
      final success = await schedule.syncNow();
      _log('Sync $featureName: ${success ? 'SUCCESS' : 'FAILED'}');
      return success;
    } catch (e) {
      _log('Erro no sync $featureName: $e');
      return false;
    }
  }

  /// Registrar schedule customizado
  void registerSchedule(dynamic schedule) {
    final existing = _schedules
        .where((s) => s.featureName == schedule.featureName)
        .firstOrNull;

    if (existing != null) {
      _log('Schedule ${schedule.featureName} já registrado, substituindo...');
      existing.dispose();
      _schedules.remove(existing);
    }

    _schedules.add(schedule);
    _log('Schedule ${schedule.featureName} registrado');

    // Se já inicializado, iniciar o novo schedule
    if (_isInitialized) {
      schedule.start().catchError((e) {
        _log('Erro ao iniciar schedule ${schedule.featureName}: $e');
      });
    }
  }

  /// Auto-registrar schedules conhecidos do sistema
  Future<void> _autoRegisterSchedules() async {
    // Registrar automaticamente schedules das features implementadas
    _schedules.addAll([
      UsuarioSchedule(), // Singleton já existente
      TecnicoSchedule(),
      // Adicionar novos schedules aqui conforme implementados:
      // ClienteSchedule(),
      // OrdemServicoSchedule(),
      // etc.
    ]);

    _log('${_schedules.length} schedules auto-registrados');
  }

  /// Status geral do sistema
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'schedules_count': _schedules.length,
      'schedules': _schedules
          .map((s) => {
                'feature': s.featureName,
                'interval': s.syncInterval.inMinutes,
              })
          .toList(),
    };
  }

  /// Lista nomes das features com schedule
  List<String> getRegisteredFeatures() {
    return _schedules.map((s) => s.featureName as String).toList();
  }

  /// Cleanup recursos
  void dispose() {
    stopAll();
  }

  void _log(String message) {
    print('[${DateTime.now()}] [SCHEDULE_MANAGER] $message');
  }
}

// Extension helper para List.firstOrNull (se não existir na versão do Dart)
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
