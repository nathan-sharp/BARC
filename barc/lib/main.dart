import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/routing/app_router.dart';

void main() {
  runApp(const ProviderScope(child: BarcApp()));
}

class BarcApp extends ConsumerWidget {
  const BarcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BARC',
      theme: AppTheme.retroDark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
