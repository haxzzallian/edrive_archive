import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

final profileProvider = FutureProvider<ProfileEntity>((ref) async {
  final result = await getIt<GetProfileUseCase>()();
  return result.fold((f) => throw f.message, (p) => p);
});

class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  ProfileUpdateNotifier() : super(const AsyncData(null));

  Future<bool> update(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final result = await getIt<UpdateProfileUseCase>()(data);
    return result.fold(
      (f) { state = AsyncError(f.message, StackTrace.current); return false; },
      (_) { state = const AsyncData(null); return true; },
    );
  }
}

final profileUpdateProvider = StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<void>>(
  (_) => ProfileUpdateNotifier(),
);
