# Implementation Gap Analysis — Lekhan AI SRS vs. Codebase

**Date**: October 1, 2026  
**Analysis Scope**: Functional & non-functional requirements NOT yet implemented  
**Baseline**: `main` @ `f12a682` (post-bug-fixes)

---

## Executive Summary

The Lekhan AI app has **excellent offline sync infrastructure** (FR-SYNC complete) but is **missing critical user-facing features**:

| Category | Status | Gap |
|----------|--------|-----|
| **Offline Sync Engine** | ✅ Complete | 0% — production-ready |
| **AI Chat Assistant** | ❌ Missing | 100% — zero implementation |
| **AI Processing Pipeline UI** | ⚠️ Partial | Infrastructure exists, UI missing |
| **Chapter Text Editor** | ❌ Missing | 100% — only metadata form exists |
| **Sync Centre UI** | ✅ Core done | 95% — needs bulk operations |
| **Local Notifications** | ✅ Complete | 0% — ready to use |
| **Processing Status UI** | ❌ Missing | 100% — no real-time updates or WebSocket |

**Critical blocker**: FR-SYNC-15 is **implemented and working**, but no AI features are present.

---

## 1. CRITICAL MISSING: AI Chat Assistant (FR-CHAT-01/02/03)

**Severity**: 🔴 **HIGH** — blocks key user workflow  
**Scope**: **100% unimplemented**  
**Estimated effort**: 40–60 hours (new feature from scratch)

### What's Missing

#### Domain Layer
- [ ] `ChatSession` entity — stores conversation metadata
- [ ] `ChatMessage` entity — stores individual messages (user vs. assistant)
- [ ] `GetOrCreateSessionUsecase` — fetch or create a chat session
- [ ] `SendMessageUsecase` — send message and handle response
- [ ] `ListSessionsUsecase` — load conversation history
- [ ] `PinSessionUsecase` / `UnpinSessionUsecase` — pin favorite conversations

#### Data Layer
- [ ] `ChatSessionRemoteDataSource` — API client for `/chatbot/*` endpoints
- [ ] `ChatSessionLocalDataSource` — Hive storage for offline access
- [ ] `ChatSessionRepository` — coordinate remote + local
- [ ] Models: `ChatSessionModel`, `ChatMessageModel` with JSON serialization

#### Presentation Layer
- [ ] `chat_screen.dart` — main conversation UI
- [ ] `ChatBloc` / `ChatCubit` — state management for conversations
- [ ] `ChatMessage` widget — render user/assistant messages with styling
- [ ] `ChatInput` widget — text input with send button
- [ ] `SessionList` widget — recent conversations sidebar
- [ ] Message streaming UI — handle real-time assistant responses

#### Backend Integration
- [ ] Endpoint: `POST /chatbot/message` — send single message
- [ ] Endpoint: `POST /chatbot/message/stream` — streaming response (SSE/WebSocket)
- [ ] Endpoint: `POST /chatbot/start` — create new conversation
- [ ] Endpoint: `GET /chatbot/sessions` — list user's conversations
- [ ] Endpoint: `GET /chatbot/sessions/pinned` — starred conversations

### References in Code

Current state:
- **No** `lib/features/ai_chat/` folder
- **No** chat usecases, datasources, or models
- **Placeholder tab** in bottom navigation but no actual chat screen
- API endpoints **defined but never called** in `api_constants.dart`

### Acceptance Criteria (from SRS §7.4)

- [ ] User opens chat from main navigation
- [ ] User types a message and taps send
- [ ] Message appears in conversation immediately (optimistic UI)
- [ ] Assistant response streams in real-time
- [ ] Conversation persists across app restarts
- [ ] Can pin/unpin important conversations
- [ ] Works offline (cached messages only; new messages queue for sync)

---

## 2. IMPORTANT MISSING: AI Processing Pipeline UI (FR-AI-05/06)

**Severity**: 🟠 **MEDIUM** — affects source material workflow  
**Scope**: **Data model exists, UI completely missing**  
**Estimated effort**: 20–30 hours

### What Exists ✅

```dart
// lib/core/enums/processing_status.dart
enum ProcessingStatus {
  notStarted, queued, transcribing, diarizing, ingesting, completed, failed
}

// ChapterSource tracks this
processingStatus: ProcessingStatus = ProcessingStatus.notStarted
```

### What's Missing ❌

#### Presentation Layer

- [ ] **ProcessingStatusBadge** widget — display current step with icon/color
  ```
  Example: ⏳ Transcribing (Step 2/4)
  ```

- [ ] **ProcessingProgressWidget** — show multi-step progress
  ```
  Step 1: Upload      ✅ Complete
  Step 2: Transcribe  ⏳ In progress (45% complete)
  Step 3: Diarize     ⏜ Waiting
  Step 4: Ingest      ⏜ Waiting
  ```

- [ ] **Source tile enhancement** — replace static upload status with dual-status view
  ```
  Before:  [📄 Interview.mp4]  Upload: ✅ Uploaded
  After:   [📄 Interview.mp4]  Upload: ✅ Uploaded | Processing: ⏳ Transcribing
  ```

- [ ] **Real-time update mechanism** — fetch status periodically or via WebSocket
  - Poll `/sources/:id` every 5 seconds while processing
  - Or: Implement WebSocket listener for push updates

#### Data Layer

- [ ] **GetSourceDetailUsecase** — fetch single source with latest processing status
- [ ] **PollProcessingStatusUsecase** — background polling task
- [ ] **ProcessingStatusRepository** — abstract status queries

#### Backend Integration

- [ ] Add endpoint call: `GET /sources/:id` to fetch `processingStatus`
- [ ] Implement polling: start when `processingStatus.isRunning == true`
- [ ] Stop polling when: `processingStatus.isTerminal == true`

### References in Code

- **Exists**: `ChapterSource.processingStatus` field in entity
- **Missing**: No UI representation anywhere
- **Missing**: No polling or real-time update mechanism

### Acceptance Criteria

- [ ] User adds source → after upload completes, sees "Processing…" badge
- [ ] UI shows current pipeline step (transcribing, diarizing, ingesting)
- [ ] Status updates every 5 seconds without user action
- [ ] When complete, badge shows checkmark and transcript/summary available
- [ ] When failed, badge shows error and retry option
- [ ] Notification fires when processing completes (integrates with FR-NOTF-06)

---

## 3. MISSING: Chapter Text Editor (FR-CHAP-06)

**Severity**: 🟠 **MEDIUM** — needed for actual book writing  
**Scope**: **100% unimplemented**  
**Estimated effort**: 30–50 hours (depends on feature scope)

### Current State

**Chapter form page** (`chapter_form_page.dart`) only allows editing:
- Chapter number
- Title
- Summary
- Target word count
- Status

**No chapter body/content field exists.**

### Design Question ⚠️

**From SRS §9 (Open Questions):**
> "AI output shape — does ingestion produce draft chapter text, an outline, or a research digest?"

**Current assumption**: The app is **source-first, not text-first**. Authors:
1. Record interviews / upload documents
2. AI transcribes and ingests into a draft
3. Author reads/refines the auto-generated text

**If true**: Chapter text editor should allow editing AI-generated drafts, not blank entry.

### What Would Be Needed (if implementing)

#### Domain Layer
- [ ] `ChapterContent` entity (or extend `Chapter` model)
  ```dart
  {
    chapterId: String,
    content: String,        // Raw text
    draftVersion: int,      // Track versions
    lastEditedAt: DateTime,
    isDraft: bool,          // Source-generated vs. user-written
    ...
  }
  ```

- [ ] `UpdateChapterContentUsecase` — save edited text, queue sync task

#### Presentation Layer
- [ ] `ChapterEditorScreen` — replace or extend `ChapterFormPage`
- [ ] **Rich text editor widget** (must pick library):
  - **quill_flutter** — feature-rich, actively maintained
  - **zefyrka** — simpler, offline-first
  - **flutter_markdown** — read-only (not suitable)

- [ ] Formatting toolbar (bold, italic, lists, headings, links)
- [ ] Auto-save to local Hive box every 3 seconds (debounced)
- [ ] Show "unsaved changes" indicator
- [ ] Conflict resolution UI (if edited locally while server changes came in)

#### Data Layer
- [ ] Extend `ChapterModel` with `content` field
- [ ] Add to Hive schema: `Box<ChapterModel>`
- [ ] Create sync task: `SyncOperation.updateChapterContent`

#### Storage & Sync
- [ ] Mark chapter `isDirty` on edit
- [ ] Queue sync task (P0 priority) to push changes
- [ ] Conflict resolution: **local unsent edits always win** (per NFR-MAINT-18)

### Acceptance Criteria

- [ ] User opens chapter detail
- [ ] Taps "Edit content" → rich text editor opens with existing content
- [ ] Types/formats text
- [ ] Taps "Save" → auto-saves to local DB
- [ ] Offline: changes queue without network
- [ ] Online: changes sync automatically
- [ ] If conflict: local version wins; show toast "You had unsent changes, they were kept"

---

## 4. PARTIAL: Sync Centre UI (FR-SYNC-12)

**Severity**: 🟢 **LOW** — nice-to-have enhancement  
**Scope**: **80% implemented, 20% polish**  
**Estimated effort**: 5–10 hours

### What Exists ✅

`lib/features/sync/presentation/pages/sync_centre_page.dart`:

```dart
✅ Displays pending sync tasks
✅ Displays failed tasks with error messages
✅ Shows attempt count and next retry time
✅ Per-item retry button: _retryOne(taskId)
✅ Per-item discard button: _cancelOne(taskId)
✅ Displays upload progress percentage
✅ Shows "last synced at" timestamp
✅ Handles "needs attention" (3+ consecutive failures)
```

### What's Missing ❌

- [ ] **Bulk retry all** — current UI has `_retryAll()` but UX not clear
- [ ] **Bulk discard/cancel failed** — select multiple → discard in batch
- [ ] **Filter by type** — show only upload failures vs. metadata failures
- [ ] **Live updates** — currently static; need BLoC to poll for status changes
- [ ] **Better error copy** — distinguish between user-fixable errors:
  - "File is 600MB (limit: 500MB)" → **User fix**: delete file
  - "Network timeout" → **System fix**: retry when connection stable
  - "Authentication failed" → **User fix**: re-login

### References in Code

- `sync_status_cubit.dart` — state management exists
- `get_sync_status_usecase.dart` — loads current queue state
- `retry_sync_usecase.dart` — implements retry logic

### Quick Wins

Add to `sync_centre_page.dart`:
1. **Checkbox multiselect** on failed items
2. **Bulk retry** button that calls `_retryOne(taskId)` for each selected
3. **Bulk discard** button that calls `_cancelOne(taskId)` for each selected
4. **Tab view**: Pending | Failed | Completed (archive)
5. **Pull-to-refresh** to reload queue status

---

## 5. COMPLETE: Offline Sync Engine (FR-SYNC-15)

**Severity**: ✅ **COMPLETE**  
**Status**: **Production-ready**

### Infrastructure (All Implemented ✅)

```
lib/core/sync/
├── sync_manager.dart           # Main orchestrator
├── sync_queue.dart             # Local queue management
├── sync_task.dart              # Task serialization
├── sync_task_builder.dart      # Builder pattern for tasks
├── sync_worker.dart            # Parallel execution (configurable workers)
├── sync_state.dart             # Preferences & state tracking
├── background_sync_scheduler.dart  # workmanager integration
├── sync_bootstrap.dart         # Boot-up initialization
├── request_bus.dart            # Sync coordination pub/sub
├── conflict_resolver.dart      # Conflict resolution logic
└── ... (more)
```

### Features Implemented ✅

| Feature | Status | Details |
|---------|--------|---------|
| **Offline write** | ✅ | Write to local DB without network; queue for sync |
| **Resumable uploads** | ✅ | 4 MB chunks, Content-Range headers, persisted offset |
| **Exponential backoff** | ✅ | 20s × 2ⁿ⁻¹, capped 1h, max 5 attempts |
| **Conflict resolution** | ✅ | Local unsent edits always win |
| **Priority ordering** | ✅ | P0 (metadata) → P1 (audio) → P4 (video) |
| **Background sync** | ✅ | workmanager integration, periodic + one-off |
| **Network state tracking** | ✅ | Monitors connectivity changes |
| **Deferred large files** | ✅ | Metered connections: ≥25 MB waits for WiFi |
| **Constraint enforcement** | ✅ | WiFi-only, charging-only options |
| **Session recovery** | ✅ | Resumes after app crash (`resetStuck`) |
| **Idempotent operations** | ✅ | Duplicate detection by (entityId, operation) |
| **Stop on 3 failures** | ✅ | Surfaces "needs attention" state |

### What's NOT Missing

Nothing critical. The sync engine is complete and production-grade.

---

## 6. COMPLETE: Local Notifications (FR-NOTF-06)

**Severity**: ✅ **COMPLETE**  
**Status**: **Ready to use**

### Implementation ✅

```dart
lib/main.dart:
  ✅ awesome_notifications package initialized
  ✅ Notification channels created with sound/vibration/lights
  ✅ Foreground & background handlers registered
  ✅ Firebase Cloud Messaging integrated

lib/features/notifications/:
  ✅ NotificationScreen (list, filtering, mark as read)
  ✅ NotificationController (tap handlers)
  ✅ Local notification factory (for sync events)
```

### Ready to Extend

To add **sync completion notifications** (FR-NOTF-06), simply:

```dart
// After sync completes in SyncManager
await AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: DateTime.now().hashCode,
    channelKey: 'basic_channel',
    title: 'Sync Complete',
    body: '5 items uploaded successfully',
    category: NotificationCategory.Progress,
  ),
);
```

---

## Implementation Priority & Timeline

### Phase 1: Infrastructure Foundation (Week 1–2)

**Goal**: Unblock AI features and text editing  
**Effort**: 20 hours

- [ ] **Implement real-time processing status updates** (FR-AI-05)
  - Add polling/WebSocket listener to fetch source status every 5 seconds
  - Create `ProcessingStatusBloc` to manage live updates
  - Add `ProcessingProgressWidget` to display multi-step progress
  - **Why first**: Required by both chat and source handling; unblocks UI patterns

**Acceptance**: Processing UI updates live as source moves through pipeline.

---

### Phase 2: Chat Assistant MVP (Week 2–4)

**Goal**: Implement conversational AI feature  
**Effort**: 50 hours

**Deliverables**:
- [ ] Chat feature module (`lib/features/ai_chat/`)
- [ ] `ChatSession` + `ChatMessage` domain entities
- [ ] `ChatSessionRepository` + `ChatMessageRepository`
- [ ] `ChatBloc` for state management
- [ ] `ChatScreen` with message list + input field
- [ ] Streaming response handler (if backend supports SSE/WebSocket)
- [ ] Local persistence for conversation history
- [ ] Integration with main nav (AI tab)

**Testing**: Can send message → receive response → persist across app restart.

---

### Phase 3: Chapter Editor (Week 4–6)

**Goal**: Enable authoring capability  
**Effort**: 40 hours

**Deliverables**:
- [ ] Decide on rich text editor library (recommend: `quill_flutter`)
- [ ] `ChapterContent` domain entity
- [ ] Extend chapter persistence layer
- [ ] `ChapterEditorScreen` with formatting toolbar
- [ ] Auto-save (debounced to Hive)
- [ ] Sync integration (queue `updateChapterContent` tasks)

**Testing**: Edit chapter → save offline → come online → sync successful.

---

### Phase 4: Polish & Testing (Week 6–8)

**Goal**: Production readiness  
**Effort**: 30 hours

- [ ] Add bulk operations to sync centre UI (FR-SYNC-12)
- [ ] Sync completion/failure notifications (FR-NOTF-06)
- [ ] Error message improvements in sync centre
- [ ] Widget and integration tests (currently ~0% coverage)
- [ ] E2E acceptance scenario testing (§7 from SRS)

---

## Effort Estimates

| Feature | Domain | Data | Presentation | Total | Priority |
|---------|--------|------|--------------|-------|----------|
| Processing status UI | 4h | 6h | 8h | **18h** | 🔴 HIGH |
| AI chat assistant | 10h | 15h | 20h | **45h** | 🔴 HIGH |
| Chapter text editor | 8h | 12h | 20h | **40h** | 🟠 MEDIUM |
| Sync centre enhancements | — | — | 8h | **8h** | 🟢 LOW |
| **Total** | | | | **111 hours** | |

**Timeline**: 6–8 weeks with 1 FTE dedicated

---

## Architecture Decisions Needed

Before implementation, confirm with product owner:

### 1. Chapter Text Editor (FR-CHAP-06)

**Question**: Is manual chapter writing in scope?

**Option A** (source-first, current assumption):
- Chapter text is **auto-generated from sources** by AI
- Editor lets authors **refine the draft**
- Primary flow: Record interview → AI transcribes → Author edits

**Option B** (text-first):
- Authors write chapters **directly** in the editor
- Sources are reference material only
- Primary flow: Outline → Author writes → Attach sources as backup

**Recommendation**: Option A aligns with current codebase. Confirm before implementing.

### 2. Chat Assistant (FR-CHAT-01)

**Question**: What context should the assistant have?

**Option A** (read-only):
- Assistant can see **project title + current book**
- Cannot modify anything
- Use case: "Suggest a title for chapter 3"

**Option B** (read-write):
- Assistant can **read & modify chapter text**
- Can edit outlines, suggest structure
- Requires edit permission layer

**Recommendation**: Start with Option A (safer). Extend to B in Phase 2.

### 3. Processing Status Updates (FR-AI-05)

**Question**: Push (WebSocket) or pull (polling)?

**Option A** (polling):
- Client calls `GET /sources/:id` every 5 seconds
- Simple to implement
- Works with any backend
- 5% more battery drain

**Option B** (WebSocket push):
- Backend notifies client when step changes
- Real-time, efficient
- Requires backend support
- Complex state management

**Recommendation**: Start with polling (Option A). Implement in <1 day. Migrate to WebSocket later if performance needed.

---

## Risk Mitigation

### Risk 1: Backend API Not Ready
**Severity**: 🔴 HIGH  
**Mitigation**: 
- Design mock API responses now
- Implement in-memory stubs for chat/processing endpoints
- Test offline flow independently

### Risk 2: Real-time Update Performance
**Severity**: 🟠 MEDIUM  
**Mitigation**:
- Start with 5-second polling (cheap)
- Monitor battery/data impact
- Implement WebSocket only if needed

### Risk 3: Text Editor Library Fragility
**Severity**: 🟠 MEDIUM  
**Mitigation**:
- Evaluate `quill_flutter` before committing
- Have fallback: simple `TextField` (no formatting) if issues arise
- Don't ship rich editing if unstable

### Risk 4: Schema Migration (Chat/Content)
**Severity**: 🟢 LOW  
**Mitigation**:
- Hive versioning already in place (`schemaVersion`)
- Add migration logic to `AppDatabase` constructor
- Test with real data before release

---

## Non-Blocking Gaps (Lower Priority)

These are "nice to have" and don't block core functionality:

- [ ] **Draft versioning** (FR-CHAP-07) — entity model exists, UI not needed yet
- [ ] **Parallel uploads** (FR-UPL-13) — single upload per file works; parallelism can wait
- [ ] **Push sync pull** (FR-SYNC-17) — users can pull-to-refresh manually
- [ ] **Live sync centre updates** (FR-SYNC-20) — can implement after chat MVP
- [ ] **Dark mode** (FR-UI-08) — low priority UX polish

---

## Verification Steps

Before marking complete, verify:

```bash
# 1. Processing UI updates in real-time
flutter run
# → Add source → Wait for processing badge to animate through stages

# 2. Chat works offline
# → Send message offline → UI shows "queued" → Come online → Message sends

# 3. Chapter edit persists across restart
# → Edit chapter → Force kill app (adb shell am kill)
# → Restart → Content still there

# 4. Sync centre shows failures
# → Break network → Try to sync → See error in sync centre
# → Retry → Should work when network restored
```

---

## Next Steps

1. **Confirm architecture decisions** (§10 above) with product owner
2. **Create feature specs** for each phase in `.kiro/specs/`
3. **Start Phase 1**: Processing status UI (lowest hanging fruit, unblocks others)
4. **Set up mock API** for chat/processing endpoints
5. **Schedule weekly reviews** to validate against SRS acceptance criteria (§7)

