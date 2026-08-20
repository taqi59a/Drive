import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/db_seeder.dart';
import 'shared/providers/isar_provider.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  final container = ProviderContainer();
  final isar = await container.read(isarProvider.future);
  await DbSeeder(isar).seedIfNeeded();

  // Background sync from Google Sheet disabled to prevent overwriting Belgian offline data
  /*
  Future.microtask(() async {
    try {
      final syncService = SheetSyncService(isar);
      final result = await syncService.syncIfNeeded();
      debugPrint('[SheetSync] $result');
    } catch (e) {
      debugPrint('[SheetSync] Error: $e');
    }
  });
  */

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DriveBetterApp(),
    ),
  );
}
