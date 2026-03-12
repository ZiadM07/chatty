<p align="center">
  <img src="assets/pngs/logo.png" width="100" height="100" alt="Chatty logo" />
</p>

<h1 align="center">💬 Chatty</h1>

<p align="center">
  <strong>A modern, real-time Flutter chat app with 1-to-1 messaging, group communities, disappearing stories, media sharing, and full Arabic/English RTL support.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-^3.10.4-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20·%20Firestore%20·%20AppCheck-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Supabase-Storage-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/State-flutter__bloc%20Cubits-7B3FE4?style=flat-square&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/DI-GetIt%20+%20Injectable-FFD700?style=flat-square" />
  <img src="https://img.shields.io/badge/Routing-AutoRoute-E53935?style=flat-square" />
  <img src="https://img.shields.io/badge/License-MIT-22C55E?style=flat-square" />
</p>

---

## 🌟 Overview

**Chatty** is a production-grade, real-time messaging application built with Flutter. Designed around a **feature-based modular architecture** and powered by **Firebase + Supabase**, Chatty delivers a WhatsApp-grade chat experience with a focus on clean code, performance, and developer experience.

### Why Chatty?

- 🏗 **Clean Architecture** — Feature-isolated modules with unidirectional data flow
- ⚡ **Real-time** — Firestore stream listeners with lazy-rendered chat lists
- 🌍 **Bilingual** — First-class Arabic RTL + English LTR with zero hardcoded strings
- 🎨 **Themeable** — Light / Dark / System modes with Material 3 color tokens
- 📱 **Responsive** — Optimized for phones and tablets via `responsive_framework`
- 🔒 **Secure** — Firebase AppCheck for abuse protection

---

## ✨ Features

<table>
  <tr>
    <td width="50%">

### 🔐 Authentication
- Firebase Auth sign up & login
- Auth state persistence
- Post-signup profile completion flow
- Email verification support

### 💬 Real-time Messaging
- 1-to-1 private conversations
- Group / community chats
- Live Firestore stream listeners
- Lazy-rendered message lists

### 📎 Rich Message Types
- Text with automatic Arabic RTL detection
- Image & media attachments (Supabase Storage)
- Voice messages with audio waveforms
- Reply messages with preview bar
- Emoji reactions with animated overlays
- Expandable long messages ("more / less")

</td>
<td width="50%">

### 📖 Stories
- Image, video, and text stories
- 24-hour auto-expiry
- View tracking & like system
- Story replies via chat

### 🖼 Media
- Image/video picker with size validation
- Image cropping before upload
- Full-screen media viewer with zoom
- Video playback support
- Media gallery per chat

### 🎨 Theming & Localization
- Light / Dark / System — switchable at runtime
- Material 3 color scheme + custom tokens
- Arabic (AR) + English (EN)
- Automatic RTL/LTR layout switching

</td>
  </tr>
</table>

### More
- 🔔 **Push Notifications** — OneSignal + FCM integration
- 👤 **Profiles** — Editable name, bio, photo with hero animation preview
- 🔇 **Chat Muting** — Per-chat mute toggle
- 🎵 **Message Sounds** — Audio feedback for new messages
- 📋 **Copy & Share** — Message content actions
- 🖼 **Chat Wallpapers** — Customizable chat backgrounds

---

## 🛠 Tech Stack

| Layer | Technology | Version |
|---|---|---|
| **UI Framework** | Flutter / Dart | 3.x / ^3.10.4 |
| **State Management** | flutter_bloc (Cubits only) | ^9.1.1 |
| **Dependency Injection** | GetIt + Injectable | ^9.0.5 / ^2.6.0 |
| **Routing** | AutoRoute | ^10.2.2 |
| **Networking** | Dio | ^5.9.0 |
| **Auth** | Firebase Authentication | ^6.1.2 |
| **Database** | Cloud Firestore | ^6.1.0 |
| **File Storage** | Supabase Storage | ^2.10.3 |
| **Security** | Firebase AppCheck | ^0.4.1 |
| **Push Notifications** | OneSignal + fcm_config | ^5.3.4 / ^3.6.5 |
| **Responsive** | responsive_framework | ^1.5.1 |
| **Caching** | cached_network_image + flutter_cache_manager | ^3.4.1 |
| **Audio** | just_audio + audio_waveforms | ^0.10.5 / ^2.0.2 |
| **Video** | video_player + video_thumbnail | ^2.10.1 |
| **In-app Toasts** | flash | ^3.1.1 |
| **Fonts** | Inter · Cairo · PlayfairDisplaySC · NotoColorEmoji | — |
| **Icons** | Solar Icons | ^0.0.5 |

---

## 🏗 Architecture

Chatty follows a **feature-based modular architecture** with clear separation of concerns and unidirectional data flow.

```
┌─────────────────────────────────────────────────────────┐
│                        UI Layer                         │
│              Screens · Widgets · Extensions              │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                     State Layer                         │
│           Cubits · AppState<T> · StateHandler            │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                   Repository Layer                      │
│         Cross-cutting logic · Composed operations        │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                   Data Source Layer                      │
│     Firebase · Supabase · SharedPreferences · APIs       │
└─────────────────────────────────────────────────────────┘
```

### Core Principles

| Principle | Detail |
|---|---|
| Feature isolation | Each feature owns its data, state, and UI layers |
| No god classes | One Cubit per responsibility |
| Single error type | `Failure(int code, String message)` everywhere |
| Manual models | No freezed — null-safe defaults, `copyWith`, equality |
| No hardcoded strings | All text via `ChattyApp.locale.xxx` |
| Shared widget system | `AppText`, `AppButton`, `AppImage`, `AppScaffold`, etc. |

### Error Handling

A single `Failure` class is used across all layers:

```dart
class Failure implements Exception {
  final int code;
  final String message;
  Failure(this.code, this.message);
}
```

| Code | Meaning |
|---|---|
| `0` | Unknown |
| `400` | Bad request |
| `401` | Unauthenticated |
| `403` | Forbidden |
| `404` | Not found |
| `500` | Server / Firestore error |
| `503` | Network / connectivity |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── exports.dart             # Barrel — single import for core
│   │   ├── app_constants.dart       # Timeouts, keys, fonts, fallback URLs
│   │   ├── app_colors.dart          # Static palette
│   │   └── app_padding.dart         # AppPadding.set() factory
│   ├── di/
│   │   ├── injectable.dart          # GetIt setup + @module
│   │   └── injectable.config.dart   # Generated — never edit
│   ├── framework/
│   │   ├── failure.dart             # Single Failure class
│   │   ├── kprint.dart              # kPrint() debug logger
│   │   ├── storage_service.dart     # StorageService wrapper
│   │   └── api_executor.dart        # API call wrapper
│   ├── state/
│   │   ├── app_state.dart           # AppState<T> + StateStatus enum
│   │   └── state_handler.dart       # Multi-state rendering widget
│   ├── utils/
│   │   ├── validator.dart           # Form validators
│   │   ├── app_border_radius.dart   # RTL-safe border radius
│   │   └── enums.dart               # Shared enums
│   └── network/                     # Dio setup, interceptors
│
├── config/
│   ├── router/
│   │   ├── app_router.dart          # Route definitions
│   │   └── app_router.gr.dart       # Generated — never edit
│   └── theme/
│       └── app_theme.dart           # Material 3 themes + custom tokens
│
├── features/
│   ├── auth/                        # 🔐 Authentication
│   │   ├── cubits/                  #    AuthCubit
│   │   ├── data/                    #    AuthDataSource, AuthRepository
│   │   └── ui/                      #    Login, Signup, Splash, FillProfile
│   ├── chats/                       # 💬 Messaging
│   │   ├── cubits/                  #    ConversationsCubit, ChatCubit, ChatInfoCubit
│   │   ├── data/                    #    ChatDataSource, ChatRepository
│   │   └── ui/                      #    Chat screen, message bubbles, media viewer
│   ├── profile/                     # 👤 User Profile
│   │   ├── cubits/                  #    ProfileCubit
│   │   ├── data/                    #    ProfileDataSource, ProfileRepository
│   │   └── ui/                      #    Profile screen, settings
│   ├── users/                       # 👥 User Directory
│   │   ├── cubits/                  #    UsersCubit
│   │   ├── data/                    #    UsersDataSource, UsersRepository
│   │   └── ui/                      #    Users list, search
│   ├── stories/                     # 📖 Stories
│   │   ├── cubits/                  #    StoriesCubit, StoryViewerCubit
│   │   ├── data/                    #    StoryDataSource, StoryRepository
│   │   └── ui/                      #    Story viewer, add story
│   └── shared/                      # 🧩 Shared Components
│       └── widgets/                 #    AppText, AppButton, AppImage, AppScaffold...
│
└── l10n/                            # 🌍 Localization
    └── app_localizations.dart
```

---

## 🧠 State Management

Chatty uses **Cubit** from `flutter_bloc` with a generic `AppState<T>` wrapper for consistent, predictable state.

### AppState\<T\>

```dart
enum StateStatus { initial, loading, loadingOverlay, success, error, none }

class AppState<T> extends Equatable {
  final StateStatus status;
  final T? data;
  final String? message;
  // Convenience getters: isInitial, isLoading, isSuccess, isError
}
```

### Feature Cubits

| Feature | Cubit | Responsibility |
|---|---|---|
| Auth | `AuthCubit` | Login, signup, session, email verification |
| Conversations | `ConversationsCubit` | Chat list streams |
| Chat | `ChatCubit` | Messages, send/receive, media |
| Chat Info | `ChatInfoCubit` | Chat details, group management |
| Profile | `ProfileCubit` | Profile CRUD |
| Users | `UsersCubit` | User list, search, pagination |
| Stories | `StoriesCubit` | Story feed, upload |
| Story Viewer | `StoryViewerCubit` | Viewing, likes, replies |
| App | `AppCubit` | Theme, language |

### One-Shot Pattern (fetch / upload)

```dart
Future<void> loadProfile(String uid) async {
  emit(state.copyWith(fetchState: const AppState(status: StateStatus.loading)));
  try {
    final profile = await _repo.getProfile(uid: uid);
    emit(state.copyWith(
      fetchState: AppState(status: StateStatus.success, data: profile),
    ));
  } on Failure catch (e) {
    emit(state.copyWith(
      fetchState: AppState(status: StateStatus.error, message: e.message),
    ));
  }
}
```

### Stream Pattern (Firestore real-time)

```dart
void watchConversations(String uid) {
  emit(state.copyWith(listState: const AppState(status: StateStatus.loading)));
  _sub = _repo.watchConversations(uid: uid).listen(
    (items) => emit(state.copyWith(
      listState: AppState(status: StateStatus.success, data: items),
    )),
    onError: (e) => emit(state.copyWith(
      listState: AppState(
        status: StateStatus.error,
        message: e is Failure ? e.message : 'Connection lost.',
      ),
    )),
  );
}
```

### StateHandler Widget

Automatic rendering based on `AppState` status — shows loading, error with retry, or content:

```dart
StateHandler(
  state: state.fetchState,
  onRetry: () => cubit.reload(),
  builder: (context, state) => YourContentWidget(),
)
```

---

## 💉 Dependency Injection

Chatty uses **GetIt + Injectable** for compile-time-safe DI.

```dart
// Data sources — lazy singleton
@LazySingleton(as: ChatDataSource)
class ChatDataSourceImpl implements ChatDataSource { ... }

// Repositories — lazy singleton
@lazySingleton
class ChatRepository {
  final ChatDataSource _dataSource;
  const ChatRepository(this._dataSource);
}

// Cubits — factory (new instance per BlocProvider)
@injectable
class ChatCubit extends Cubit<ChatState> { ... }

// Third-party — registered via @module
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
```

> ⚠️ After any change to annotated files, regenerate:
> ```bash
> flutter pub run build_runner build --delete-conflicting-outputs
> ```

---

## 🗺 Routing

Chatty uses **AutoRoute** with `fadeIn` transitions (220ms) on all screens.

<table>
<tr>
<td>

### Unauthenticated

| Route | Screen |
|---|---|
| `SplashRoute` | Splash |
| `WelcomeRoute` | Onboarding |
| `LoginRoute` | Login |
| `SignupRoute` | Sign up |
| `FillProfileRoute` | Profile setup |

</td>
<td>

### Authenticated

| Route | Screen |
|---|---|
| `MainRoute` | Main shell |
| `ConversationsRoute` | Chat list |
| `ChatRoute` | Chat screen |
| `ChatInfoRoute` | Chat details |
| `UsersRoute` | User directory |
| `ProfileRoute` | Profile view |
| `ProfileSettingsRoute` | Profile settings |
| `ChatsSettingsRoute` | Chat settings |
| `LanguageSettingsRoute` | Language picker |
| `NotificationSettingsRoute` | Notifications |
| `AddStoryRoute` | Add story |
| `StoryViewerRoute` | View story |
| `ChatMediaRoute` | Media gallery |
| `ChatWallpaperRoute` | Wallpaper picker |

</td>
</tr>
</table>

---

## ☁️ Backend

### Firebase
| Service | Usage |
|---|---|
| **Authentication** | Sign up, login, session persistence, email verification |
| **Cloud Firestore** | Conversations, messages, profiles, stories (real-time streams) |
| **AppCheck** | Abuse protection |

### Supabase
| Service | Usage |
|---|---|
| **Storage** | All media uploads — images, voice messages, story media, profile photos |

---

## 🎨 Theming & Localization

### Theme Modes

| Mode | Description |
|---|---|
| ☀️ Light | Clean, bright interface |
| 🌙 Dark | Eye-friendly dark palette |
| 🖥 System | Follows device setting |

Switch at runtime via `AppCubit`:
```dart
context.read<AppCubit>().changeThemeMode(0) // light
context.read<AppCubit>().changeThemeMode(1) // dark
context.read<AppCubit>().changeThemeMode(2) // system
```

### Custom Color Tokens

```dart
context.colorScheme.textPrimary    // main text
context.colorScheme.textSecondary  // muted text
context.colorScheme.textTertiary   // hint text
context.colorScheme.primary        // brand color
context.colorScheme.surface        // backgrounds
context.colorScheme.error          // error states
```

### Localization

| Language | Code | Font | Direction |
|---|---|---|---|
| English | `en` | Inter | LTR |
| Arabic | `ar` | Cairo | RTL |

All strings accessed via `ChattyApp.locale.xxx` — layout direction switches automatically.

---

## 🧩 Shared Widget System

Chatty enforces a **shared widget system** — raw Flutter primitives are never used when a shared alternative exists.

| Instead of | Use |
|---|---|
| `Text()` | `AppText()` |
| `Scaffold()` | `AppScaffold()` |
| `TextFormField()` | `AppTextFormField()` |
| `ElevatedButton` | `AppButton()` |
| `Image.network()` | `AppImage()` |
| `Padding()` | `.addPadding()` extension |
| `GestureDetector` | `.addAction()` extension |
| `BorderRadius` | `AppBorderRadius.set()` |
| `SnackBar` | `AppToast.showError/showSuccess()` |

### Highlights

```dart
// Text with auto Arabic RTL
AppText('Hello', size: 22, weight: FontWeight.w600)

// Gradient action button
AppButton(text: 'Continue', onTap: _submit)

// Cached network image with shimmer
AppImage(imageUrl: user.photoUrl, width: 48, height: 48, borderRadius: 24)

// Scaffold with back button
AppScaffold(title: 'Settings', body: const _Content())

// Form input with password toggle
AppTextFormField(controller: _ctrl, isPasswordField: true)

// Padding via extension
widget.addPadding(horizontal: 16, vertical: 8)

// Tap with bounce animation
icon.addAction(onBounce: () => doSomething())
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter 3.x](https://flutter.dev/docs/get-started/install) + Dart ^3.10.4
- [Firebase CLI](https://firebase.google.com/docs/cli) + [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- A [Supabase](https://supabase.com) project with a storage bucket

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/ZiadM07/chatty.git
cd chatty

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
flutterfire configure
# Add google-services.json (Android) and GoogleService-Info.plist (iOS)

# 4. Configure Supabase
# Add your Supabase URL and anon key to your env/constants file

# 5. Generate code (routes, DI, serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# 6. Run
flutter run
```

> ⚠️ Re-run `build_runner` whenever you modify files with `@injectable`, `@LazySingleton`, `@RoutePage`, or `@JsonSerializable` annotations.

---

## 📝 Code Style

| Convention | Example |
|---|---|
| Classes | `PascalCase` → `ChatRepository` |
| Files | `snake_case` → `chat_repository.dart` |
| Variables | `camelCase` → `userList` |
| Private fields | `_camelCase` → `_firestore` |
| Constants | `camelCase` → `cacheFolder` |
| Icons | `SolarIconsOutline.xxx` |

### Key Rules
- `const` on all static widgets
- `async/await` only — no `.then()`
- `kPrint()` for logging — never `print()`
- `context.router.maybePop()` for navigation — never `Navigator.pop()`
- `Validator.xxx` for form validation — never inline regex
- `AppToast` for user feedback — never raw `SnackBar`

---


##  Made with ❤️ By Ziad Mohamed 

### GitHub: [ZiadM07](https://github.com/ZiadM07)
### 


