# NIVASA — Production Firestore Database Schema

**Version:** 1.0  
**Backend:** Google Cloud Firestore + Firebase Storage + Firebase Auth  
**Project:** `homefixvit`  
**Last updated:** 2026-06-15

---

## Design principles

| Principle | Implementation |
|-----------|----------------|
| **Single source of truth** | Firestore is the system of record; no parallel mock stores in production |
| **Schema versioning** | Every document carries `schemaVersion` for safe migrations |
| **Auditability** | `createdAt`, `updatedAt`, `createdBy`; status changes logged in subcollections |
| **Least privilege** | Security rules enforce role, ownership, and immutable admin fields |
| **Denormalization** | Worker name on tickets for fast mobile reads |
| **Idempotency** | Payments keyed by `idempotencyKey`; subscriptions 1:1 with `userId` |
| **Soft delete** | `isDeleted` flag — never hard-delete customer data from clients |
| **Server timestamps** | All temporal fields use `FieldValue.serverTimestamp()` on write |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Firebase Auth                             │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                     Cloud Firestore                              │
│  ┌──────────┐  ┌───────────────┐  ┌─────────────────┐          │
│  │  users   │──│ subscriptions │  │ service_requests │         │
│  └──────────┘  └───────────────┘  └────────┬────────┘          │
│       │              │                      │                    │
│       │         ┌────▼────┐          ┌──────▼──────┐             │
│       │         │ payments│          │status_history│ (subcoll)  │
│       │         └─────────┘          └─────────────┘             │
│       │                              ┌──────────┐                │
│       └──────────────────────────────│ workers  │                │
│                                      └──────────┘                │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐            │
│  │ notifications│  │   reviews    │  │ app_config  │            │
│  └──────────────┘  └──────────────┘  └─────────────┘            │
│  ┌──────────────┐                                                │
│  │   counters   │  ← atomic ticket IDs (transaction)           │
│  └──────────────┘                                                │
└─────────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                    Firebase Storage                              │
│  users/{uid}/avatar.*                                            │
│  service_requests/{requestId}/{uuid}.jpg                         │
│  payments/{uid}/proof_{paymentId}.jpg                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Global field conventions

Every top-level document SHOULD include:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `schemaVersion` | number | yes | Current: `1` |
| `createdAt` | timestamp | yes | Server timestamp on create |
| `updatedAt` | timestamp | yes | Server timestamp on every write |
| `isDeleted` | boolean | yes | Default `false`; soft delete |

---

## Collections

### 1. `users/{userId}`

| Field | Type | Required | Mutable by | Description |
|-------|------|----------|------------|-------------|
| `uid` | string | yes | — (immutable) | Firebase Auth UID |
| `name` | string | yes | owner, admin | Display name |
| `email` | string | yes | — (immutable) | From Auth |
| `phone` | string | yes | owner, admin | E.164 or `+91 …` |
| `photoUrl` | string | no | owner | Profile image URL |
| `address` | string | no | owner | Service address |
| `authProvider` | enum | yes | — | `email` \| `google` |
| `role` | enum | yes | admin only | `customer` \| `technician` \| `admin` |
| `onboardingCompleted` | boolean | yes | owner | Default `false` |
| `fcmToken` | string | no | owner | Push notification token |
| `lastLoginAt` | timestamp | no | system | Updated on sign-in |

**Indexes:** `role` + `createdAt` (admin dashboard)

**Security:** Users cannot self-promote to `admin` or `technician`.

---

### 2. `subscriptions/{userId}`

Document ID = user UID (enforces 1 active subscription record per user).

| Field | Type | Required | Mutable by | Description |
|-------|------|----------|------------|-------------|
| `userId` | string | yes | — (immutable) | Owner UID |
| `email` | string | yes | owner | Billing email |
| `name` | string | yes | owner | Subscriber name |
| `mobile` | string | yes | owner | Primary contact |
| `alternateMobile` | string | no | owner | Secondary contact |
| `address` | string | yes | owner | Service location |
| `planType` | enum | yes | owner (create) | `monthly` \| `yearly` |
| `amount` | number | yes | admin | INR amount |
| `currency` | string | yes | — | Always `INR` |
| `subscriptionStartDate` | timestamp | yes | admin | Plan start |
| `subscriptionEndDate` | timestamp | yes | admin | Plan expiry |
| `paymentStatus` | enum | yes | admin* | See enum below |
| `paymentMethod` | enum | no | owner (create) | `upi_manual` \| `razorpay` |
| `paymentReference` | string | no | owner | UPI ref / gateway ID |
| `autoRenew` | boolean | no | owner | Default `false` |
| `cancelledAt` | timestamp | no | admin | Cancellation time |
| `cancelReason` | string | no | owner/admin | Free text |

**`paymentStatus` enum**

| Value | Who sets | Meaning |
|-------|----------|---------|
| `pending` | customer (create) | Awaiting verification |
| `active` | admin / Cloud Function | Verified + valid dates |
| `done` | legacy | Treat as `active` in app |
| `expired` | Cloud Function (scheduled) | Past end date |
| `cancelled` | admin | Manually cancelled |
| `rejected` | admin | Payment proof rejected |

**Critical rule:** Customers may only set `paymentStatus` to `pending` on create/update. Only admin can set `active`.

---

### 3. `service_requests/{requestId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `requestId` | string | yes | Public ticket `NVS-10001` |
| `userId` | string | yes | Customer UID (immutable) |
| `category` | enum | yes | See categories below |
| `issueTitle` | string | yes | Max 120 chars |
| `description` | string | yes | Max 2000 chars |
| `location` | string | yes | Flat / tower |
| `contactPhone` | string | yes | Callback number |
| `notes` | string | no | Max 500 chars |
| `priority` | enum | yes | `low` \| `medium` \| `high` \| `emergency` |
| `scheduledDate` | timestamp | no | Preferred date |
| `timeSlot` | string | no | e.g. `10:00 AM – 12:00 PM` |
| `status` | enum | yes | Lifecycle (see below) |
| `assignedWorkerId` | string | no | `workers/{id}` |
| `assignedWorkerName` | string | no | Denormalized |
| `aiAnalysis` | map | no | AI urgency payload |
| `imageUrls` | array\<string\> | no | Storage URLs |
| `subscriptionActive` | boolean | yes | Snapshot at submit |
| `completedAt` | timestamp | no | Resolution time |
| `cancelledAt` | timestamp | no | If cancelled |
| `cancelReason` | string | no | Why cancelled |

**Categories:** `plumbing`, `electrical`, `cleaning`, `internet_wifi`, `security`, `appliance_repair`, `water_leakage`, `other`

**Status lifecycle**

```
requested → finding_technician → assigned → in_progress → on_the_way → completed
                                                                    ↘ cancelled (any stage before completed)
```

**Subcollection: `service_requests/{id}/status_history/{entryId}`**

| Field | Type | Description |
|-------|------|-------------|
| `fromStatus` | string | Previous status |
| `toStatus` | string | New status |
| `changedBy` | string | UID or `system` |
| `changedByRole` | enum | `customer` \| `technician` \| `admin` \| `system` |
| `note` | string | Optional comment |
| `createdAt` | timestamp | Event time |

---

### 4. `workers/{workerId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workerId` | string | yes | Document ID |
| `name` | string | yes | Full name |
| `phone` | string | yes | Contact |
| `type` | enum | yes | `plumber` \| `electrician` \| `general` |
| `skills` | array\<string\> | no | Skill tags |
| `rating` | number | no | 0.0–5.0 |
| `ratingCount` | number | no | Review count |
| `location` | string | yes | Base area |
| `serviceAreas` | array\<string\> | no | Coverage zones |
| `available` | boolean | yes | Accepting jobs |
| `linkedUserId` | string | no | App login UID |
| `verified` | boolean | yes | Admin KYC flag |

---

### 5. `payments/{paymentId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `paymentId` | string | yes | Document ID |
| `userId` | string | yes | Payer (immutable) |
| `subscriptionId` | string | yes | Usually = userId |
| `amount` | number | yes | INR |
| `currency` | string | yes | `INR` |
| `planType` | enum | yes | `monthly` \| `yearly` |
| `status` | enum | yes | `pending` \| `verified` \| `failed` \| `refunded` |
| `method` | enum | yes | `upi_manual` \| `razorpay` |
| `gatewayReference` | string | no | External txn ID |
| `idempotencyKey` | string | yes | `{userId}_{planType}_{date}` — prevents duplicates |
| `proofImageUrl` | string | no | UPI screenshot |
| `verifiedBy` | string | no | Admin UID |
| `verifiedAt` | timestamp | no | Verification time |
| `failureReason` | string | no | If failed |

---

### 6. `reviews/{reviewId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reviewId` | string | yes | Document ID |
| `requestId` | string | yes | Linked ticket |
| `userId` | string | yes | Reviewer |
| `workerId` | string | yes | Reviewed worker |
| `rating` | number | yes | 1–5 |
| `comment` | string | no | Max 1000 chars |
| `createdAt` | timestamp | yes | |

**Constraint:** One review per `requestId` (enforce in app + Cloud Function).

---

### 7. `notifications/{notificationId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | string | yes | Recipient |
| `type` | enum | yes | `service_update` \| `payment` \| `subscription` \| `system` |
| `title` | string | yes | |
| `body` | string | yes | |
| `data` | map | no | Deep-link payload |
| `read` | boolean | yes | Default `false` |
| `expiresAt` | timestamp | no | TTL for cleanup |

---

### 8. `app_config/pricing` (singleton)

| Field | Type | Description |
|-------|------|-------------|
| `monthlyPrice` | number | Default `300` |
| `yearlyPrice` | number | Default `3600` |
| `currency` | string | `INR` |
| `emergencySlaMinutes` | number | Default `120` |
| `maxOpenRequestsPerUser` | number | Default `3` |
| `updatedAt` | timestamp | |

Read-only for clients; admin writes via console or admin SDK.

---

### 9. `counters/service_tickets` (singleton)

| Field | Type | Description |
|-------|------|-------------|
| `lastNumber` | number | Incremented via transaction |
| `updatedAt` | timestamp | |

Generates public IDs: `NVS-{lastNumber}`.

---

## Firebase Storage layout

| Path | Max size | Allowed types | Access |
|------|----------|---------------|--------|
| `users/{uid}/avatar.jpg` | 2 MB | image/jpeg, image/png | owner read/write |
| `service_requests/{requestId}/{fileId}.jpg` | 5 MB | image/jpeg, image/png | owner + admin |
| `payments/{uid}/proof_{paymentId}.jpg` | 5 MB | image/jpeg, image/png | owner + admin |

---

## Composite indexes

Defined in `firestore.indexes.json` at repo root. Deploy with:

```bash
firebase deploy --only firestore:indexes,firestore:rules,storage
```

---

## Cloud Functions (recommended for production)

| Function | Trigger | Purpose |
|----------|---------|---------|
| `onPaymentVerified` | Admin updates payment | Set subscription `active`, send notification |
| `expireSubscriptions` | Scheduled daily | Set `paymentStatus: expired` |
| `onRequestStatusChange` | `service_requests` update | Append `status_history`, notify user |
| `onReviewCreated` | `reviews` create | Recalculate worker `rating` |
| `razorpayWebhook` | HTTPS | Verify gateway payments |

---

## Migration from current app

| Current field | Production field | Action |
|---------------|------------------|--------|
| `provider` (Google) | `authProvider` | Write `authProvider`; read both |
| `paymentStatus: done` | `active` | Map in app layer |
| Mock service submit | `service_requests` | Use `ServiceRequestRepository` |
| `demo_workers.dart` | `workers` collection | Seed via admin script |

---

## Implementation status

| Artifact | Path | Status |
|----------|------|--------|
| Schema spec | `docs/database-schema.md` | ✅ |
| Security rules | `firestore.rules` | ✅ Production-hardened |
| Storage rules | `storage.rules` | ✅ |
| Indexes | `firestore.indexes.json` | ✅ |
| Firebase config | `firebase.json` | ✅ |
| Dart constants | `lib/core/db/` | ✅ |
| Repositories | `lib/services/repositories/` | ✅ |
