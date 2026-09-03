/// Modelo de um atleta do elenco profissional do Vasco.
///
/// Sem dados confiáveis de fotos disponíveis localmente, a interface exibe
/// a inicial do atleta num avatar (sem depender de rede).
class Player {
  final String number;
  final String name;
  final String position;
  final String? photo;

  const Player({
    required this.number,
    required this.name,
    required this.position,
    this.photo,
  });

  factory Player.fromMap(Map<String, dynamic> json) => Player(
        number: json['num']?.toString() ?? json['number']?.toString() ?? '-',
        name: json['nome']?.toString() ?? json['name']?.toString() ?? '-',
        position: json['pos']?.toString() ?? json['position']?.toString() ?? '-',
        photo: json['foto']?.toString(),
      );

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
