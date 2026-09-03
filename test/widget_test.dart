import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_time_vasco/core/theme/app_theme.dart';
import 'package:app_time_vasco/screens/shell.dart';
import 'package:app_time_vasco/state/app_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App carrega em modo demonstração sem erros', (tester) async {
    final state = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const Shell(),
        ),
      ),
    );
    await tester.pump();

    // Identidade + indicador de demonstração aparecem.
    expect(find.text('APP TIME VASCO'), findsOneWidget);
    expect(find.text('MODO DEMONSTRAÇÃO'), findsWidgets);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Jogos'), findsOneWidget);

    // Encerra o polling iniciado pelo Shell.
    state.dispose();
  });
}
