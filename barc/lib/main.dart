import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/routing/app_router.dart';
import 'src/features/settings/data/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BarcApp()));
}

class BarcApp extends ConsumerWidget {
  const BarcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wait for SharedPreferences to load
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    if (prefsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return MaterialApp.router(
      title: 'BARC',
      theme: AppTheme.whatsappLight(settings.fontFamily),
      darkTheme: AppTheme.whatsappDark(settings.fontFamily),
      themeMode: settings.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child!,
        );
      },
    );
  }
}
