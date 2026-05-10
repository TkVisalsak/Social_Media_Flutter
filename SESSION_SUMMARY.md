# Session Summary — Flutter Models, Repos, Architecture Fixes & Backend Hardening

This document summarizes all work performed in this session across the
Flutter client (`socialmedia/`) and the Express backend
(`social-media-backend/`).

---

## 1. Flutter — Data Models

Created/updated models to mirror the backend exactly. All located under
`lib/data/models/`.

| Model file | Backend mapping | Notes |
|------------|-----------------|-------|
| `user_model.dart` | `User` | Added `firstName`, `lastName`, `dob`, `gender`, `createdAt`, `fullName` getter, `copyWith`, equality |
| `post_model.dart` | `Feed` | Already matched backend (visibility, hashtags, location, isEdited) |
| `short_model.dart` | `ShortVideo` | Already present |
| `comment_model.dart` | `Comment` (feed + short) | Already present |
| `message_model.dart` | `Message` + `Conversation` | Both DM and group conversation types |
| `story_model.dart` | `Story` | Media array, viewers, expiry |
| `notification_model.dart` | (frontend-only) | Stub for future server-side notifications |
| `follow_model.dart` | `Follow` | follower/following relationships |
| `save_model.dart` | `Save` | polymorphic feed/short with `SaveContentType` enum |
| `repost_model.dart` | `Repost` | polymorphic feed/short with `RepostContentType` enum |
| `user_preference_model.dart` | `UserPreference` | active status, mute, notification toggle |

### JSON utility bug fix
`lib/core/utils/json_util.dart` — `nullableString` always returned `null`
(`return s.isEmpty ? null : null;`). Fixed to return the actual string.

---

## 2. Flutter — Repository / Provider Layer

Pattern: **Repo → Provider → Dio → DioClient.instance**, every repo
returns `ApiResponse<T>`.

### Providers added (`lib/data/providers/`)
- `follow_provider.dart`
- `save_provider.dart`
- `repost_provider.dart`
- `user_provider.dart`
- `short_provider.dart`
- `story_provider.dart`
- `message_provider.dart` *(was `chat_provider.dart`)*
- `notification_provider.dart`

### Repositories added/refactored (`lib/data/repositories/`)
- `follow_repository.dart`
- `save_repository.dart`
- `repost_repository.dart`
- `user_repository.dart`
- `short_repository.dart` *(was empty)*
- `story_repository.dart` *(was empty)*
- `message_repository.dart` *(was `chat_repository.dart`, was empty)*
- `notification_repository.dart` *(was empty)*
- `repo_helpers.dart` — shared `normalizeBody`, `extractList`, `asMap`,
  `dioErrorMessage` helpers (renamed from `_repo_helpers.dart` to follow
  conventional naming)

### Endpoint registry (`lib/data/network/api_endpoint.dart`)
Updated with all backend routes (auth, follow, save, repost, shorts,
stories, conversations, messages).

---

## 3. Flutter — Architecture Audit & Top-3 Fixes

After scanning the project structure, I identified critical gaps and
fixed the top three.

### Fix 1 — Dependency Injection wired
`lib/app/bindings/initial_binding.dart` now registers every Provider and
Repository as `lazyPut(fenix: true)`, plus `Dio` and `SocketService` as
permanent singletons. Module bindings can `Get.find<AnyRepository>()`
without crashing.

### Fix 2 — Naming consistency with backend

| Before | After | Reason |
|--------|-------|--------|
| `chat_provider.dart` / `ChatProvider` | `message_provider.dart` / `MessageProvider` | Backend has `Message` model, module folder was already `message/` |
| `chat_repository.dart` / `ChatRepository` | `message_repository.dart` / `MessageRepository` | Same |
| `modules/reels/` + `Reels*` classes | `modules/shorts/` + `Shorts*` classes | Backend uses `/shorts` endpoint and `ShortVideo` model |
| `AppRoutes.REELS` (`/reels`) | `AppRoutes.SHORTS` (`/shorts`) | Match backend |
| `_repo_helpers.dart` | `repo_helpers.dart` | Underscore prefix at file level was non-standard |

All call sites updated (`feed_view`, `profile_view`, `message_view`,
`app_pages`, `app_routes`, `feed_create_flow`). Old files deleted. The
new `ShortsController` is also wired to `ShortRepository` (the old
`ReelsController` had no repo).

### Fix 3 — Socket.io service
- Added `socket_io_client: ^2.0.3+1` to `pubspec.yaml`
- Created `lib/core/services/socket_service.dart` with:
  - JWT auth from `LocalStorage`
  - Streams: `connectionStream`, `messageStream`, `notificationStream`,
    `typingStream`
  - Methods: `connect()`, `disconnect()`, `joinConversation()`,
    `leaveConversation()`, `sendTyping()`, generic `emit()`
  - Idempotent connect, safe `dispose()`
- Registered as permanent singleton in `InitialBinding`

> Run `flutter pub get` to install the new package.

---

## 4. Backend — Critical Bug Fixes

### `message.controller.js` — broken REST endpoints
The controller queried `Message.find({ $or: [{ senderId, receiverId }, ...] })`
but the Message model has **no `receiverId` field** (it uses
`conversationId`). REST messaging never worked — only the socket flow
did. Rewrote the controller to:

- Find or create the 1-to-1 Conversation between the two users
- Query messages by `conversationId`
- Populate `senderId` with proper fields
- Update `lastMessage` on the conversation
- Emit `newMessage` to all of the receiver's open sockets
- Paginate `getUsersForSidebar` (was returning ALL users)

### Populate field-name typos
Across multiple controllers, `populate("...avatar")` and
`populate("username")` referenced non-existent fields — User model uses
`profilePic` and `userName`. Fixed in:

- `controllers/userController/follow.controller.js`
- `controllers/userController/repost.controller.js`
- `controllers/feedController/feed.comment.controller.js` (3 sites)
- `controllers/shortController/short.comment.controller.js` (4 sites)
- `controllers/storyController/story.controller.js`

All now use `"userName profilePic firstName lastName"`.

### `db.js`
- Removed unused `import mongooose from "mongoose"` typo
- Added `MONGODB_URI` env-var check
- Added `process.exit(1)` on connection failure
- Added `mongoose.set("strictQuery", true)`

### Dead code removed
- `backend/src/server.js` (duplicate, never started)
- `backend/src/lib/socket.js` (duplicate of `socket/socket.js`)

---

## 5. Backend — New Endpoints

The Flutter side already had wiring for these — they were dead-ends
until now.

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/api/auth/refresh` | Exchanges refresh token for new access token. The Flutter `RefreshInterceptor` is now functional. |
| `POST` | `/api/auth/forgot-password` | Generates reset token, logs server-side (TODO: email). Returns generic message — doesn't leak whether email exists. |
| `POST` | `/api/auth/reset-password` | Verifies reset token, hashes new password, updates user. |

### Auth token strategy changed
- Access token TTL: `7d` → `15m`
- New refresh token: `30d`, signed with separate `JWT_REFRESH_SECRET`
- bcrypt rounds: `10` → `12`
- Login/signup now return `{ success, accessToken, refreshToken, user }`
- `lib/utils.js` exports `generateAccessToken`, `generateRefreshToken`,
  `generateResetToken`, `verifyRefreshToken`, `verifyResetToken`
  (`generateToken` retained as alias for backward compatibility)

---

## 6. Backend — Security Hardening

Applied globally in `index.js`:

- **`helmet`** — security headers
- **`express-mongo-sanitize`** — strips `$` and `.` from user input,
  blocks NoSQL injection
- **`express-rate-limit`** — global `200 req/min`, stricter `20 req/15 min`
  on auth endpoints (signup/login/forgot/reset)
- **`express-validator`** — wired via new `middleware/validate.middleware.js`,
  applied to all auth routes
- **`morgan`** logger — `dev` in dev, `combined` in prod
- **404 handler** added
- **Structured error responses** — no stack traces in prod
- **`/health` endpoint** for uptime checks

### Hardcoded redirects fixed
`google.controller.js` previously redirected to
`http://127.0.0.1:5500/frontend/public/...` — would break in prod. Now
uses `process.env.FRONTEND_URL`.

### `updateProfile` consistency
Now accepts both multipart upload (via multer) AND base64 (for backward
compat).

---

## 7. Backend — `package.json` Cleanup

- Removed unused dep: **`twilio`**
- Moved `nodemon` to `devDependencies`
- Added `engines.node: ">=18"`
- Added new deps: `helmet`, `express-mongo-sanitize`, `morgan`
- Ran `npm audit fix` — resolved high-severity Mongoose NoSQL injection
  vulnerability

---

## 8. Required Environment Variables

Add to `backend/.env` if not already present:

```
MONGODB_URI=<your mongo connection string>
JWT_SECRET=<existing access-token secret>
JWT_REFRESH_SECRET=<new long random string, must differ from JWT_SECRET>
FRONTEND_URL=http://localhost:5500/frontend/public
NODE_ENV=development
PORT=5001
```

---

## 9. Verification

- `node --check` passed on every changed JS file
- Smoke test: imported all 10 changed modules in isolation — `ALL IMPORTS OK`
- Vulnerability audit: `found 0 vulnerabilities` after `npm audit fix`
- Flutter side has defensive `RepoHelpers.normalizeBody` + `_extractToken`
  / `_extractRefreshToken` already in place — no client-side changes
  required for the new envelope shape

---

## 10. What Was Intentionally Skipped

These were called out in the audit but not pursued in this session:

- **Full response-envelope refactor** across every backend controller
  (would touch 30+ files for cosmetic gain; Flutter side parses
  defensively already).
- **ESLint / Prettier** configuration on the backend.
- **Test scaffold** (Jest/Vitest) on either side.
- **`PostModel` → `FeedModel`** rename (would touch 5+ Flutter UI files;
  "post" is universal social-media UI vocabulary).
- **`core/theme/`, `core/widgets/`, `core/constants/`** scaffolding for
  shared UI primitives.
- **`LocalStorage`** move from `data/providers/` to `data/local/`.
- **Email service integration** for `forgot-password` (token currently
  logged to server console — TODO marked in code).
- **Repo cleanup**: stale `.claude/worktrees/elegant-herschel-bbe57d/`
  copy of the backend, `hs_err_pid*.log` in the Flutter project,
  `getx.framework.md` / `todo.md` at project root.

---

## 11. File Inventory

### Flutter — Created
- `lib/core/services/socket_service.dart`
- `lib/data/models/follow_model.dart`
- `lib/data/models/save_model.dart`
- `lib/data/models/repost_model.dart`
- `lib/data/models/user_preference_model.dart`
- `lib/data/providers/follow_provider.dart`
- `lib/data/providers/save_provider.dart`
- `lib/data/providers/repost_provider.dart`
- `lib/data/providers/user_provider.dart`
- `lib/data/providers/short_provider.dart`
- `lib/data/providers/story_provider.dart`
- `lib/data/providers/message_provider.dart`
- `lib/data/providers/notification_provider.dart`
- `lib/data/repositories/repo_helpers.dart`
- `lib/data/repositories/follow_repository.dart`
- `lib/data/repositories/save_repository.dart`
- `lib/data/repositories/repost_repository.dart`
- `lib/data/repositories/user_repository.dart`
- `lib/data/repositories/short_repository.dart` (filled)
- `lib/data/repositories/story_repository.dart` (filled)
- `lib/data/repositories/message_repository.dart` (renamed/filled)
- `lib/data/repositories/notification_repository.dart` (filled)
- `lib/modules/shorts/bindings/shorts_binding.dart`
- `lib/modules/shorts/controllers/shorts_controller.dart`
- `lib/modules/shorts/views/shorts_view.dart`

### Flutter — Modified
- `lib/core/utils/json_util.dart` (bug fix)
- `lib/data/models/user_model.dart` (added fields)
- `lib/data/network/api_endpoint.dart` (full backend route map)
- `lib/app/bindings/initial_binding.dart` (full DI graph)
- `lib/app/routes/app_routes.dart` (`SHORTS`)
- `lib/app/routes/app_pages.dart` (shorts module)
- `lib/modules/feed/views/feed_view.dart` (route rename)
- `lib/modules/feed/widgets/feed_create_flow.dart` (snackbar text)
- `lib/modules/message/views/message_view.dart` (nav rename)
- `lib/modules/profile/views/profile_view.dart` (nav rename)
- `pubspec.yaml` (`socket_io_client`)

### Flutter — Deleted
- `lib/data/repositories/_repo_helpers.dart`
- `lib/data/repositories/chat_repository.dart`
- `lib/data/providers/chat_provider.dart`
- `lib/modules/reels/` (entire folder)

### Backend — Created
- `backend/src/middleware/validate.middleware.js`

### Backend — Modified
- `backend/src/index.js` (security middleware, error handling, health
  check, route mounting)
- `backend/src/lib/db.js` (typo, exit on failure, strictQuery)
- `backend/src/lib/utils.js` (refresh + reset tokens)
- `backend/src/controllers/authController/auth.controller.js` (new
  endpoints, sanitizeUser, multer support)
- `backend/src/controllers/authController/google.controller.js`
  (`generateAccessToken`, env-driven redirect)
- `backend/src/controllers/messageController/message.controller.js`
  (full rewrite to use Conversation)
- `backend/src/controllers/userController/follow.controller.js`
  (populate fix)
- `backend/src/controllers/userController/repost.controller.js`
  (populate fix)
- `backend/src/controllers/feedController/feed.comment.controller.js`
  (populate fix)
- `backend/src/controllers/shortController/short.comment.controller.js`
  (populate fix)
- `backend/src/controllers/storyController/story.controller.js`
  (populate fix)
- `backend/src/routes/authRoute/auth.route.js` (new endpoints,
  validation, rate limiting, multer)
- `backend/package.json` (deps cleanup, engines, devDeps split)

### Backend — Deleted
- `backend/src/server.js`
- `backend/src/lib/socket.js`







