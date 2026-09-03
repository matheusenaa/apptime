import 'package:flutter/material.dart';

/// Banner de estado offline: informa que os dados podem estar desatualizados.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.35),
        border: Border.all(color: scheme.error.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off, color: scheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sem conexão. Exibindo as informações atualizadas pela última vez.',
              style: TextStyle(color: scheme.onSurface, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
