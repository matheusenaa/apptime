import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import 'history_screen.dart';
import 'news_screen.dart';
import 'settings_screen.dart';

/// Aba "Mais": acesso a Notícias, Configurações, Histórico e Sobre.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuTile(
          icon: Icons.newspaper_outlined,
          title: 'Notícias',
          subtitle: 'Fatos e conquistas do Gigante da Colina',
          onTap: () => _push(context, const NewsScreen()),
        ),
        _MenuTile(
          icon: Icons.timeline,
          title: 'Histórico',
          subtitle: 'Brasileirão e Copa do Brasil',
          onTap: () => _push(context, const HistoryScreen()),
        ),
        _MenuTile(
          icon: Icons.settings_outlined,
          title: 'Configurações',
          subtitle: 'Tema e chave da API-Football',
          onTap: () => _push(context, const SettingsScreen()),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.shield, color: AppConstants.vascoRed, size: 40),
              const SizedBox(height: 10),
              const Text(
                'SOU VASCO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nada a declarar',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Version 1.0.0 · Flutter · API-Football',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppConstants.vascoRed),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: scheme.onSurface.withValues(alpha: 0.4)),
        onTap: onTap,
      ),
    );
  }
}
