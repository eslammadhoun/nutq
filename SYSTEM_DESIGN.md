# System Design — Nutq Arabic Transcription Platform
**Version:** 1.0 | **Date:** 2026-08-06

---

## 1. Big Picture

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER DEVICES                              │
│                                                                  │
│   ┌──────────────────┐          ┌──────────────────┐            │
│   │  Flutter App     │          │  Postman / CLI   │            │
│   │  (iOS / Android) │          │  (API Keys)      │            │
│   └────────┬─────────┘          └────────┬─────────┘            │
└────────────┼────────────────────────────┼─────────────────────-─┘
             │  HTTPS / WSS               │  HTTPS
             ▼                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     NUTQ API  (FastAPI)                          │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐   │
│  │  Auth Router │  │  Jobs Router │  │  Storage Router     │   │
│  │  /auth/*     │  │  /jobs/*     │  │  /dev-storage/*     │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬──────────┘   │
│         │                 │                      │               │
│  ┌──────▼─────────────────▼──────────────────────▼──────────┐  │
│  │                   Domain Use Cases                         │  │
│  │   AuthService │ SubmitJob │ GetJob │ ListJobs │ CancelJob  │  │
│  └──────────────────────────┬───────────────────────────────┘   │
│                             │                                    │
│  ┌──────────────────────────▼───────────────────────────────┐   │
│  │              Infrastructure Layer                          │   │
│  │  SQLRepository │ WhisperBackend │ SummarizationBackend    │   │
│  └──────┬───────────────┬─────────────────┬──────────────────┘  │
└─────────┼───────────────┼─────────────────┼───────────────────-─┘
          │               │                 │
          ▼               ▼                 ▼
    ┌──────────┐   ┌─────────────┐   ┌─────────────┐
    │PostgreSQL│   │Whisper Model│   │  LLM API    │
    │(SQLite   │   │(local GPU / │   │(Summarize)  │
    │  dev)    │   │ cloud)      │   │             │
    └──────────┘   └─────────────┘   └─────────────┘
```

---

## 2. Flutter App Architecture

The Nutq Flutter app follows **Clean Architecture** with feature-first folder structure.

### Layer Breakdown

```
lib/
├── core/                        # Shared infrastructure
│   ├── di/                      # GetIt dependency injection
│   ├── network/                 # Dio + Retrofit + error handling
│   ├── routing/                 # Named route navigation
│   ├── theme/                   # Light + Dark MaterialTheme
│   └── preferences/             # SharedPreferences wrapper
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/     # AuthApiService (Retrofit)
    │   │   ├── models/          # JSON models (json_serializable)
    │   │   └── repositories/    # AuthRepositoryImpl
    │   ├── domain/
    │   │   └── repositories/    # AuthRepository interface
    │   └── presentation/
    │       ├── cubit/           # AuthCubit + AuthState (BLoC)
    │       ├── screens/         # LoginScreen, RegisterScreen
    │       └── widgets/         # Shared field widgets
    │
    └── jobs/
        ├── data/
        │   ├── datasources/     # JobsApiService (Retrofit)
        │   ├── models/          # JobModel, TranscriptModel
        │   └── repositories/    # JobsRepositoryImpl
        ├── domain/
        │   └── repositories/    # JobsRepository interface
        └── presentation/
            ├── cubit/           # JobsCubit, JobDetailCubit
            ├── screens/         # HomeScreen, DetailScreen, etc.
            └── widgets/         # JobCard, StatusChip, etc.
```

### State Management: BLoC / Cubit

```
UI (Screen)
    │
    │  user event (button tap)
    ▼
 Cubit.method()
    │
    │  calls repository
    ▼
 Repository (interface)
    │
    │  calls API service / cache
    ▼
 ApiService (Retrofit + Dio)
    │
    │  HTTP request
    ▼
 Nutq REST API
    │
    │  emits new state
    ▼
 BlocBuilder<Cubit, State>  →  UI rebuilds
```

**State classes use Freezed sealed unions:**
```dart
sealed class JobsState extends Equatable {
  const JobsState();
}
final class JobsInitial   extends JobsState { ... }
final class JobsLoading   extends JobsState { ... }
final class JobsLoaded    extends JobsState { final List<Job> jobs; ... }
final class JobsError     extends JobsState { final String message; ... }
```

### Networking: Dio + Retrofit

```dart
// Token auto-attached on every request via Dio interceptor
DioFactory.instance  →  Interceptor reads FlutterSecureStorage
                     →  Sets: Authorization: Bearer <access_token>
                     →  On 401: auto-refresh, retry original request
```

---

## 3. Backend API Architecture (Hexagonal / Ports & Adapters)

```
┌────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER (pure Python)               │
│                                                            │
│  Job entity │ Transcript entity │ User entity              │
│  SubmitJobUseCase │ GetJobUseCase │ CancelJobUseCase        │
│                                                            │
│  Ports (interfaces):                                       │
│    IJobRepository │ ITranscriptBackend │ IStorageBackend    │
└──────────────────────────────────┬─────────────────────────┘
                                   │  implemented by
┌──────────────────────────────────▼─────────────────────────┐
│                  INFRASTRUCTURE LAYER                        │
│                                                            │
│  SQLJobRepository      →  PostgreSQL / SQLite (SQLAlchemy) │
│  WhisperBackend        →  local faster-whisper model       │
│  LocalStorageBackend   →  signed URL file storage          │
│  SummarizationBackend  →  Qwen3: 4B fine-tuned (local)     │
└──────────────────────────────────┬─────────────────────────┘
                                   │  exposed by
┌──────────────────────────────────▼─────────────────────────┐
│                    API LAYER  (FastAPI)                      │
│                                                            │
│  /auth/*     → JWT + refresh token + API key auth          │
│  /jobs/*     → CRUD + status polling + file upload         │
│  /jobs/{id}/ws → WebSocket real-time status                │
└────────────────────────────────────────────────────────────┘
```

---

## 4. Authentication Flow

```
Register                         Login
   │                               │
   │ POST /auth/register            │ POST /auth/login
   │ { email, username, password }  │ { email, password }
   │                               │
   ▼                               ▼
API creates user             API verifies password (bcrypt)
   │                               │
   ▼                               ▼
   └──────────┬────────────────────┘
              │
              ▼
   Issue TokenPair:
   ┌────────────────────────────────┐
   │  access_token  (JWT, 15 min)   │  → stored in FlutterSecureStorage
   │  refresh_token (JWT, 30 days)  │  → stored in FlutterSecureStorage
   └────────────────────────────────┘
              │
              │  On 401 (access expired)
              ▼
   POST /auth/refresh
   { refresh_token }
              │
              ▼
   New TokenPair issued
   Old refresh token revoked (rotation)
   ─────────────────────────────────
   If refresh reused → entire family revoked (reuse detection)
```

### Dual Auth Modes
| Mode | Header | Use case |
|------|--------|----------|
| JWT Bearer | `Authorization: Bearer <jwt>` | Flutter app |
| API Key | `X-API-Key: nutq_<key>` | Integrations / CLI |

---

## 5. Job Submission Flow

```
Flutter App                    Nutq API               Storage / Workers
    │                              │                         │
    │  POST /jobs                  │                         │
    │  { source_type: "upload",    │                         │
    │    filename, content_type }  │                         │
    │─────────────────────────────►│                         │
    │                              │ Creates Job (queued)    │
    │                              │ Issues upload_slot      │
    │◄─────────────────────────────│                         │
    │  { id, upload_slot: {        │                         │
    │      upload_url, token } }   │                         │
    │                              │                         │
    │  PUT /dev-storage/{token}    │                         │
    │  (binary audio file)         │                         │
    │─────────────────────────────────────────────────────►  │
    │◄─────────────────────────────────────────────────────  │
    │  200 OK                      │                         │
    │                              │                         │
    │  POST /jobs/{id}/confirm     │                         │
    │─────────────────────────────►│                         │
    │                              │ Job → processing        │
    │                              │ Whisper runs            │
    │◄─────────────────────────────│                         │
    │  { status: "processing" }    │                         │
    │                              │                         │
    │  [polling every 3s]          │                         │
    │  GET /jobs/{id}              │                         │
    │─────────────────────────────►│                         │
    │◄─────────────────────────────│                         │
    │  { status: "done",           │                         │
    │    transcript: { ... } }     │                         │

── Text / URL / YouTube jobs skip the upload step entirely ──
```

### Idempotency
Every job submission can include an `idempotency_key`. If the same key is submitted again within the window, the API returns the **existing** job — safe for mobile retries after network failures.

---

## 6. Real-Time Status Updates

```
Option A: Polling (implemented, default)
──────────────────────────────────────
Flutter polls GET /jobs/{id} every 3 seconds
while status ∈ { queued, processing }
→ Simple, works on all networks
→ Stop polling when status ∈ { done, failed, cancelled }

Option B: WebSocket (registered, auth TBD)
──────────────────────────────────────────
ws://host/v1/jobs/{id}/ws
→ Server pushes { status, updated_at } on each change
→ Lower latency, better UX for long transcriptions
→ Flutter uses web_socket_channel package
```

---

## 7. Data Model

```
users ─────────────────────────────────────────────────────────
  id (UUID v7) │ email (unique) │ username (unique, nullable)
  password_hash │ role │ status │ created_at

jobs ──────────────────────────────────────────────────────────
  id (UUID v7) │ user_id (FK) │ status │ source_type
  language │ idempotency_key (unique) │ created_at │ updated_at

transcripts ───────────────────────────────────────────────────
  id │ job_id (FK, unique) │ language │ word_count
  duration_seconds │ model_name │ model_version
  download_url │ created_at

summaries ─────────────────────────────────────────────────────
  id │ job_id (FK, unique) │ summary_text │ tone_and_format
  takeaways (JSONB) │ model_name │ tokens_in │ tokens_out

refresh_tokens ────────────────────────────────────────────────
  jti (PK) │ user_id │ family_id │ expires_at │ revoked_at

api_keys ──────────────────────────────────────────────────────
  id │ user_id │ key_hash │ prefix │ scopes │ last_used_at
```

**Job Status State Machine:**
```
          ┌──────────┐
  submit  │          │
─────────►│  queued  │
          │          │
          └────┬─────┘
               │ worker picks up
               ▼
          ┌──────────────┐         ┌──────────┐
          │  processing  │────────►│  failed  │
          └──────┬───────┘  error  └──────────┘
                 │ success
                 ▼
          ┌──────────┐
          │   done   │
          └──────────┘
               ▲
    cancel ────┤ (only from queued/processing)
               ▼
          ┌───────────┐
          │ cancelled │
          └───────────┘
```

---

## 8. Security Model

| Concern | Approach |
|---------|----------|
| Password storage | bcrypt with automatic rehash on login |
| JWT signing | HS256, configurable secret |
| Refresh token reuse | Entire family revoked on reuse detection |
| API key storage | SHA-256 hash only; full key shown once |
| Token storage (mobile) | `FlutterSecureStorage` (iOS Keychain / Android Keystore) |
| Rate limiting | Redis-backed per-user sliding window |
| Upload size | Max 500 MB enforced at API layer |
| Auth bypass | `REQUIRE_AUTH=false` env flag for local dev only |

---

## 9. Non-Functional Targets

| Metric | Target |
|--------|--------|
| Auth endpoints p99 | < 200 ms |
| Job list (first load) | < 1 s on WiFi |
| Transcript turnaround (short clip) | < 30 s |
| Concurrent users (initial) | 50 |
| Mobile app size | < 30 MB |
| Offline behaviour | Cached job list shown; submissions blocked with toast |
