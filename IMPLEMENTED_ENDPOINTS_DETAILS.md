# Implemented Endpoints Details

This document lists all the backend endpoints that have been successfully integrated into the Flutter frontend. It includes the required parameters and the exact Dart files where they are implemented.

## 1. Authentication (`/api/v1/auth`)
**Repository File:** `lib/features/authentication/repositories/auth_repository.dart`
**Screens using it:** `SignInScreen`, `SignUpScreen`, `ForgotPasswordScreen`, `ResetPasswordScreen`, `SplashScreen`

| Endpoint | Method | Parameters (Body / Path) | Description |
|----------|--------|-------------------------|-------------|
| `/api/v1/auth/login` | `POST` | `{ "email": "...", "password": "..." }` | Authenticates a user and retrieves JWT token. |
| `/api/v1/auth/register` | `POST` | `{ "fullName": "...", "email": "...", "adminPassword": "...", "subdomain": "..." }` | Registers a new account. |
| `/api/v1/auth/resend-verification`| `POST` | `{ "email": "..." }` | Resends OTP email verification. |
| `/api/v1/auth/forgot-password` | `POST` | `{ "email": "..." }` | Requests a password reset OTP. |
| `/api/v1/auth/reset-password` | `POST` | `{ "token": "...", "newPassword": "..." }` | Resets password using OTP as token. |
| `/api/v1/auth/logout` | `POST` | None | Clears the session token. |
| `/api/v1/auth/me` | `GET` | None | Retrieves authenticated user profile details. |

---

## 2. Dashboard (`/api/v1/field-sales/stats`)
**Repository File:** `lib/features/dashboard/repositories/dashboard_repository.dart`
**Screens using it:** `DashboardScreen` (`lib/features/dashboard/screens/dashboard_screen.dart`)

| Endpoint | Method | Parameters (Body / Path) | Description |
|----------|--------|-------------------------|-------------|
| `/api/v1/field-sales/stats` | `GET` | None | Fetches aggregate KPIs and target progress for the dashboard. |

---

## 3. Notifications (`/api/v1/notifications`)
**Repository File:** `lib/features/dashboard/repositories/notification_repository.dart`
**Screens using it:** `NotificationsScreen` (`lib/features/dashboard/screens/notifications_screen.dart`)

| Endpoint | Method | Parameters (Body / Path) | Description |
|----------|--------|-------------------------|-------------|
| `/api/v1/notifications` | `GET` | None | Fetches list of notifications for the user. |
| `/api/v1/notifications/read-all`| `PATCH` | None | Marks all unread notifications as read. |

---

## 4. Leads Management (`/api/v1/leads`)
**Repository File:** `lib/features/leads/repositories/leads_repository.dart`
**Screens using it:** `LeadsListScreen` (`lib/features/leads/screens/leads_list_screen.dart`)

| Endpoint | Method | Parameters (Body / Path) | Description |
|----------|--------|-------------------------|-------------|
| `/api/v1/leads` | `GET` | None | Fetches all sales leads assigned to the user. |
| `/api/v1/leads/:id/status`| `PATCH` | **Path:** `id`<br>**Body:** `{ "status": "..." }` | Updates the stage/status of a specific lead. |

---

## 5. Visits & Field Sales (`/api/v1/field-sales`)
**Repository File:** `lib/features/visits/repositories/visits_repository.dart`
**Screens using it:** `VisitsListScreen` (`lib/features/visits/screens/visits_list_screen.dart`), `ScheduleVisitScreen` (`lib/features/visits/screens/schedule_visit_screen.dart`)

| Endpoint | Method | Parameters (Body / Path) | Description |
|----------|--------|-------------------------|-------------|
| `/api/v1/field-sales/visits` | `GET` | None | Fetches field visits and daily schedules. |
| `/api/v1/field-sales/visits` | `POST` | `{ "time": "...", "status": "...", "meetingType": "...", "companyName": "...", "contactName": "...", "contactRole": "...", "locationAddress": "...", "dayOfMonth": 8, "distanceKm": 1.2, "duration": "...", "notes": "..." }` | Schedules a new visit. |
| `/api/v1/field-sales/checkin` | `POST` | `{ "visitId": "..." }` | Check-in to an active/upcoming visit. |
| `/api/v1/field-sales/checkout`| `POST` | `{ "visitId": "..." }` | Check-out to mark an in-progress visit as completed. |
