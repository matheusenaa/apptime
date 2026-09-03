import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../models/match.dart';
import '../core/constants/app_constants.dart';

/// Cartão de uma partida do Vasco.
class MatchCard extends StatelessWidget {
  final Match match;
  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Competição + status
            Row(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 15, color: scheme.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    match.competition.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                _StatusChip(match: match),
              ],
            ),
            const SizedBox(height: 12),
            // Times e placar
            Row(
              children: [
                const SizedBox(width: 36),
                Expanded(
                  child: _TeamLabel(
                    name: match.homeTeam,
                    isVasco: match.isVascoHome,
                  ),
                ),
                _Score(match: match),
                Expanded(
                  child: _TeamLabel(
                    name: match.awayTeam,
                    isVasco: match.isVascoHome == false,
                    alignEnd: true,
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
            if (match.venue.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.stadium_outlined,
                      size: 13, color: scheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      match.venue,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (match.date != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 13, color: scheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.dataHora(match.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamLabel extends StatelessWidget {
  final String name;
  final bool isVasco;
  final bool alignEnd;
  const _TeamLabel({
    required this.name,
    required this.isVasco,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name.toUpperCase(),
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isVasco ? FontWeight.w900 : FontWeight.w600,
            color: isVasco ? AppConstants.vascoRed : scheme.onSurface,
            height: 1.15,
          ),
        ),
        if (isVasco)
          Text(
            'VASCO',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }
}

class _Score extends StatelessWidget {
  final Match match;
  const _Score({required this.match});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (match.isScheduled) {
      return Column(
        children: [
          Text(
            'VS',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              match.homeGoals.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: match.isVascoHome ? AppConstants.vascoRed : scheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Text('x',
                style: TextStyle(
                    fontSize: 16, color: scheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(width: 6),
            Text(
              match.awayGoals.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: !match.isVascoHome ? AppConstants.vascoRed : scheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Match match;
  const _StatusChip({required this.match});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    if (match.isLive) {
      bg = AppConstants.vascoRed;
      fg = Colors.white;
    } else if (match.isFinished) {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    } else {
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (match.isLive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            match.statusLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
