import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sheet_sync_service.dart';
import '../../core/database/db_seeder.dart';
import 'isar_provider.dart';
import 'training_providers.dart';

final sheetSyncServiceProvider = FutureProvider<SheetSyncService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return SheetSyncService(isar);
});

// Sync state notifier
class SyncState {
  final bool isSyncing;
  final SyncResult? lastResult;
  final String? statusMessage;

  const SyncState({this.isSyncing = false, this.lastResult, this.statusMessage});

  SyncState copyWith({bool? isSyncing, SyncResult? lastResult, String? statusMessage}) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastResult: lastResult ?? this.lastResult,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref _ref;

  SyncNotifier(this._ref) : super(const SyncState());

  Future<void> syncIfNeeded() async {
    if (state.isSyncing) return;
    try {
      final isar = await _ref.read(isarProvider.future);
      await DbSeeder(isar).seedIfNeeded();
    } catch (_) {}
  }

  Future<void> forceSync() async {
    if (state.isSyncing) return;
    try {
      state = state.copyWith(isSyncing: true, statusMessage: 'Loading local database...');
      final isar = await _ref.read(isarProvider.future);
      await DbSeeder(isar).seedIfNeeded(force: true);
      state = state.copyWith(
        isSyncing: false,
        statusMessage: '✓ 320 questions loaded',
        lastResult: SyncResult.success(320),
      );
      _ref.invalidate(totalQuestionsProvider);
      _ref.invalidate(topicsProvider);
      _ref.invalidate(statsProvider);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        statusMessage: '✗ Loading failed: $e',
        lastResult: SyncResult.error(e.toString()),
      );
    }
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});
