import 'package:lekhan_ai/shared/custom_fields/domain/entities/custom_field_definition.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_module.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/repository/custom_fields_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomFieldsState {
  final CustomFieldModule module;
  final bool isLoading;
  final bool isRefreshing;
  final List<CustomFieldDefinition> fields;
  final AppException? error;

  const CustomFieldsState({
    required this.module,
    required this.isLoading,
    required this.isRefreshing,
    required this.fields,
    required this.error,
  });

  factory CustomFieldsState.initial(CustomFieldModule module) {
    return CustomFieldsState(
      module: module,
      isLoading: true,
      isRefreshing: false,
      fields: const [],
      error: null,
    );
  }

  CustomFieldsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<CustomFieldDefinition>? fields,
    AppException? error,
    bool clearError = false,
  }) {
    return CustomFieldsState(
      module: module,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      fields: fields ?? this.fields,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CustomFieldsCubit extends Cubit<CustomFieldsState> {
  final CustomFieldsRepository repository;

  CustomFieldsCubit({
    required this.repository,
    required CustomFieldModule module,
  }) : super(CustomFieldsState.initial(module));

  Future<void> load({
    Duration maxCacheAge = const Duration(hours: 6),
  }) async {
    // Cache-first
    final cached = await repository.getCachedFields(state.module);
    cached.fold(
      (_) {},
      (fields) {
        if (fields.isNotEmpty) {
          emit(state.copyWith(isLoading: false, fields: fields));
        }
      },
    );

    emit(
        state.copyWith(isRefreshing: true, clearError: true, isLoading: false));

    final res = await repository.getFields(
      module: state.module,
      forceRefresh: false,
      maxCacheAge: maxCacheAge,
    );

    res.fold(
      (e) => emit(state.copyWith(isRefreshing: false, error: e)),
      (fields) {
        if (_same(fields, state.fields)) {
          emit(state.copyWith(isRefreshing: false));
          return;
        }
        emit(state.copyWith(isRefreshing: false, fields: fields));
      },
    );
  }

  Future<void> forceRefresh() async {
    emit(
        state.copyWith(isRefreshing: true, clearError: true, isLoading: false));

    final res = await repository.getFields(
      module: state.module,
      forceRefresh: true,
      maxCacheAge: Duration.zero,
    );

    res.fold(
      (e) => emit(state.copyWith(isRefreshing: false, error: e)),
      (fields) => emit(state.copyWith(isRefreshing: false, fields: fields)),
    );
  }
}

bool _same(List<CustomFieldDefinition> a, List<CustomFieldDefinition> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
