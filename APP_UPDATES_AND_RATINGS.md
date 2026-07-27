# App Updates & In-App Reviews Guide (BlithePay Mobile)

This document details the configuration, implementation, and operational guide for **In-App Updates** (via `upgrader`) and **In-App Store Ratings/Reviews** (via `in_app_review`).

---

## 1. Required Configuration Parameters

To fully complete the store integrations, provide the following details (or placeholders can be used during staging/development):

| Parameter | Description | Required For | Location / File Path |
|-----------|-------------|--------------|----------------------|
| **iOS App Store ID** | Numerical App ID from Apple App Store Connect (e.g. `6470000000`) | iOS In-App Upgrades & Review Fallbacks | [Env.appStoreId](file:///c:/Workspace/blithepay-mobile/lib/core/config/env.dart#L8) |
| **Android Package Name** | Package ID registered on Google Play Store | Android In-App Upgrades | Auto-detected from `pubspec.yaml` / `build.gradle` |
| **Update Prompt Policy** | Soft Update (dismissible) vs. Forced Update (blocks app usage until updated) | `upgrader` config | Configurable in [DashboardView](file:///c:/Workspace/blithepay-mobile/lib/features/dashboard/presentation/views/dashboard_view.dart) |
| **Rating Trigger Moments** | Key user actions to trigger rating dialogs | `in_app_review` service | [SuccessView](file:///c:/Workspace/blithepay-mobile/lib/features/common/presentation/views/success_view.dart) / [RatingService](file:///c:/Workspace/blithepay-mobile/lib/core/services/rating_service.dart) |

---

## 2. In-App Updates Strategy (`upgrader`)

### Overview
The `upgrader` package checks Google Play Store and Apple App Store metadata on app launch. When a newer version than `pubspec.yaml` (e.g. `1.0.2+1`) is published on the store, a native alert/dialog prompts the user.

### Key Capabilities
- **Automatic Version Comparison**: Reads installed version vs. published store version.
- **Customizable UI**: Styled using Material/Cupertino dialogs with BlithePay branding.
- **Flexible Rules**: Can allow user to skip versions or require immediate update.

### Integration Architecture
Wrapped around the main Dashboard layout ([DashboardView](file:///c:/Workspace/blithepay-mobile/lib/features/dashboard/presentation/views/dashboard_view.dart)) so that authenticated users are prompted upon landing on their home dashboard.

---

## 3. In-App Ratings & Feedback Strategy (`in_app_review`)

### Overview
The `in_app_review` package uses Google Play's **In-App Review API** and iOS **SKStoreReviewController**. It displays the store rating stars popup directly within the app without redirecting the user away.

### Best Practice Rules & Quotas
1. **Store Quota Limits**:
   - iOS limits rating prompts to 3 times per 365-day period per user.
   - Android Play Store manages quotas dynamically per device.
2. **Positive Trigger Moments**:
   - Prompts are triggered **only** after high-satisfaction user milestones (e.g. successful fee payments, successful wallet funding).
3. **Fallback**:
   - If the in-app review popup is unavailable or quota is reached, it gracefully falls back to opening the store listing page.

---

## 4. Implementation Steps

1. **Add Dependencies to `pubspec.yaml`**:
   - `upgrader: ^11.0.0`
   - `in_app_review: ^2.0.9`
2. **Create `RatingService` Utility**:
   - `lib/core/services/rating_service.dart` for managing rating prompts and storing last prompted timestamp locally to prevent spamming users.
3. **Integrate `UpgradeAlert`**:
   - Enclose `DashboardView` with `UpgradeAlert(upgrader: Upgrader(...))`.
4. **Trigger Ratings in Feature Flow**:
   - Call `RatingService().promptReviewIfEligible()` on payment success view or payment confirmation.
