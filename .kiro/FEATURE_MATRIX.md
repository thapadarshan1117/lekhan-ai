# Feature Implementation Matrix — Lekhan AI

## Overview: What's Done vs. What's Missing

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     LEKHAN AI FEATURE COMPLETION MATRIX                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  FOUNDATION & INFRASTRUCTURE                                                │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  ✅ Authentication & Account (FR-AUTH, FR-ACCT)                     [100%]  │
│     └─ Login, signup, OTP, password reset, profile, JWT refresh            │
│                                                                              │
│  ✅ Offline Sync Engine (FR-SYNC-15)                               [100%]  │
│     └─ Local queue, resumable uploads, conflict resolution, backoff       │
│                                                                              │
│  ✅ Local Notifications (FR-NOTF-06)                               [100%]  │
│     └─ Push notifications, notification list, mark as read                │
│                                                                              │
│  ────────────────────────────────────────────────────────────────────────   │
│                                                                              │
│  CORE WRITING STRUCTURE                                                     │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  ✅ Projects (FR-PROJ)                                              [100%]  │
│     └─ Create, list, edit, delete (with sync)                            │
│                                                                              │
│  ✅ Books (FR-BOOK)                                                 [100%]  │
│     └─ Create, list, edit; word count progress                            │
│                                                                              │
│  ✅ Chapters (FR-CHAP) — Metadata                                  [80%]   │
│     ├─ Create, list, edit metadata                                        │
│     ├─ Chapter numbering, status, word progress                           │
│     ├─ Show source counts                                                 │
│     ❌ FR-CHAP-06: Chapter text editor (MISSING — 0%)                     │
│     └─ FR-CHAP-07: Draft versioning (planned, not needed yet)             │
│                                                                              │
│  ────────────────────────────────────────────────────────────────────────   │
│                                                                              │
│  SOURCE MATERIAL CAPTURE                                                    │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  ✅ File Upload (FR-SRC)                                            [100%]  │
│     └─ Pick files → detect type → copy to chapter folder                 │
│                                                                              │
│  ✅ Voice Recording (FR-REC)                                        [100%]  │
│     └─ Microphone permission, record, save to recordings/ folder         │
│                                                                              │
│  ✅ Upload Engine (FR-UPL)                                          [100%]  │
│     └─ 4MB chunks, Content-Range, resumable, checksum, session mgmt     │
│                                                                              │
│  ⚠️  Processing Status (FR-AI-05/06) — Infrastructure              [50%]   │
│     ├─ ✅ ProcessingStatus enum (queued, transcribing, ingesting)        │
│     ├─ ✅ ChapterSource tracks processingStatus                          │
│     ❌ Processing status polling (MISSING — 0%)                          │
│     ❌ Processing progress UI (MISSING — 0%)                            │
│     └─ ❌ Real-time status updates (MISSING — 0%)                        │
│                                                                              │
│  ────────────────────────────────────────────────────────────────────────   │
│                                                                              │
│  SYNC & QUEUE MANAGEMENT                                                    │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  ✅ Sync Queue (FR-SYNC-01 to FR-SYNC-11)                          [100%]  │
│     └─ Persist work, trigger on network/background, order by priority   │
│                                                                              │
│  ✅ Sync Centre (FR-SYNC-12) — Core                                [80%]   │
│     ├─ Show pending & failed items                                       │
│     ├─ Per-item retry & discard buttons                                  │
│     ├─ Error messages & attempt counts                                   │
│     ❌ Bulk operations (retry/discard multiple) — MISSING                │
│     ❌ Filter by type (upload vs. metadata) — MISSING                    │
│     └─ ❌ Live updates — MISSING (currently static)                      │
│                                                                              │
│  ✅ Background Sync (FR-SYNC-15)                                   [100%]  │
│     └─ workmanager integration, periodic + one-off tasks                 │
│                                                                              │
│  ✅ Conflict Resolution (FR-SYNC-18)                               [100%]  │
│     └─ Local unsent edits always win                                     │
│                                                                              │
│  ────────────────────────────────────────────────────────────────────────   │
│                                                                              │
│  AI FEATURES (NEW)                                                          │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  ❌ AI Chat Assistant (FR-CHAT-01/02/03)                           [0%]    │
│     ├─ No domain entities (ChatSession, ChatMessage)                     │
│     ├─ No data layer (remote API, local persistence)                    │
│     ├─ No presentation (ChatScreen, ChatBloc)                           │
│     ├─ No backend integration (POST /chatbot/message)                   │
│     └─ BLOCKER: Core product feature, needed for MVP                   │
│                                                                              │
│  ❌ Processing Pipeline UI (FR-AI-05/06)                           [0%]    │
│     ├─ No status polling mechanism                                       │
│     ├─ No processing progress widget                                     │
│     ├─ No real-time UI updates                                          │
│     └─ BLOCKER: Source material experience incomplete                   │
│                                                                              │
│  ────────────────────────────────────────────────────────────────────────   │
│                                                                              │
│  AUTHOR EXPERIENCE                                                          │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  ✅ Offline Indicator (NFR-USE-01)                                 [100%]  │
│     └─ Sync centre shows queued work explicitly                         │
│                                                                              │
│  ✅ "Waiting to Upload" State (NFR-USE-02)                         [100%]  │
│     └─ Shown as normal operation, not error                             │
│                                                                              │
│  ✅ UI Honesty (NFR-USE-03)                                        [100%]  │
│     └─ Copy says "syncs when connection available"                      │
│                                                                              │
│  ✅ Error Transparency (NFR-USE-04)                                [100%]  │
│     └─ Sync centre shows cause & offers retry                           │
│                                                                              │
│  ✅ Destructive Action Confirmation (NFR-USE-05)                  [100%]  │
│     └─ Delete asks for confirmation                                     │
│                                                                              │
│  ✅ Recording One-Tap Access (NFR-USE-06)                          [100%]  │
│     └─ From chapter detail → add source → record                        │
│                                                                              │
│  ✅ Theming & Localisation (FR-UI-03 to FR-UI-06)                 [100%]  │
│     └─ Custom themes, custom fields, text scaling, English UI           │
│                                                                              │
│  ❌ Dark Mode (FR-UI-08)                                            [0%]    │
│     └─ Not implemented (low priority)                                    │
│                                                                              │
│  ────────────────────────────────────────────────────────────────────────   │
│                                                                              │
│  PRODUCT CLEANUP                                                            │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  ❌ Remove Legacy Booking UI (FR-LEGACY)                           [0%]    │
│     ├─ Home marketplace, service categories, pro listings               │
│     ├─ Booking routes, rate-and-review flows                            │
│     ├─ Khalti payment integration                                        │
│     ├─ Address & favourites screens                                      │
│     └─ Stale API base URLs, vatsalaya_app references                    │
│                                                                              │
│  ============================════════════════════════════════════════════   │
│                                                                              │
│  FEATURE COUNTS                                                             │
│  ────────────────                                                           │
│                                                                              │
│  ✅ Implemented: 22 features                                              │
│  ⚠️  Partial: 2 features (Processing status, Sync centre)                │
│  ❌ Missing: 4 features (Chat, Processing UI, Chapter editor, Dark mode)  │
│  🔧 Legacy to remove: 8 items                                            │
│                                                                              │
│                                                                              │
│  TOTAL PROGRESS: 73% (complete) | 8% (partial) | 19% (missing/low priority)│
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Critical Path to MVP

```
TODAY
  │
  ├─ Phase 1: Processing Status UI (18h)
  │  └─ Processing badge + polling → DONE
  │
  ├─ Phase 2: Chat MVP (45h)
  │  ├─ Domain entities & usecases
  │  ├─ Local persistence
  │  ├─ Remote API integration
  │  └─ ChatScreen UI → DONE
  │
  ├─ Phase 3: Chapter Editor (40h) — OPTIONAL
  │  └─ Rich text editor + auto-save → DONE
  │
  └─ Phase 4: Polish (30h)
     ├─ Sync centre bulk ops
     ├─ Error UX improvements
     ├─ E2E testing
     └─ Ready for Beta → GO LIVE


Total: ~135 hours (4–5 weeks @ 1 FTE)
Critical path (blockers only): ~65 hours (2 weeks)
```

---

## Feature Dependencies

```
Authentication ✅
    │
    ├─→ Projects/Books/Chapters ✅
    │
    ├─→ Source Upload ✅
    │   │
    │   ├─→ Processing Status UI ❌ (PHASE 1)
    │   │
    │   └─→ Sync Engine ✅
    │
    ├─→ Chat Assistant ❌ (PHASE 2)
    │   └─ Depends on: Processing UI for context
    │
    └─→ Chapter Editor ❌ (PHASE 3)
        └─ Depends on: Sync Engine (already done)


Nothing blocks Phase 1 start.
Phase 2 depends on Phase 1.
Phase 3 can start anytime (independent).
```

---

## Effort Breakdown by Layer

| Layer | Domain | Data | Presentation | Total |
|-------|--------|------|--------------|-------|
| **Processing Status** | 4h | 6h | 8h | 18h |
| **Chat** | 10h | 15h | 20h | 45h |
| **Chapter Editor** | 8h | 12h | 20h | 40h |
| **Sync Polish** | — | — | 8h | 8h |
| **Testing & fixes** | 5h | 5h | 12h | 22h |
| **TOTAL** | **27h** | **38h** | **68h** | **133h** |

---

## Definition of Done (per feature)

### Processing Status ✅
- [ ] Badge displays correct step
- [ ] Polling fetches every 5s when processing
- [ ] Status updates in real-time
- [ ] Works offline (shows last known)
- [ ] Stops polling when terminal
- [ ] Widget tests pass

### Chat ✅
- [ ] Send message → response appears
- [ ] Conversation persists
- [ ] Works offline (queues message)
- [ ] Can list/pin sessions
- [ ] Streaming responses (if backend supports)
- [ ] Integration tests pass

### Chapter Editor ✅
- [ ] Edit chapter text
- [ ] Auto-saves every 3 seconds
- [ ] Survives app kill/restart
- [ ] Syncs to backend
- [ ] Offline changes merge correctly
- [ ] E2E test passes

---

## Success Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Offline write success rate | 100% | ✅ 100% |
| Sync queue recovery (after app kill) | 100% | ✅ 100% |
| Chat message delivery | 100% | ❌ N/A (not built) |
| Processing status latency | <5s | ❌ N/A (not built) |
| App startup time | <2s | ⚠️ Unknown |
| Widget test coverage | >50% | ❌ ~5% |
| E2E scenario pass rate | 100% | ⚠️ Untested |

---

## Risk & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Backend API not ready | 🔴 HIGH | Build mock API now |
| Chat streaming complex | 🟠 MEDIUM | Start with polling, add streaming later |
| Text editor instability | 🟠 MEDIUM | Evaluate `quill_flutter` early; fallback to plain text |
| Schema migration bugs | 🟢 LOW | Test Hive migration with real data |
| Performance degradation | 🟠 MEDIUM | Profile before/after each phase |

---

## Next Immediate Actions

1. **This week**: Review & confirm Phase 1 design
2. **Next week**: Start Processing Status implementation
3. **Week 3**: Begin Chat domain layer (in parallel)
4. **Week 4**: Integrate Chat with UI
5. **Week 5**: Chapter Editor design decision + kickoff
6. **Week 6+**: Polish & testing

