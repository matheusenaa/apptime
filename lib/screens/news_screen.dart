import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../data/club_facts.dart';

/// Tela de notícias/fatos do clube.
///
/// Apresenta uma linha do tempo de fatos verificados do Vasco. Não inventa
/// conteúdo: cada item traz categoria, ano e fonte pública.
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Fatos do Clube')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clubFacts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Linha do tempo com fatos históricos e conquistas do Club de '
                'Regatas Vasco da Gama. Cada item é verificado e possui fonte.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            );
          }
          final fact = clubFacts[index - 1];
          return _FactCard(fact: fact);
        },
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  final ClubFact fact;
  const _FactCard({required this.fact});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppConstants.vascoRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    fact.year,
                    style: const TextStyle(
                      color: AppConstants.vascoRed,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fact.categoria.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              fact.titulo,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              fact.descricao,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.source,
                    size: 13, color: scheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text(
                  'Fonte: ${fact.fonte}',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
