import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/add_existing_file_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/add_source_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/delete_source_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/get_chapter_sources_usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

part 'sources_event.dart';
part 'sources_state.dart';
part 'sources_bloc.freezed.dart';

/// The source material of one chapter.
///
/// This listens to the local store instead of fetching, so a source appears the
/// moment it is written - with its "waiting to upload" badge - and that badge
/// turns into a progress bar and then a tick without anything being reloaded.
class SourcesBloc extends Bloc<SourcesEvent, SourcesState> {
  SourcesBloc({
    required this.chapter,
    required this.watchSources,
    required this.addSource,
    required this.addExistingFile,
    required this.deleteSource,
    required this.retryUpload,
  }) : super(const SourcesState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
    on<_FileAdded>(_onFileAdded);
    on<_RecordingAdded>(_onRecordingAdded);
    on<_Deleted>(_onDeleted);
    on<_UploadRetried>(_onUploadRetried);
  }

  final Chapter chapter;
  final WatchChapterSourcesUsecase watchSources;
  final AddSourceUsecase addSource;
  final AddExistingFileUsecase addExistingFile;
  final DeleteSourceUsecase deleteSource;
  final RetryUploadUsecase retryUpload;

  StreamSubscription<List<ChapterSource>>? _subscription;

  Future<void> _onStarted(_Started event, Emitter<SourcesState> emit) async {
    emit(const SourcesState.loading());

    await _subscription?.cancel();
    
    // Emit initial documents before subscribing to changes
    try {
      final List<ChapterSource> initialItems = await watchSources(chapter.id).first;
      _publish(emit, initialItems);
    } catch (error) {
      if (!emit.isDone) {
        emit(SourcesState.error('Sources could not be read from this device.'));
      }
      return;
    }

    // Now subscribe to future changes
    _subscription = watchSources(chapter.id).listen(
      (List<ChapterSource> items) {
        if (!emit.isDone) {
          _publish(emit, items);
        }
      },
      onError: (Object error) {
        if (!emit.isDone) {
          emit(SourcesState.error('Sources could not be read from this device.'));
        }
      },
    );
  }

  Future<void> _onRefreshed(_Refreshed event, Emitter<SourcesState> emit) async {
    final List<ChapterSource> items = await watchSources(chapter.id).first;
    _publish(emit, items);
  }

  Future<void> _onFileAdded(_FileAdded event, Emitter<SourcesState> emit) async {
    await _mutate(
      emit,
      () => addSource(
        AddSourceParams(
          file: event.file,
          chapter: chapter,
          displayName: event.displayName,
        ),
      ),
      success: 'Saved on this device. It will upload automatically.',
    );
  }

  Future<void> _onRecordingAdded(
    _RecordingAdded event,
    Emitter<SourcesState> emit,
  ) async {
    await _mutate(
      emit,
      () => addExistingFile(
        AddExistingFileParams(
          localPath: event.localPath,
          chapter: chapter,
          sourceType: SourceType.recording,
        ),
      ),
      success: 'Recording saved on this device.',
    );
  }

  Future<void> _onDeleted(_Deleted event, Emitter<SourcesState> emit) async {
    await _mutate(
      emit,
      () => deleteSource(
        DeleteSourceParams(sourceId: event.sourceId, chapterId: chapter.id),
      ),
      success: 'Source removed.',
    );
  }

  Future<void> _onUploadRetried(
    _UploadRetried event,
    Emitter<SourcesState> emit,
  ) async {
    await _mutate(
      emit,
      () => retryUpload(event.sourceId),
      success: 'Queued for another upload attempt.',
    );
  }

  /// Runs one write, then reports it. The list itself comes from the local
  /// store, so it never flashes empty while this runs.
  Future<void> _mutate(
    Emitter<SourcesState> emit,
    Future<Either<AppException, Object?>> Function() action, {
    required String success,
  }) async {
    final SourcesState before = state;

    if (before is _Loaded) {
      emit(before.copyWith(isBusy: true, message: null));
    }

    final Either<AppException, Object?> result = await action();
    final String message = result.fold(
      (AppException error) => error.message,
      (_) => success,
    );

    // The store will also push the new list through the subscription; reading
    // it here as well keeps the state correct even if that is delayed.
    final List<ChapterSource> items = await watchSources(chapter.id).first;

    emit(SourcesState.loaded(
      sources: items,
      isBusy: false,
      message: message,
    ));
  }

  /// Emits a new list while preserving the busy flag and any pending message.
  void _publish(Emitter<SourcesState> emit, List<ChapterSource> items) {
    // Check if emit is done before emitting
    if (emit.isDone) return;
    
    final bool isBusy = state.maybeWhen(
      loaded: (List<ChapterSource> _, bool isBusy, String? __) => isBusy,
      orElse: () => false,
    );

    emit(SourcesState.loaded(sources: items, isBusy: isBusy));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
