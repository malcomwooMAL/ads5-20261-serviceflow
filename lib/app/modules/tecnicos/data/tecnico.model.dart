import 'package:serviceflow/app/core/base/base.model.dart';

/**
 * Herda da classe BaseModel, para garantir a integridade da arquitetura
 * proposta pelo professor.
 */
class Tecnico extends BaseModel {
  final String nome;
  final String? especialidade;

  Tecnico({
    super.id,
    super.createdAt,
    super.isSync = 0,
    super.ativo = true,
    required this.nome,
    this.especialidade,
  });

  Tecnico.fromMap(Map<String, dynamic> map)
      : nome = map['nome'] as String,
        especialidade = map['especialidade'] as String?,
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'nome': nome,
      'especialidade': especialidade,
    };
  }

  Tecnico copyWith({
    int? id,
    DateTime? createdAt,
    int? isSync,
    bool? ativo,
    String? nome,
    String? especialidade,
  }) {
    return Tecnico(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isSync: isSync ?? this.isSync,
      ativo: ativo ?? this.ativo,
      nome: nome ?? this.nome,
      especialidade: especialidade ?? this.especialidade,
    );
  }
}