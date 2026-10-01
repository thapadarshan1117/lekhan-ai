# Phase 1 Specification — AI Processing Status UI

**Status**: Ready to implement  
**Duration**: 18 hours (1 week)  
**Priority**: 🔴 **CRITICAL BLOCKER**  
**Owner**: Senior Flutter Architect

---

## Overview

Implement real-time UI display for AI processing pipeline status. When a source is uploaded, show live updates as it moves through transcription → speaker identification → ingestion stages.

**Success criteria**: User adds source file → after upload completes, UI shows processing progress that updates every 5 seconds without user action → when complete, shows checkmark and link to transcript.

---

## Requirements

### FR-AI-05: Show per-source processing progress in the UI

**Current state**: 
- `ChapterSource` entity has `processingStatus` field
- No UI displays it
- No polling mechanism fetches updates

**After Phase 1**:
- Badge shows current step with icon
- Progress widget shows 4-step breakdown
- Polling fetches status every 5 seconds
- UI updates automatically
- Offline: shows last known status (no spinner)

### FR-AI-06: Notify the user when processing completes

**Current state**: 
- `awesome_notifications` configured
- No notification triggers on processing complete

**After Phase 1** (optional, can defer):
- When processing completes, fire local notification
- Notification says "Transcript ready: [source name]"
- Tap notification → show transcript/processing details

---

## Design

### Component Hierarchy

```
ChapterDetailPage
└─ SourcesList
   └─ SourceTile (existing)
      ├─ [File icon] + name + size
      ├─ UploadStatus badge (existing)
      └─ NEW: ProcessingStatusBadge
         ├─ Icon (hourglass, spinner, checkmark, X)
         ├─ Text (status name + step number)
         └─ Progress bar (if in progress)
         
Optional expanded view:
└─ ProcessingProgressWidget (on tap)
   ├─ Step 1: Upload        ✅ 100%
   ├─ Step 2: Transcribe    ⏳ 45%
   ├─ Step 3: Diarize       ⏜ 0%
   └─ Step 4: Ingest        ⏜ 0%
```

### State Flow

```
sourceId added to SourcesBloc
         ↓
    Initial state: processingStatus = notStarted
         ↓
    ProcessingStatusCubit created for this source
         ↓
    Start polling (if processingStatus.isRunning)
         ↓
    Fetch every 5 seconds: GET /sources/{id}
         ↓
    Parse response.processingStatus
         ↓
    Emit new state (UI updates badge)
         ↓
    Check if terminal (completed or failed)
         ↓
    If terminal: stop polling, show checkmark or error
         ↓
    Optional: fire notification
```

### UI Mockup

```
┌─────────────────────────────────────┐
│ Chapter Detail: My Chapter          │
├─────────────────────────────────────┤
│ Word count: 250/1000                │
├─────────────────────────────────────┤
│ SOURCES (1)                         │
│                                     │
│ 📄 Interview.mp3    [2.3 MB]       │
│ Upload: ✅ Uploaded                 │
│ Processing: ⏳ Transcribing (2/4)  │  ← NEW badge
│ [████░░░░░░░░░░░] 30%             │  ← NEW progress bar
│                                     │
│ ⋮ (more sources)                    │
│                                     │
├─────────────────────────────────────┤
│ [+] Add source    [  ...  ]         │
└─────────────────────────────────────┘
```

---

## Implementation Plan

### Step 1: Create Domain Layer (4 hours)

**File**: `lib/features/source_content/domain/usecases/get_source_detail_usecase.dart`

```dart
// Domain usecase to fetch a single source with latest status
class GetSourceDetailUsecase {
  final SourceRepository _repository;
  
  GetSourceDetailUsecase({required SourceRepository repository})
    : _repository = repository;

  Future<Either<AppException, ChapterSource>> call(String sourceId) async {
    return _repository.getSourceDetail(sourceId);
  }
}
```

**File**: `lib/features/source_content/data/repositories/source_repository_impl.dart`

**Modify**: Add method to fetch single source:

```dart
Future<Either<AppException, ChapterSource>> getSourceDetail(String sourceId) async {
  try {
    final response = await _remoteDataSource.getSource(sourceId);
    final source = ChapterSourceModel.fromJson(response).toDomain();
    
    // Cache locally
    await _localDataSource.saveSource(ChapterSourceModel.fromDomain(source));
    
    return Right(source);
  } catch (e) {
    // Return cached version if offline
    final cached = await _localDataSource.getSource(sourceId);
    if (cached != null) return Right(cached.toDomain());
    
    return Left(AppException(message: 'Could not fetch source: $e'));
  }
}
```

**File**: `lib/features/source_content/domain/repositories/source_repository.dart`

**Add** abstract method:

```dart
Future<Either<AppException, ChapterSource>> getSourceDetail(String sourceId);
```

### Step 2: Create Data Layer (6 hours)

**File**: `lib/features/source_content/data/datasources/source_remote_datasource.dart`

**Add** method to fetch single source:

```dart
Future<Map<String, dynamic>> getSource(String sourceId) async {
  final response = await _networkService.get(
    '/sources/$sourceId',
  );
  return response.data as Map<String, dynamic>;
}
```

**Test**: Mock response should return:
```json
{
  "id": "src_123",
  "name": "Interview.mp3",
  "uploadStatus": "uploaded",
  "processingStatus": "transcribing",
  "uploadProgress": 100,
  "fileSize": 2400000,
  ...
}
```

### Step 3: Create Presentation Layer (8 hours)

#### 3a. ProcessingStatusCubit

**File**: `lib/features/source_content/presentation/bloc/processing_status_cubit.dart`

```dart
part 'processing_status_state.dart';

class ProcessingStatusCubit extends Cubit<ProcessingStatusState> {
  ProcessingStatusCubit({
    required GetSourceDetailUsecase getSourceDetail,
  })  : _getSourceDetail = getSourceDetail,
        super(const ProcessingStatusState.initial());

  final GetSourceDetailUsecase _getSourceDetail;
  Timer? _pollTimer;

  Future<void> startPolling(String sourceId) async {
    // Initial fetch
    await _fetch(sourceId);

    // Only start polling if not terminal
    if (state.maybeWhen(
      loaded: (source) => source.processingStatus.isRunning,
      orElse: () => false,
    )) {
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _fetch(sourceId);
      });
    }
  }

  Future<void> _fetch(String sourceId) async {
    final result = await _getSourceDetail(sourceId);
    
    result.fold(
      (error) => emit(ProcessingStatusState.error(error.message)),
      (source) {
        emit(ProcessingStatusState.loaded(source));
        
        // Stop polling if terminal
        if (source.processingStatus.isTerminal && _pollTimer != null) {
          _pollTimer!.cancel();
          _pollTimer = null;
        }
      },
    );
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    await super.close();
  }
}
```

**File**: `lib/features/source_content/presentation/bloc/processing_status_state.dart`

```dart
part of 'processing_status_cubit.dart';

@freezed
class ProcessingStatusState with _$ProcessingStatusState {
  const factory ProcessingStatusState.initial() = _Initial;
  const factory ProcessingStatusState.loading() = _Loading;
  const factory ProcessingStatusState.loaded(ChapterSource source) = _Loaded;
  const factory ProcessingStatusState.error(String message) = _Error;
}
```

#### 3b. ProcessingStatusBadge Widget

**File**: `lib/features/source_content/presentation/widgets/processing_status_badge.dart`

```dart
class ProcessingStatusBadge extends StatelessWidget {
  const ProcessingStatusBadge({
    super.key,
    required this.processingStatus,
    required this.uploadProgress,
  });

  final ProcessingStatus processingStatus;
  final double uploadProgress;

  String get _stepLabel {
    switch (processingStatus) {
      case ProcessingStatus.notStarted:
        return 'Not started';
      case ProcessingStatus.queued:
        return 'Queued';
      case ProcessingStatus.transcribing:
        return 'Transcribing (2/4)';
      case ProcessingStatus.diarizing:
        return 'Identifying speakers (3/4)';
      case ProcessingStatus.ingesting:
        return 'Ingesting (4/4)';
      case ProcessingStatus.completed:
        return 'Processing complete';
      case ProcessingStatus.failed:
        return 'Processing failed';
    }
  }

  IconData get _icon {
    switch (processingStatus) {
      case ProcessingStatus.notStarted:
        return Icons.schedule;
      case ProcessingStatus.queued:
      case ProcessingStatus.transcribing:
      case ProcessingStatus.diarizing:
      case ProcessingStatus.ingesting:
        return Icons.hourglass_bottom;
      case ProcessingStatus.completed:
        return Icons.check_circle;
      case ProcessingStatus.failed:
        return Icons.error;
    }
  }

  Color get _color {
    switch (processingStatus) {
      case ProcessingStatus.notStarted:
      case ProcessingStatus.queued:
        return AppColors.textSecondary;
      case ProcessingStatus.transcribing:
      case ProcessingStatus.diarizing:
      case ProcessingStatus.ingesting:
        return AppColors.primary;
      case ProcessingStatus.completed:
        return AppColors.success;
      case ProcessingStatus.failed:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(_icon, size: 16, color: _color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processing: $_stepLabel',
                  style: TextStyle(
                    fontSize: 12,
                    color: _color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (processingStatus.isRunning) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: uploadProgress / 100,
                      minHeight: 3,
                      backgroundColor: _color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 3c. Modify SourceTile

**File**: `lib/features/source_content/presentation/widgets/source_tile.dart`

**Current**: Displays only `uploadStatus`  
**Add**: Display `processingStatus` below upload badge

```dart
// In SourceTile build method, after upload badge:

BlocProvider(
  create: (_) => ProcessingStatusCubit(
    getSourceDetail: sl<GetSourceDetailUsecase>(),
  )..startPolling(source.id),
  child: BlocBuilder<ProcessingStatusCubit, ProcessingStatusState>(
    builder: (context, state) {
      return state.maybeWhen(
        loaded: (updatedSource) => ProcessingStatusBadge(
          processingStatus: updatedSource.processingStatus,
          uploadProgress: updatedSource.uploadProgress.toDouble(),
        ),
        error: (_) => const SizedBox.shrink(),  // Don't show if error
        orElse: () => const SizedBox.shrink(),
      );
    },
  ),
),
```

#### 3d. Optional: ProcessingProgressWidget

**File**: `lib/features/source_content/presentation/widgets/processing_progress_widget.dart`

Show expanded view when user taps badge (future enhancement):

```dart
class ProcessingProgressWidget extends StatelessWidget {
  const ProcessingProgressWidget({required this.source});

  final ChapterSource source;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Step(
          number: 1,
          label: 'Upload',
          completed: source.uploadStatus == UploadStatus.uploaded,
          progress: source.uploadStatus == UploadStatus.uploaded ? 1.0 : 0.0,
        ),
        _Step(
          number: 2,
          label: 'Transcribe',
          completed: source.processingStatus.index >= ProcessingStatus.transcribing.index,
          inProgress: source.processingStatus == ProcessingStatus.transcribing,
          progress: source.processingStatus == ProcessingStatus.transcribing ? 0.45 : 1.0,
        ),
        _Step(
          number: 3,
          label: 'Identify speakers',
          completed: source.processingStatus.index >= ProcessingStatus.diarizing.index,
          inProgress: source.processingStatus == ProcessingStatus.diarizing,
        ),
        _Step(
          number: 4,
          label: 'Ingest',
          completed: source.processingStatus == ProcessingStatus.completed,
          inProgress: source.processingStatus == ProcessingStatus.ingesting,
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    this.completed = false,
    this.inProgress = false,
    this.progress = 0.0,
  });

  final int number;
  final String label;
  final bool completed;
  final bool inProgress;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? AppColors.success : AppColors.outline,
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text('$number', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (inProgress)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(value: progress),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Dependency Injection (1 hour)

**File**: `lib/core/config/dependency_injection/di_config.dart`

**Add**:

```dart
// Usecases
getIt.registerSingleton(
  GetSourceDetailUsecase(
    repository: getIt<SourceRepository>(),
  ),
);

// Cubits (scoped per source)
// Don't register globally; create per-source in SourceTile via BlocProvider
```

### Step 5: Testing (5 hours)

#### Unit Tests

**File**: `test/features/source_content/presentation/bloc/processing_status_cubit_test.dart`

```dart
void main() {
  group('ProcessingStatusCubit', () {
    late MockGetSourceDetailUsecase mockGetSourceDetail;
    late ProcessingStatusCubit cubit;

    setUp(() {
      mockGetSourceDetail = MockGetSourceDetailUsecase();
      cubit = ProcessingStatusCubit(getSourceDetail: mockGetSourceDetail);
    });

    test('emits [loading, loaded] when startPolling succeeds', () async {
      final source = ChapterSource(...);
      when(mockGetSourceDetail(any))
          .thenAnswer((_) async => Right(source));

      expect(
        cubit.stream,
        emitsInOrder([
          isA<ProcessingStatusState>(),  // initial
          isA<ProcessingStatusState>(),  // loaded
        ]),
      );

      await cubit.startPolling('src_123');
    });

    test('stops polling when processing completes', () async {
      final source = ChapterSource(
        ...
        processingStatus: ProcessingStatus.completed,
      );
      when(mockGetSourceDetail(any))
          .thenAnswer((_) async => Right(source));

      await cubit.startPolling('src_123');
      await Future.delayed(Duration(milliseconds: 100));

      expect(cubit.state, isA<ProcessingStatusState>());
      // Verify no more emissions after ~6 seconds
      await expectLater(cubit.stream, emitsDone, skip: 1);
    });
  });
}
```

#### Widget Tests

**File**: `test/features/source_content/presentation/widgets/processing_status_badge_test.dart`

```dart
void main() {
  group('ProcessingStatusBadge', () {
    testWidgets('displays transcribing icon and text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProcessingStatusBadge(
              processingStatus: ProcessingStatus.transcribing,
              uploadProgress: 45,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.hourglass_bottom), findsOneWidget);
      expect(find.byText('Transcribing (2/4)'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows checkmark when completed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProcessingStatusBadge(
              processingStatus: ProcessingStatus.completed,
              uploadProgress: 100,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
```

---

## Acceptance Criteria

### Before marking Phase 1 complete, verify:

- [ ] **User adds source file** → badge shows "Upload: ✅ Uploaded"
- [ ] **Backend processes file** → after 5s, badge changes to "Processing: ⏳ Transcribing"
- [ ] **Badge updates every 5s** → no user action required
- [ ] **All 4 steps display correctly**:
  - Transcribing (2/4)
  - Identifying speakers / Diarizing (3/4)
  - Ingesting (4/4)
  - Completed ✓
- [ ] **Failed processing shows error**:
  - Badge displays "Processing failed"
  - Icon is red X
  - Error message visible (optional in this phase)
- [ ] **Offline behavior**:
  - Before connection → shows last known status (no spinner)
  - After connection restored → resume polling
- [ ] **Widget tests pass** (>80% coverage for new widgets)
- [ ] **No memory leaks** → polling stops after navigation away

---

## API Contract

**Endpoint**: `GET /sources/{sourceId}`

**Response**:
```json
{
  "id": "src_28662fabb6084e66",
  "chapterId": "chp_4d4bf34fe40d453c",
  "name": "Interview.mp3",
  "uploadStatus": "uploaded",
  "processingStatus": "transcribing",
  "uploadProgress": 100,
  "fileSize": 2400000,
  "createdAt": "2026-10-01T09:33:00Z",
  "updatedAt": "2026-10-01T09:33:30Z"
}
```

**Status values**: `"not_started" | "queued" | "transcribing" | "diarizing" | "ingesting" | "completed" | "failed"`

---

## Files Summary

**New files** (3):
- `lib/features/source_content/presentation/bloc/processing_status_cubit.dart`
- `lib/features/source_content/presentation/widgets/processing_status_badge.dart`
- `lib/features/source_content/domain/usecases/get_source_detail_usecase.dart`

**Modified files** (3):
- `lib/features/source_content/presentation/widgets/source_tile.dart` (add badge)
- `lib/features/source_content/data/repositories/source_repository.dart` (add method)
- `lib/core/config/dependency_injection/di_config.dart` (register usecase)

**Optional files** (1):
- `lib/features/source_content/presentation/widgets/processing_progress_widget.dart` (Phase 1.5)

**Test files** (2):
- `test/features/source_content/presentation/bloc/processing_status_cubit_test.dart`
- `test/features/source_content/presentation/widgets/processing_status_badge_test.dart`

---

## Timeline

| Day | Task | Duration |
|-----|------|----------|
| 1 | Design + Setup | 2h |
| 1–2 | Domain layer (usecase) | 4h |
| 2–3 | Data layer (fetch method) | 6h |
| 3–4 | Presentation (cubit + widgets) | 8h |
| 5 | Testing + DI registration | 5h |
| 5–6 | Integration testing + fixes | 3h |
| **TOTAL** | | **18h** |

---

## Success Definition

✅ **Feature is production-ready when:**
1. User sees processing progress update live without manual refresh
2. All 4 pipeline steps display correctly
3. Polling stops after processing completes or fails
4. No memory leaks or excessive battery drain
5. Works offline (shows cached status)
6. Widget tests pass with >80% coverage
7. No crashes or unhandled exceptions

