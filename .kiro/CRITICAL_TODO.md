# 🚀 Critical TODOs — Lekhan AI Implementation Roadmap

## Status Overview

| Feature | SRS ID | Status | Blocker | Effort |
|---------|--------|--------|---------|--------|
| **Processing status UI** | FR-AI-05/06 | ❌ MISSING | Yes | 18h |
| **AI Chat** | FR-CHAT-01/02/03 | ❌ MISSING | Yes | 45h |
| **Chapter editor** | FR-CHAP-06 | ❌ MISSING | No | 40h |
| **Sync centre UI** | FR-SYNC-12 | ✅ 80% | No | 8h |
| **Sync engine** | FR-SYNC-15 | ✅ DONE | No | 0h |
| **Local notifications** | FR-NOTF-06 | ✅ DONE | No | 0h |

---

## 🔴 HIGHEST PRIORITY: Processing Status UI (18 hours)

**Why**: Unblocks both chat and source handling patterns. Lowest effort, highest value.

### What to Build

1. **ProcessingStatusBadge widget** — Shows current step
   ```
   File.mp4
   Upload: ✅ Uploaded
   Processing: ⏳ Transcribing (Step 2/4)
   ```

2. **ProcessingProgressWidget** — Multi-step breakdown
   ```
   □ Step 1: Upload              ✅
   □ Step 2: Transcribe          ⏳ 45%
   □ Step 3: Speaker separation  ⏜
   □ Step 4: Ingest              ⏜
   ```

3. **Real-time status polling** — Fetch every 5s while processing
   - Create `ProcessingStatusPoller` service
   - Poll `GET /sources/:id` when `processingStatus.isRunning`
   - Stop when `processingStatus.isTerminal`

4. **Live updates in UI** — Use BLoC to push updates
   - Create `ProcessingStatusCubit` to manage polling
   - Emit new state when status changes
   - UI reacts automatically

### Files to Create

```
lib/features/source_content/presentation/
├── widgets/
│   ├── processing_status_badge.dart      # NEW: Status display
│   ├── processing_progress_widget.dart   # NEW: Multi-step UI
│   └── source_tile.dart                  # MODIFY: Add processing display
├── bloc/
│   └── processing_status_cubit.dart      # NEW: Polling state machine
└── ...

lib/features/source_content/domain/
├── usecases/
│   └── get_source_detail_usecase.dart    # NEW: Fetch with status
└── ...
```

### Tests to Pass

- [ ] Badge shows correct step (transcribing, diarizing, ingesting, etc.)
- [ ] Progress updates every 5 seconds without user action
- [ ] Stops polling when complete/failed
- [ ] Offline: shows last known status (no spinner)
- [ ] Error state shows reason and retry button

### Implementation Steps

1. Add `GetSourceDetailUsecase` (calls `GET /sources/:id`)
2. Create `ProcessingStatusCubit` with polling timer
3. Add widgets to `source_tile.dart`
4. Test with mock API responses
5. Integrate with existing `SourcesBloc`

**Estimated time**: 18 hours (3 days)

---

## 🔴 HIGH PRIORITY: AI Chat Assistant (45 hours)

**Why**: Core product feature. Needed before public beta.

### Phased Approach

**Week 1**: MVP (basic chat works)
**Week 2**: Polish (streaming, persistence, pinning)

### Week 1 — Core Chat (30 hours)

**Domain layer**:
- [ ] `ChatSession` entity (id, title, createdAt, pinned)
- [ ] `ChatMessage` entity (id, sessionId, role, content, createdAt)
- [ ] `SendMessageUsecase` (takes message, returns Either<AppException, ChatMessage>)
- [ ] `ListSessionsUsecase`
- [ ] `CreateSessionUsecase`

**Data layer**:
- [ ] `ChatSessionLocalDataSource` (Hive box)
- [ ] `ChatMessageLocalDataSource` (Hive box)
- [ ] `ChatSessionRemoteDataSource` (API calls)
- [ ] `ChatSessionRepository`

**Presentation**:
- [ ] `ChatBloc` (manages message list & send action)
- [ ] `ChatScreen` (layout: messages + input bar)
- [ ] `ChatMessage` widget (user vs assistant styling)
- [ ] `ChatInput` widget (text field + send button)

**Backend**:
- [ ] Call `POST /chatbot/message`
- [ ] Store response in local box
- [ ] Handle offline: queue message for later send

**Acceptance**: Send message → see response → message persists

**Estimated time**: 30 hours (1 week)

### Week 2 — Streaming & UX (15 hours)

- [ ] Streaming responses from `POST /chatbot/message/stream`
- [ ] Session list & pinning UI
- [ ] Sync integration (queue messages offline)
- [ ] Notification when assistant responds
- [ ] Polish animations

**Estimated time**: 15 hours (3 days)

### Files to Create

```
lib/features/ai_chat/
├── domain/
│   ├── entities/
│   │   ├── chat_session.dart
│   │   └── chat_message.dart
│   ├── repositories/
│   │   └── chat_session_repository.dart
│   └── usecases/
│       ├── send_message_usecase.dart
│       ├── list_sessions_usecase.dart
│       ├── create_session_usecase.dart
│       └── pin_session_usecase.dart
├── data/
│   ├── datasources/
│   │   ├── chat_session_local_datasource.dart
│   │   ├── chat_message_local_datasource.dart
│   │   └── chat_session_remote_datasource.dart
│   ├── models/
│   │   ├── chat_session_model.dart
│   │   └── chat_message_model.dart
│   └── repositories/
│       └── chat_session_repository_impl.dart
└── presentation/
    ├── bloc/
    │   └── chat_bloc.dart
    ├── pages/
    │   └── chat_screen.dart
    └── widgets/
        ├── chat_message_widget.dart
        ├── chat_input_widget.dart
        └── session_list_widget.dart
```

---

## 🟠 MEDIUM PRIORITY: Chapter Text Editor (40 hours)

**Why**: Needed for authoring, but can follow chat MVP.

### Decision Required First

**Question**: Is manual chapter writing in scope?

- **Option A** (recommended): Authors edit **AI-generated text** only
- **Option B**: Authors write **from scratch**

**Assume Option A** for now. Modify if product owner specifies B.

### Implementation (Option A: Edit AI-generated)

**Domain**:
- [ ] `ChapterContent` value object (content, draftVersion, lastEditedAt)
- [ ] Extend `Chapter` entity to include content
- [ ] `UpdateChapterContentUsecase`

**Data**:
- [ ] Extend `ChapterModel` with `content` field
- [ ] Update Hive schema (version bump)
- [ ] Create migration: empty content → empty string for old chapters

**Presentation**:
- [ ] Extend `chapter_form_page.dart` OR create separate `chapter_editor_screen.dart`
- [ ] Add rich text editor (use `quill_flutter` package)
- [ ] Auto-save (debounced, every 3 seconds)
- [ ] "Unsaved changes" indicator
- [ ] Sync integration: mark chapter isDirty, queue P0 sync task

**Sync**:
- [ ] New `SyncOperation.updateChapterContent`
- [ ] Push to `POST /chapters/:id` with content field
- [ ] Conflict resolution: local wins (existing rule)

**Acceptance**:
- [ ] Edit chapter → changes auto-save
- [ ] Force quit → restart → content persists
- [ ] Offline edit → come online → content syncs

**Estimated time**: 40 hours (1 week with full-time)

---

## 🟢 LOW PRIORITY: Sync Centre Enhancements (8 hours)

**Why**: Nice to have. Core sync centre already works.

### Quick Wins

- [ ] Add **multiselect checkboxes** to failed items
- [ ] Add **bulk retry** button
- [ ] Add **bulk discard** button
- [ ] Add **tab view**: Pending | Failed | Completed
- [ ] Add **pull-to-refresh**

**Files to Modify**:
- `lib/features/sync/presentation/pages/sync_centre_page.dart`

**Estimated time**: 8 hours (1 day)

---

## ✅ ALREADY COMPLETE (No Action Needed)

### Offline Sync Engine (FR-SYNC-15) ✅

**Status**: Production-ready  
**What exists**: 
- ✅ Full offline support
- ✅ Resumable uploads (4 MB chunks)
- ✅ Conflict resolution (local wins)
- ✅ Background sync (workmanager)
- ✅ Priority queue (P0–P4)
- ✅ Exponential backoff + 5 retries
- ✅ Network constraint enforcement (WiFi-only, etc.)

**Nothing to do**.

### Local Notifications (FR-NOTF-06) ✅

**Status**: Implemented  
**What exists**:
- ✅ `awesome_notifications` configured
- ✅ Firebase Cloud Messaging integrated
- ✅ Notification list screen
- ✅ Mark as read
- ✅ Handlers for tap events

**To extend** (optional):
- Sync completion notification (one-liner in SyncManager.dart)
- Processing complete notification (one-liner in ProcessingPoller)

---

## 📋 Implementation Checklist

### Phase 1: Processing Status (Week 1)
- [ ] Design `ProcessingStatusCubit` state machine
- [ ] Implement polling logic (5s interval)
- [ ] Create badge & progress widgets
- [ ] Add to source tile
- [ ] Test with mock API
- [ ] Integrate with real backend

### Phase 2: Chat MVP (Weeks 2–3)
- [ ] Domain entities & usecases
- [ ] Local persistence (Hive)
- [ ] Remote API integration
- [ ] ChatBloc state management
- [ ] ChatScreen UI
- [ ] Test offline message queuing
- [ ] Nav integration (AI tab)

### Phase 3: Chapter Editor (Weeks 4–5)
- [ ] Decision: edit existing or write from scratch
- [ ] Domain layer (ChapterContent entity)
- [ ] Data layer (Hive + API)
- [ ] Editor UI with formatting
- [ ] Auto-save mechanism
- [ ] Sync task integration
- [ ] Conflict resolution

### Phase 4: Polish (Weeks 6–8)
- [ ] Sync centre bulk operations
- [ ] Sync notifications
- [ ] Error message improvements
- [ ] E2E testing (SRS §7 scenarios)
- [ ] Performance tuning
- [ ] Widget tests (aim for >50% coverage)

---

## 🎯 Acceptance Scenarios (from SRS §7)

Before marking done, verify these pass:

### Offline Scenario ✅ (Already works)
```
1. Airplane mode on
2. Create project → book → chapter
3. Record 2-min voice note
✓ File appears in app storage
✓ Shows "waiting to upload"
✓ No error dialogs
5. Force quit & restart
✓ Everything still present
6. Enable connectivity
✓ Sync auto-starts
✓ Processing starts
✓ File eventually reads "uploaded"
```

### Chat Scenario (New)
```
1. Tap AI tab
2. Type "Summarize chapter 1"
3. Send
✓ Message appears instantly (optimistic UI)
✓ Assistant response streams in
4. Force quit app
5. Restart
✓ Message thread persists
✓ Can continue conversation
```

### Chapter Editing Scenario (New)
```
1. Open chapter
2. Edit text
3. Tap save
✓ Auto-saves to local DB
4. Airplane mode
5. Tap edit again, change text
6. Enable connectivity
✓ All changes sync correctly
```

---

## 🔗 References

- **Full analysis**: `.kiro/IMPLEMENTATION_GAP_ANALYSIS.md`
- **SRS**: `SRS.md` (§3 functional, §4 non-functional requirements)
- **Architecture**: `Banao Architecture.md` (clean architecture rules)

---

## Questions for Product Owner

Before starting Phase 2/3, confirm:

1. **Chat scope**: Should assistant read/modify chapters, or read-only?
2. **Chapter editing**: Edit AI-generated text, or write from scratch?
3. **Processing display**: What granularity? (just step name, or include ETA?)
4. **Notifications**: Sound/vibration on chat reply? On sync failure?
5. **Offline duration**: How long must drafts survive without sync?

---

**Last updated**: 2026-10-01  
**Next review**: After Phase 1 completion  
**Owner**: Senior Flutter Architect
