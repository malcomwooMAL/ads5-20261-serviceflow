import 'package:serviceflow/app/core/base/base.schedule.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/data/tecnico.provider.dart';

class TecnicoSchedule extends BaseSchedule<Tecnico, TecnicoRepository, TecnicoProvider> {
  TecnicoSchedule() : super(TecnicoRepository(), TecnicoProvider());

  @override
  String get featureName => 'tecnicos';

  @override
  Duration get syncInterval => const Duration(minutes: 5);
}
