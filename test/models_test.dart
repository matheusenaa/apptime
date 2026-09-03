import 'package:flutter_test/flutter_test.dart';

import 'package:app_time_vasco/data/historical_data.dart';
import 'package:app_time_vasco/models/match.dart';
import 'package:app_time_vasco/models/standing.dart';

void main() {
  group('Match.fromJson', () {
    test('parseia jogo agendado', () {
      final json = {
        'fixture': {
          'id': 1,
          'date': '2026-08-01T21:30:00+00:00',
          'status': {'short': 'NS'},
          'venue': {'name': 'São Januário'},
        },
        'league': {'name': 'Brasileirão Série A'},
        'teams': {
          'home': {'name': 'Vasco da Gama'},
          'away': {'name': 'Flamengo'},
        },
        'goals': {'home': null, 'away': null},
      };

      final m = Match.fromJson(json);
      expect(m.isScheduled, isTrue);
      expect(m.isVascoHome, isTrue);
      expect(m.opponentName, 'Flamengo');
      expect(m.venue, 'São Januário');
    });

    test('parseia jogo ao vivo com placar', () {
      final json = {
        'fixture': {
          'id': 2,
          'date': '2026-08-01T21:30:00+00:00',
          'status': {'short': '2H', 'elapsed': 70},
        },
        'league': {'name': 'Brasileirão Série A'},
        'teams': {
          'home': {'name': 'Botafogo'},
          'away': {'name': 'Vasco da Gama'},
        },
        'goals': {'home': 1, 'away': 2},
      };

      final m = Match.fromJson(json);
      expect(m.isLive, isTrue);
      expect(m.isVascoHome, isFalse);
      expect(m.opponentName, 'Botafogo');
      expect(m.vascaoScore, '2');
      expect(m.opponentScore, '1');
      expect(m.minute, '70');
      expect(m.statusLabel, "70'");
    });
  });

  group('Standing.fromJson', () {
    test('parseia linha da tabela e identifica Vasco', () {
      final json = {
        'rank': 3,
        'team': {'id': 129, 'name': 'Vasco da Gama'},
        'points': 52,
        'all': {'played': 30, 'win': 15, 'draw': 7, 'lose': 8},
        'goals': {'for': 45, 'against': 32},
      };

      final s = Standing.fromJson(json, vascoId: 129);
      expect(s.position, 3);
      expect(s.isVasco, isTrue);
      expect(s.goalDifference, 13);
      expect(s.wins, 15);
    });
  });

  group('Dados históricos', () {
    final bras = historicalCompetitions
        .firstWhere((c) => c.id == 'brasileirao');

    test('4 títulos do Brasileirão', () {
      expect(bras.summary['titulos'], '4');
    });

    test('contagem de temporadas listadas', () {
      expect(bras.seasons!.length, greaterThanOrEqualTo(17));
    });

    test('temporada 2026 não inventada (vazia/ausente de dados)', () {
      // A base só contém temporadas verificadas até 2025.
      final has2026 = bras.seasons!.any((s) => s.year == 2026);
      expect(has2026, isFalse);
    });

    test('Copa do Brasil: 3 finais e título em 2011', () {
      final copa = historicalCompetitions
          .firstWhere((c) => c.id == 'copa_brasil');
      expect(copa.finals!.length, 3);
      expect(copa.finals!.firstWhere((f) => f.year == 2011).champion, isTrue);
    });

    test('resumo acumulado soma temporadas', () {
      final total = summarizeSeasons(bras.seasons);
      expect(total, isNotNull);
      expect(total!.played, greaterThan(0));
      expect(total.goalsFor, greaterThan(0));
      expect(total.aproveitamento, isNotNull);
    });
  });
}
