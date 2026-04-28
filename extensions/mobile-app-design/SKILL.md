---
name: mobile-app-design
description: Domain extension for mobile application architecture. Use when the project involves iOS, Android, or cross-platform mobile apps with backend integration. Dynamically loaded by devforge-architecture-design when PRD contains mobile characteristic tags.
---

# Mobile App Design Extension

## Overview

This extension augments the generic `devforge-architecture-design` skill with mobile-specific evaluation dimensions, anti-patterns, and architecture guidance. Loaded when PRD contains tags like `mobile_app`, `ios`, `android`, `react_native`, `flutter`.

## When to Load

- PRD mentions: Mobile app, iOS, Android, push notifications, offline-first, mobile backend
- Project characteristic tags include: `mobile_app`, `offline_first`, `multi_platform`

## Overlay Rules

### Additional Dimensions

| Dimension | Weight | Description |
|-----------|--------|-------------|
| Offline Support | 1.1x | How does the pattern handle connectivity loss and local data? |
| Battery Efficiency | 1.0x | Does the pattern minimize background activity and network calls? |
| Push Delivery | 1.0x | How naturally does the pattern integrate push notification delivery? |
| Screen Adaptation | 0.8x | Does the pattern support responsive/adaptive layouts across devices? |
| Store Compliance | 0.9x | Does the pattern respect app store policies (background limits, privacy)? |

### Mandatory Modules

- `MobileClient`: App shell, navigation, local state management
- `SyncEngine`: Offline queue, conflict resolution, background sync
- `PushHandler`: Notification routing, deep linking, in-app handling
- `BFF-Mobile`: Mobile-optimized backend, payload aggregation, caching
- `AnalyticsCollector`: Event tracking, session management, crash reporting

### Interface Additions

| Interface | Input | Output | Error Codes |
|-----------|-------|--------|-------------|
| `sync_data` | `SyncRequest` | `SyncResult` | 409 (conflict), 412 (sync token expired), 429 (rate limit) |
| `send_push` | `PushNotification` | `DeliveryReceipt` | 410 (device unregistered), 429 (provider rate limit) |
| `upload_analytics` | `EventBatch` | `Ack` | 413 (batch too large), 422 (invalid event) |

## References

- `references/offline-first.md` — Offline queue patterns, conflict resolution strategies
- `references/push-notification.md` — Push delivery architectures, retry and fallback
