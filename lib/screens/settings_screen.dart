import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_config.dart';
import '../state/app_state.dart';

/// Tela de configurações: tema e chave da API-Football.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hasKey = ApiConfig.hasApiKey;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel('APARÊNCIA'),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: state.themeMode,
              onChanged: (v) {
                if (v != null) state.setThemeMode(v);
              },
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('Sistema'),
                    subtitle: Text('Segue o tema do dispositivo'),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Claro'),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Escuro'),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('DADOS (API-FOOTBALL)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasKey ? Icons.check_circle : Icons.info_outline,
                        color: hasKey ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasKey ? 'Chave configurada' : 'Modo demonstração ativo',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasKey
                        ? 'O app está conectado à API-Football e exibirá dados '
                            'reais. A chave está guardada no arquivo .env local.'
                        : 'Para ativar dados reais: crie uma conta gratuita em '
                            'api-football.com, copie sua chave e adicione ao '
                            'arquivo .env (APIFOOTBALL_KEY=...). A chave nunca é '
                            'enviada para o repositório.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'A chave é lida do arquivo .env. Edite o arquivo '
                                'e reinicie o app.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.key, size: 16),
                        label: const Text('Como configurar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.read<AppState>().refreshAll(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Atualizar dados'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('COTA DIÁRIA'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Limite do plano Free'),
              subtitle: const Text('100 requisições por dia'),
              trailing: const Icon(Icons.info_outline, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: scheme.secondary,
        ),
      ),
    );
  }
}
