# SkillLoop 🔄 — Peer-to-Peer Student Skill Exchange

SkillLoop is a student-to-student skill exchange mobile application built with **Flutter** and **Firebase**. It allows students to teach skills they already know and learn skills from peers on campus, featuring smart skill matching, exchange request workflows, real-time 1-on-1 messaging, in-app notifications, and peer review reputation.

---

## 📱 Features

1. **Authentication & Student Profiles**
   - Email/Password authentication with Firebase Auth.
   - Registration collects **Full Name, College, Department, and Year of Study**.
   - Profile management: Edit bio, skills you can teach, skills you want to learn, and availability status.
   - Teaching skills retain their original string-list structure and may include an optional student-written description in `teachingSkillDescriptions`.
2. **Faithful Wireframe Homepage**
   - Personalized greeting with the logged-in student's first name and avatar.
   - Category filter chips: `Technology`, `Design`, `Creative`, `Communication`, `Academics`.
   - "Recommended for You" horizontal student cards with avatar, department, rating, tags, and "View Profile".
   - "Perfect Match" banner opening the explainable skill matching screen.
   - Fixed bottom navigation (Home, Explore, Chat, Profile) with lavender active indicator.
3. **Explore Skills & Directory**
   - Search across skills, student names, and topics.
   - Filter by skill categories or academic department (`CSE`, `ECE`, `IT`, `Mech`, `Management`).
   - Clean empty and error state handling.
4. **Explainable Skill Matching**
   - Intelligent normalized matching engine comparing your learning wishlist (`skillsToLearn`) with peers' teaching skills (`skillsToTeach`).
   - Detects and highlights **Mutual Matches ("✨ Perfect Match")** where both students can trade skills.
5. **Skill Exchange Requests**
   - Send requests specifying the skill you offer, skill you request, and an optional message.
   - Prevent duplicate pending requests.
   - Receiver can **Accept** or **Decline**.
   - Either participant can mark an exchange as **Completed**.
6. **Real-Time 1-on-1 Chat**
   - Direct private chat channels backed by Cloud Firestore real-time streams.
   - Timestamp formatting, sender/receiver message styling, and unread badges.
7. **Ratings & Peer Reviews**
   - After completing an exchange, each participant can submit one immutable 1–5 star rating and optional feedback.
   - The review document ID is deterministic (`exchangeRequestId_reviewerId`), preventing duplicate reviews.
8. **In-App Notifications**
   - Real-time alerts for exchange requests, acceptance, new messages, completions, and reviews.
   - Tap to mark as read and jump directly to the relevant request or chat.
9. **Safe Demo Data**
   - Includes realistic sample students (`Priya S.` for UI/UX Design, `Rahul K.` for Python, `Ananya M.` for Flutter, etc.).
   - Demo records are tagged `isDemo: true` to prevent pollution of real user accounts.
   - One-tap "Seed Demo Data" and "Clear Demo Data" buttons in the Profile tab.

---

## 🛠 Tech Stack

- **Framework**: Flutter 3.38+ / Dart 3.10+
- **Architecture**: Layered (Screens, Widgets, Models, Services, Providers)
- **State Management**: `provider` (^6.1.2) with `ChangeNotifierProxyProvider`
- **Backend & Database**:
  - `firebase_core` (^3.12.1)
  - `firebase_auth` (^5.5.1)
  - `cloud_firestore` (^5.6.5)
  - `firebase_storage` (^12.4.4)
- **Utilities**: `intl` (^0.20.2), `cupertino_icons` (^1.0.8)

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Hex colors: Lavender (#6366F1), pastels, borders
│   │   ├── app_text_styles.dart    # Typography hierarchy
│   │   └── app_theme.dart          # Material 3 light theme definition
│   ├── routes/
│   │   └── app_routes.dart         # Named routes map
│   └── widgets/
│       ├── avatar_widget.dart      # Safe network image with initials fallback
│       ├── bottom_nav_bar.dart     # Wireframe-faithful 4-tab bottom bar
│       ├── category_chip.dart      # Filter chips
│       ├── custom_button.dart      # Primary, secondary, outline button variants
│       ├── custom_text_field.dart  # Form text fields with validation & password toggle
│       ├── empty_state_view.dart   # Empty state displays
│       └── student_card.dart       # Horizontal/Grid student card widget
├── models/
│   ├── app_notification.dart       # Notification model
│   ├── chat_message.dart           # 1-on-1 message model
│   ├── conversation.dart           # Chat conversation thread model
│   ├── exchange_request.dart       # Skill trade request model
│   ├── review.dart                 # Rating & review model
│   └── user_profile.dart           # Student profile model
├── providers/
│   ├── auth_provider.dart          # Auth session & current profile state
│   ├── chat_provider.dart          # Conversations & active chat streams
│   ├── exchange_provider.dart      # Sent/Received requests & actions
│   ├── explore_provider.dart       # Search, category, & student filters
│   └── notification_provider.dart  # In-app notifications & unread counts
├── screens/
│   ├── auth/
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── welcome_screen.dart
│   ├── chat/
│   │   ├── chat_room_screen.dart
│   │   └── conversations_screen.dart
│   ├── exchanges/
│   │   ├── create_request_dialog.dart
│   │   └── exchange_requests_screen.dart
│   ├── explore/
│   │   └── explore_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── category_list_view.dart
│   │       ├── greeting_header.dart
│   │       ├── home_search_bar.dart
│   │       ├── perfect_match_banner.dart
│   │       └── recommended_list_view.dart
│   ├── matches/
│   │   └── explore_matches_screen.dart
│   ├── notifications/
│   │   └── notifications_screen.dart
│   ├── profile/
│   │   ├── edit_profile_screen.dart
│   │   ├── my_profile_tab.dart
│   │   └── student_profile_screen.dart
│   └── main_navigation_wrapper.dart # Bottom navigation container
├── services/
│   ├── auth_service.dart           # Firebase Auth integration
│   ├── firebase_service.dart       # Safe initialization manager
│   ├── firestore_service.dart      # Firestore typed CRUD operations
│   ├── matching_service.dart       # Explainable skill matching engine
│   └── sample_data_service.dart    # Safe demo student seeder
└── main.dart                       # App entrypoint with MultiProvider
```

---

## ⚡ Firebase Setup Guide

Follow these exact steps using the FlutterFire CLI:

### Step 1: Install Firebase CLI & FlutterFire CLI
In PowerShell / Command Prompt:
```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

### Step 2: Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it `skill-loop` (or your preferred name).
3. Disable or enable Google Analytics (optional).

### Step 3: Enable Authentication & Firestore
1. In the Firebase Console, navigate to **Build > Authentication > Get Started**.
2. Under Sign-in method, enable **Email/Password** (leave Email link disabled).
3. Navigate to **Build > Firestore Database > Create database**.
4. Choose **Start in production mode** (we deploy strict security rules next).
5. Select your preferred Cloud Firestore server location.

### Step 4: Configure FlutterFire for Android
Run the following command from the project root:
```powershell
flutterfire configure --project=<your-firebase-project-id> --platforms=android
```
*Note: The Android application ID is `com.example.skill_loop` (configured in `android/app/build.gradle.kts`).*

FlutterFire CLI will generate:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- Apply the Google Services Gradle plugin to `android/build.gradle.kts` and `android/app/build.gradle.kts`.

### Step 5: Deploy Security Rules
In your project directory, deploy the included `firestore.rules` and `storage.rules`:
```powershell
firebase deploy --only firestore:rules,storage
```

If the Firebase CLI is not installed, open **Firestore Database > Rules** in
Firebase Console, replace the rules with the contents of `firestore.rules`, and
click **Publish**. Do not use test mode or unrestricted rules.

### Skill-description compatibility

Existing `users` documents keep `skillsToTeach` as `List<String>`, so search,
matching, requests, and existing data keep working. New descriptions are saved
in the additive map below; no migration or deletion is required.

```text
skillsToTeach: ["Flutter", "Dart"]
teachingSkillDescriptions: {
  "Flutter": "I can teach widgets, layouts, navigation and basic mobile app development."
}
```

Demo profiles contain predefined descriptions in the app seed source. Real
students supply their own descriptions in **Edit Profile**; the app does not
generate or replace them.

---

## 🔒 Firestore Database Schema

### `users/{userId}`
| Field | Type | Description |
|---|---|---|
| `fullName` | String | Student's full name |
| `email` | String | College email |
| `college` | String | College / University name |
| `department` | String | Academic department (e.g. CSE, ECE) |
| `year` | String | Year of study (e.g. 3rd Year) |
| `bio` | String | Short bio / introduction |
| `photoUrl` | String | Avatar image URL |
| `skillsToTeach` | List<String> | Skills student can teach |
| `skillsToLearn` | List<String> | Skills student wants to learn |
| `isAvailable` | Boolean | Availability toggle |
| `averageRating` | Double | Aggregate peer rating (1.0 - 5.0) |
| `reviewCount` | Integer | Total reviews received |
| `completedExchanges`| Integer | Total completed exchanges |
| `isDemo` | Boolean | True for sample/test students |
| `createdAt` | Timestamp | Account creation timestamp |
| `updatedAt` | Timestamp | Last update timestamp |

### `exchangeRequests/{requestId}`
| Field | Type | Description |
|---|---|---|
| `senderId` | String | Auth UID of requesting student |
| `receiverId` | String | Auth UID of target student |
| `senderName` | String | Display name of sender |
| `receiverName` | String | Display name of receiver |
| `senderPhotoUrl`| String | Avatar URL of sender |
| `receiverPhotoUrl`| String | Avatar URL of receiver |
| `offeredSkill` | String | Skill offered by sender |
| `requestedSkill`| String | Skill desired from receiver |
| `message` | String | Optional exchange message |
| `status` | String | `pending` \| `accepted` \| `rejected` \| `completed` |
| `createdAt` | Timestamp | Request creation timestamp |
| `updatedAt` | Timestamp | Status update timestamp |

### `conversations/{conversationId}`
| Field | Type | Description |
|---|---|---|
| `participantIds` | List<String> | Array of the 2 student UIDs |
| `participantNames` | Map<UID, Name> | Name mapping for participants |
| `participantPhotos` | Map<UID, URL> | Avatar mapping for participants |
| `lastMessage` | String | Preview text of last message |
| `lastMessageSenderId` | String | Sender UID of last message |
| `lastMessageAt` | Timestamp | Timestamp of last message |
| `relatedRequestId` | String? | Associated exchange request ID |

#### Subcollection: `conversations/{conversationId}/messages/{messageId}`
| Field | Type | Description |
|---|---|---|
| `senderId` | String | UID of message author |
| `text` | String | Message content |
| `createdAt` | Timestamp | Sent timestamp |
| `readAt` | Timestamp? | Read receipt timestamp |

### `reviews/{reviewId}`
| Field | Type | Description |
|---|---|---|
| `exchangeRequestId` | String | Verified completed exchange ID |
| `reviewerId` | String | UID of author |
| `reviewerName` | String | Name of author |
| `reviewerPhotoUrl` | String | Avatar URL of author |
| `revieweeId` | String | Target student UID receiving rating |
| `rating` | Double | Star rating (1.0 to 5.0) |
| `comment` | String | Feedback text |
| `createdAt` | Timestamp | Review submission timestamp |

### `notifications/{notificationId}`
| Field | Type | Description |
|---|---|---|
| `recipientId` | String | Target student UID |
| `type` | String | `request_received` \| `request_accepted` \| `request_rejected` \| `new_message` \| `exchange_completed` \| `review_received` |
| `title` | String | Notification header |
| `body` | String | Notification message |
| `relatedId` | String | Related request or conversation ID |
| `isRead` | Boolean | Read state |
| `createdAt` | Timestamp | Timestamp |

---

## 🚀 Running the App

### Get dependencies:
```powershell
flutter pub get
```

### Run static analysis:
```powershell
flutter analyze
```

### Run test suite:
```powershell
flutter test
```

### Run the app on your connected Android phone:
```powershell
flutter run -d <your-android-device-id>
```
*(Or simply run `flutter run` and select your device from the list).*

---

## 🧪 Testing and Demo Data

1. **Before Firebase is Configured**:
   - The app includes offline demo fallback data (`Abinaya` as current user, `Priya S.` and `Rahul K.` as peers). All navigation, search, filters, matching algorithms, and UI flows can be explored immediately.
2. **After Firebase is Configured**:
   - Navigate to the **Profile** tab.
   - Under **Developer & Demo Tools**, tap **Seed Demo Data**. This will populate Firestore with 5 diverse sample student profiles (`isDemo: true`) across different engineering and design departments.
   - You can clear demo records at any time by tapping **Clear Demo Data**.
3. **Multi-User Testing**:
   - Create two student accounts in the app (e.g. `student1@college.edu` and `student2@college.edu`).
   - Propose an exchange from student 1 to student 2.
   - Log into student 2 to accept the request, start the chat, and mark the exchange as completed.
   - Each participant can leave one review for the completed exchange. A second
     submission is rejected.

---

## 🛡 Security Rules Overview

- **Profiles**: Authenticated users can read public student profiles; users can only modify their own profile document. Client edits cannot alter reputation fields.
- **Exchange Requests**: Only direct participants can read a request. Only its receiver can accept or decline it; either participant can complete an accepted request.
- **Messaging**: Only members listed in `participantIds` can read or post messages to a conversation thread.
- **Reviews**: Only a participant of a verified completed exchange can post one immutable rating for the other participant, constrained between 1.0 and 5.0.
- **Notifications**: Strictly accessible only by the `recipientId`.
- **Storage**: Image uploads restricted to authenticated users for their own folder with a 5MB size ceiling and MIME type validation.

---

## 🔮 Future Improvements

- **Trusted reputation aggregates**: Included in `functions/index.js`. Deploy the functions to update `averageRating`, `reviewCount`, and `completedExchanges` after their related Firestore events.
- **Push Notifications**: Firebase Cloud Messaging (FCM) is not configured. To add push delivery, enable Cloud Messaging in Firebase, add `firebase_messaging`, create Android notification channels, request notification permission, and send notifications from a trusted server or Cloud Function. The current notifications are in-app Firestore notifications only.
- **Profile photo picker**: The Android gallery picker is included. Firebase Storage must be created and its rules deployed before uploads can succeed.

## Firebase Functions: profile totals

Profile reputation fields are server-managed, so one student cannot forge another
student's rating or exchange count. From the project root, install and deploy
the included functions:

```powershell
cd functions
npm install
cd ..
firebase deploy --only functions --project skill-loop-95ba4
```

Cloud Functions deployment requires Firebase's Blaze billing plan. Set a budget
alert before deploying; this project does not deploy functions automatically.

`updateProfileRating` runs only when a review document is created. It updates
the reviewee's average rating and review count. `incrementCompletedExchangeCounts`
runs only when an exchange request changes to `completed`, then increments both
participants' completed-exchange totals once.
- **Audio/Video Calls**: WebRTC or Agora integration for live virtual skill sessions directly in the app.
- **Calendar Scheduling**: Calendar invite synchronization for agreed exchange time slots.
