import 'package:intl/intl.dart';

/// Utilitarios de formatação para datas, horas e numeros no app.
class Formatters {
  Formatters._();

  static final DateFormat _dataHora = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _data = DateFormat('dd/MM/yyyy');
  static final DateFormat _hora = DateFormat('HH:mm');

  /// Formata data/hora ISO (ex.: 2026-08-01T21:30:00Z) em dd/MM/yyyy HH:mm.
  static String dataHora(DateTime? d) {
    if (d == null) return '—';
    return _dataHora.format(d.toLocal());
  }

  static String data(DateTime? d) {
    if (d == null) return '—';
    return _data.format(d.toLocal());
  }

  static String hora(DateTime? d) {
    if (d == null) return '—';
    return _hora.format(d.toLocal());
  }

  /// Converte uma string ISO com timezone; retorna null se invalida.
  static DateTime? parseIso(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final d = DateTime.tryParse(iso);
    return d;
  }
}
