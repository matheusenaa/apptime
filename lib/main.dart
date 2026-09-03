import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'screens/shell.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tenta carregar o .env (chave da API). Se ausente (ex.: release sem o
  // arquivo), segue em modo demonstração ou usa a chave via --dart-define.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env não disponível neste build — sem chave local é tratado com segurança.
  }

  final state = AppState();
  // Pré-carrega o tema antes do primeiro frame (evita "flash" de tema).
  await state.loadTheme();

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const AppTimeVascoApp(),
    ),
  );
}

class AppTimeVascoApp extends StatelessWidget {
  const AppTimeVascoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'App Time Vasco',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.themeMode,
          home: const Shell(),
        );
      },
    );
  }
}
