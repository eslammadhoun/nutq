# Software Requirements Specification
## Nutq — Arabic Speech Transcription App
**Version:** 1.0  
**Date:** 2026-08-06  
**Platform:** Flutter (iOS + Android)  
**Backend:** Nutq Transcription API v1 (FastAPI, hexagonal arch)

---

## 1. Purpose

Nutq is a mobile application that lets users transcribe Arabic audio and text using the Nutq backend API. Users can submit audio files, YouTube links, web URLs, or raw text for transcription/summarization, then view and manage their results.

---

## 2. Scope

The v1.0 release covers:
- Account management (register, login, logout, refresh)
- Job submission via 4 source types: **text**, **file upload**, **URL**, **YouTube**
- Real-time job status tracking via polling / WebSocket
- Transcript and summary viewing
- Jobs history with pagination
- API key management (developer feature)

---

## 3. User Stories

### Auth
| ID | As a user I want to… | So that… |
|----|----------------------|----------|
| U1 | Register with email, username + password | I can create an account with an identity |
| U2 | Log in and receive a JWT | I can use authenticated endpoints |
| U3 | Stay logged in on relaunch | I don't re-enter credentials every time |
| U4 | Log out | My session is cleared from the device |

### Jobs
| ID | As a user I want to… | So that… |
|----|----------------------|----------|
| J1 | Submit a text snippet | I get a summarized/processed result |
| J2 | Upload a local audio file | I get an Arabic transcription |
| J3 | Paste a URL (web audio/video) | The backend fetches and transcribes it |
| J4 | Paste a YouTube URL | The backend transcribes the video |
| J5 | See a live status indicator | I know when my job is done |
| J6 | Read the full transcript | I can copy or share the result |
| J7 | Read the AI summary + takeaways | I get a quick digest |
| J8 | Browse my past jobs | I can find previous transcriptions |
| J9 | Cancel a pending job | I can abort a submission I no longer need |
| J10 | Use an idempotency key | Retrying a request doesn't create duplicates |

### Settings
| ID | As a user I want to… | So that… |
|----|----------------------|----------|
| S1 | View my account info (username, email) | I know which account is signed in |
| S2 | Toggle dark mode | I can use the app comfortably at night |
| S3 | Create API keys with scopes | I can integrate Nutq into my own tools |
| S4 | List and revoke API keys | I can manage programmatic access |

### Notifications
| ID | As a user I want to… | So that… |
|----|----------------------|----------|
| N1 | See an in-app notification when a job completes | I'm informed without keeping the app open |
| N2 | View my notification history | I can review past completions and errors |
| N3 | Clear individual or all notifications | I can keep the list tidy |

---

## 4. Screens

### 4.1 Splash Screen
- Displays Nutq logo + name for ~1.5 s
- Checks `SharedPreferences` for login state → routes to Onboarding (first launch) or Home

### 4.2 Onboarding Flow (3 slides)
- **Slide 1 — Transcribe:** "Turn Arabic speech into text in seconds"
- **Slide 2 — Summarize:** "Get AI-powered summaries and key takeaways"
- **Slide 3 — Manage:** "Browse your history, share, and export"
- Skip button on slides 1–2; "Get Started" CTA on slide 3 → Login
- Only shown on first launch; stored flag in `SharedPreferences`

### 4.3 Login Screen
- Email + password fields
- "Log In" button → `POST /auth/login`
- Link to Register screen
- Error snackbar on failure

### 4.4 Register Screen
- Username + email + password + confirm password fields
- "Register" button → `POST /auth/register`
- Username: alphanumeric + underscores, 2–50 chars
- On success → navigate to Home directly (register returns a TokenPair)

### 4.5 Home — History
- Paginated list of jobs (cursor-based, `GET /jobs`)
- Each card shows: source type icon, status chip, created date, language, short preview of transcript
- Status chips: `queued` (grey) · `processing` (blue, animated) · `done` (green) · `failed` (red) · `cancelled` (grey)
- FAB → New Job sheet
- Pull-to-refresh
- Empty state illustration when no jobs

### 4.6 New Job Bottom Sheet
Four tabs:

| Tab | Source Type | Required Fields |
|-----|-------------|-----------------|
| Text | `text` | Text area (up to 500k chars) |
| File | `upload` | File picker (audio), optional filename |
| URL | `url` | URL field |
| YouTube | `youtube` | YouTube URL, optional "Force Whisper" toggle |

- Language selector (default: Arabic `ar`)
- Optional idempotency key field (advanced, collapsed by default)
- Submit → `POST /jobs` → confirm upload if `upload_slot` returned → polling starts

### 4.7 Job Detail Screen
- Header: status chip, source type, created date
- **Transcript card**: language, word count, duration, model info, full text (RTL for Arabic)
- **Summary card**: summary text, tone/format badge, takeaways list
- **Download** button (when `download_url` is available)
- **Cancel** button (when status is `queued` or `processing`)
- Real-time status polling every 3 s (or WebSocket when available)

### 4.8 Notifications Screen
- In-app notification feed (job completed, job failed, system messages)
- Each notification: icon, title, body, timestamp, unread dot
- Tap → navigates to relevant Job Detail
- Swipe-to-dismiss individual notifications
- "Clear All" button in app bar
- Badge count on bottom nav icon

### 4.9 Profile / Settings Screen
- Username + email display, avatar initials
- **Dark Mode** toggle (persisted in `SharedPreferences`)
- Logged-in email display
- "Log Out" button → `POST /auth/logout` → clear tokens → Login screen
- **API Keys section**:
  - List of keys (prefix, scopes, created date)
  - "Create API Key" button → scope selector → `POST /auth/api-keys` → show full key once modal
  - Swipe-to-delete → `DELETE /auth/api-keys/{id}`

---

## 5. API Mapping

| Screen / Action | Method | Endpoint |
|-----------------|--------|----------|
| Register | POST | `/auth/register` |
| Login | POST | `/auth/login` |
| Refresh token | POST | `/auth/refresh` |
| Logout | POST | `/auth/logout` |
| Get current user | GET | `/auth/me` |
| Create API key | POST | `/auth/api-keys` |
| List API keys | GET | `/auth/api-keys` |
| Revoke API key | DELETE | `/auth/api-keys/{id}` |
| Submit job | POST | `/jobs` |
| Upload audio file | PUT | `/dev-storage/{token}` (from upload_slot) |
| Confirm upload | POST | `/jobs/{id}/confirm` |
| Get job detail | GET | `/jobs/{id}` |
| List jobs | GET | `/jobs?cursor=&limit=` |
| Cancel job | POST | `/jobs/{id}/cancel` |
| Real-time status | WS | `/jobs/{id}/ws` |

---

## 6. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Auth | JWT stored in `FlutterSecureStorage`; auto-refresh on 401 |
| Offline | Show cached jobs list when offline; new submissions blocked with toast |
| Performance | Jobs list first load < 1 s on WiFi |
| Retry | Idempotency key auto-generated for upload/URL jobs to survive retries |
| Accessibility | Minimum touch target 48×48 dp; support RTL for Arabic content |
| Security | No tokens stored in plain SharedPreferences |

---

## 7. Design Guidelines

- **Font:** Inter (Latin UI) + Noto Naskh Arabic (Arabic transcript content)
- **Color:** Primary `#1A56DB` (blue), surface white/dark, status-specific chips
- **Style:** Clean, minimal cards; Material 3; rounded corners (12 dp)
- **Language:** UI in English; transcript content rendered RTL when Arabic
- **Dark mode:** Supported v1.0 — toggle in Settings, system default respected on first launch
- **Navigation:** Bottom nav bar with 3 tabs: History · Notifications · Profile
