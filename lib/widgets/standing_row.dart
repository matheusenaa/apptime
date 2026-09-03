import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/standing.dart';

/// Linha da tabela de classificação.
class StandingRow extends StatelessWidget {
  final Standing standing;
  const StandingRow({super.key, required this.standing});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isVasco = standing.isVasco;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isVasco
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03))
            : scheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: isVasco
            ? Border.all(color: AppConstants.vascoRed, width: 1)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '${standing.position}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isVasco ? AppConstants.vascoRed : scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              standing.team,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isVasco ? FontWeight.w900 : FontWeight.w600,
                color: isVasco ? AppConstants.vascoRed : scheme.onSurface,
              ),
            ),
          ),
          _Cell(standing.played, isVasco),
          _Cell(standing.wins, isVasco),
          _Cell(standing.draws, isVasco),
          _Cell(standing.losses, isVasco),
          _Cell(standing.goalsFor, isVasco),
          _Cell(standing.goalDifference.toString(), isVasco),
          _Cell('${standing.points}', isVasco, strong: true),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isVasco;
  final bool strong;
  _Cell(Object value, this.isVasco, {this.strong = false})
      : text = value.toString();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 30,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: strong ? 13 : 12,
          fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
          color: isVasco
              ? AppConstants.vascoRed
              : (strong ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
