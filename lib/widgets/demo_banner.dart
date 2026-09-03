import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Banner exibido quando o app está em MODO DEMONSTRAÇÃO (sem chave de API).
///
/// Deixa claro ao usuário que os dados são de demonstração — nunca engana
/// apresentando dados simulados como se fossem reais.
class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark
                ? AppConstants.vascoRed
                : AppConstants.crossOfMaltaRed)
            .withValues(alpha: 0.12),
        border: Border.all(
          color: AppConstants.vascoRed.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined,
                  color: AppConstants.vascoRed, size: 18),
              const SizedBox(width: 8),
              Text(
                'MODO DEMONSTRAÇÃO',
                style: TextStyle(
                  color: AppConstants.vascoRed,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Sem chave de API configurada. Os dados de jogos e '
            'classificação não são carregados. Configure sua chave da '
            'API-Football em Configurações para ativar dados reais.',
            style: TextStyle(color: scheme.onSurface, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
