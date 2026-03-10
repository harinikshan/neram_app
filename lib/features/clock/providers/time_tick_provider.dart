import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/search_service.dart';
import '../../../data/repositories/preferences_repository.dart';

const int previewStepMinutes = 15;
const int previewMaxMinutes = 24 * 60;

/// Emits the current DateTime every second
final timeTickProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  ).asBroadcastStream();
});

/// User-adjustable preview offset in minutes (-24h to +24h).
final timePreviewOffsetMinutesProvider = StateProvider<int>((ref) => 0);

final timePreviewOffsetProvider = Provider<Duration>((ref) {
  final minutes = ref.watch(timePreviewOffsetMinutesProvider);
  return Duration(minutes: minutes);
});

final isPreviewModeProvider = Provider<bool>((ref) {
  return ref.watch(timePreviewOffsetMinutesProvider) != 0;
});

/// Frozen base time, captured when entering preview mode
final previewBaseTimeProvider = StateProvider<DateTime?>((ref) => null);

/// Effective time: frozen during preview, live otherwise
final effectiveTimeProvider = Provider<DateTime>((ref) {
  final isPreview = ref.watch(isPreviewModeProvider);
  if (isPreview) {
    return ref.watch(previewBaseTimeProvider) ?? DateTime.now();
  }
  return ref.watch(timeTickProvider).value ?? DateTime.now();
});

/// Singleton search service
final searchServiceProvider = Provider<SearchService>((ref) {
  final service = SearchService();
  service.initialize();
  return service;
});

/// Singleton preferences repository
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository();
});
