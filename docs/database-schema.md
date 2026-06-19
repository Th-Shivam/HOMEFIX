# NIVASA — Production Firestore Database Schema v2

**Version:** 2.0  
**Backend:** Cloud Firestore + Firebase Storage + Firebase Auth  
**Project:** `homefixvit`

Supports full UI flow: **Home → Raise Request → Track → Chat → Invoice → Membership**

---

## Entity overview (20 collections)

| # | Collection | Doc ID | Purpose |
|---|------------|--------|---------|
| 1 | `users` | Auth UID | Customer / technician / admin profile |
| 2 | `addresses` | Auto | Saved addresses (multiple per user) |
| 3 | `service_categories` | Auto / slug | Plumbing, Electrical, etc. |
| 4 | `service_requests` | Auto | Core ticket entity |
| 5 | `request_assignments` | Auto | Assignment + reassignment history |
| 6 | `request_images` | Auto | Before / after / invoice photos |
| 7 | `chat_messages` | Auto | Per-request chat |
| 8 | `status_history` | Auto | Audit log (also subcollection) |
| 9 | `workers` | Auto | Technician profiles |
| 10 | `worker_location_tracking` | Auto | Live GPS pings |
| 11 | `reviews` | Auto | Post-job ratings |
| 12 | `payments` | Auto | All payment records |
| 13 | `invoices` | Auto | Generated invoices |
| 14 | `subscriptions` | Auto | Membership records (multiple per user) |
| 15 | `membership_plans` | Auto / slug | Plan catalog |
| 16 | `notifications` | Auto | Push / in-app |
| 17 | `emergency_contacts` | Auto | Profile emergency contacts |
| 18 | `support_tickets` | Auto | Customer support |
| 19 | `app_config` | Singleton | Global settings |
| 20 | `counters` | Singleton | Atomic IDs |

---

## Global fields (every document)

| Field | Type | Required |
|-------|------|----------|
| `schemaVersion` | number | yes (`2`) |
| `createdAt` | timestamp | yes |
| `updatedAt` | timestamp | yes |
| `isDeleted` | boolean | yes (default `false`) |

---

## 1. `users/{userId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `uid` | string | yes | PK, immutable |
| `name` | string | yes | |
| `email` | string | yes | immutable |
| `phone` | string | yes | |
| `photoUrl` | string | no | |
| `defaultAddressId` | string | no | FK → `addresses` |
| `authProvider` | enum | yes | `email` \| `google` |
| `role` | enum | yes | `customer` \| `technician` \| `admin` |
| `onboardingCompleted` | boolean | yes | |
| `fcmToken` | string | no | |
| `lastLoginAt` | timestamp | no | |

---

## 2. `addresses/{addressId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `addressId` | string | yes | PK |
| `userId` | string | yes | FK → `users` |
| `label` | string | yes | Home, Office, Tower A |
| `houseNumber` | string | no | Flat 204 |
| `street` | string | yes | Street / society |
| `city` | string | yes | |
| `state` | string | yes | |
| `pincode` | string | yes | |
| `latitude` | number | no | |
| `longitude` | number | no | |
| `isDefault` | boolean | yes | One default per user |

**Relationships:** `users` 1→N `addresses`; `service_requests.addressId` → `addresses`

---

## 3. `service_categories/{categoryId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `categoryId` | string | yes | PK e.g. `plumbing` |
| `name` | string | yes | Plumbing |
| `icon` | string | no | Icon key / URL |
| `description` | string | no | |
| `isActive` | boolean | yes | |
| `sortOrder` | number | no | |

---

## 4. `service_requests/{requestId}`

Core entity — expanded for production.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `requestId` | string | yes | Public ticket `NVS-10001` |
| `userId` | string | yes | FK → `users` |
| `categoryId` | string | yes | FK → `service_categories` |
| `title` | string | yes | Short title (max 120) |
| `description` | string | yes | Full problem detail |
| `addressId` | string | yes | FK → `addresses` |
| `contactPhone` | string | yes | Callback number |
| `priority` | enum | yes | `low` \| `medium` \| `high` \| `emergency` |
| `status` | enum | yes | Lifecycle enum |
| `scheduledAt` | timestamp | no | Preferred slot start |
| `timeSlot` | string | no | `10:00 AM – 12:00 PM` |
| `requestedAt` | timestamp | yes | When submitted |
| `completedAt` | timestamp | no | |
| `cancelledAt` | timestamp | no | |
| `cancelReason` | string | no | |
| `estimatedCost` | number | no | INR |
| `finalCost` | number | no | INR after job |
| `notes` | string | no | Customer notes |
| `aiAnalysis` | map | no | Urgency AI result |
| `subscriptionId` | string | no | FK if membership used |
| `activeAssignmentId` | string | no | Current assignment |
| `invoiceId` | string | no | FK → `invoices` |

**Status:** `requested` → `finding_technician` → `assigned` → `in_progress` → `on_the_way` → `completed` | `cancelled`

---

## 5. `request_assignments/{assignmentId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `assignmentId` | string | yes | PK |
| `requestId` | string | yes | FK → `service_requests` |
| `workerId` | string | yes | FK → `workers` |
| `assignedAt` | timestamp | yes | |
| `assignedBy` | string | yes | Admin / system UID |
| `status` | enum | yes | `active` \| `completed` \| `reassigned` \| `cancelled` |
| `unassignedAt` | timestamp | no | |
| `remarks` | string | no | |

---

## 6. `request_images/{imageId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `imageId` | string | yes | PK |
| `requestId` | string | yes | FK |
| `imageUrl` | string | yes | Storage URL |
| `uploadedBy` | string | yes | UID |
| `uploadedAt` | timestamp | yes | |
| `type` | enum | yes | `before` \| `after` \| `invoice` \| `other` |

*Also available as subcollection: `service_requests/{id}/request_images/{imageId}`*

---

## 7. `chat_messages/{messageId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `messageId` | string | yes | PK |
| `requestId` | string | yes | FK |
| `senderId` | string | yes | UID |
| `senderRole` | enum | yes | `customer` \| `worker` \| `admin` |
| `message` | string | yes | |
| `sentAt` | timestamp | yes | |
| `status` | enum | yes | `sent` \| `delivered` \| `read` |

*Recommended subcollection: `service_requests/{id}/chat_messages/{messageId}`*

---

## 8. `status_history/{entryId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `entryId` | string | yes | PK |
| `requestId` | string | yes | FK (required) |
| `fromStatus` | string | yes | |
| `toStatus` | string | yes | |
| `changedBy` | string | yes | UID or `system` |
| `changedByRole` | enum | yes | `customer` \| `worker` \| `admin` \| `system` |
| `remarks` | string | no | |
| `createdAt` | timestamp | yes | |

*Subcollection: `service_requests/{id}/status_history/{entryId}`*

---

## 9. `workers/{workerId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `workerId` | string | yes | PK |
| `linkedUserId` | string | no | FK → `users` |
| `name` | string | yes | |
| `phone` | string | yes | |
| `email` | string | no | |
| `profilePhoto` | string | no | |
| `type` | enum | yes | `plumber` \| `electrician` \| `general` |
| `experience` | number | no | Years |
| `aadhaarVerified` | boolean | yes | |
| `backgroundVerified` | boolean | yes | |
| `skills` | array | no | |
| `serviceAreas` | array | no | |
| `currentLocation` | geopoint | no | Last known |
| `available` | boolean | yes | |
| `rating` | number | no | 0–5 |
| `ratingCount` | number | no | |
| `totalJobsCompleted` | number | no | |
| `avgResponseTimeMinutes` | number | no | |
| `joinedAt` | timestamp | yes | |

---

## 10. `worker_location_tracking/{trackingId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `trackingId` | string | yes | PK |
| `workerId` | string | yes | FK |
| `requestId` | string | no | Active job context |
| `latitude` | number | yes | |
| `longitude` | number | yes | |
| `timestamp` | timestamp | yes | |

TTL: auto-delete entries older than 7 days (Cloud Function).

---

## 11. `reviews/{reviewId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `reviewId` | string | yes | PK |
| `requestId` | string | yes | FK, unique per request |
| `userId` | string | yes | FK reviewer |
| `workerId` | string | yes | FK reviewed worker |
| `rating` | number | yes | 1–5 |
| `comment` | string | no | |
| `createdAt` | timestamp | yes | |

---

## 12. `payments/{paymentId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `paymentId` | string | yes | PK |
| `userId` | string | yes | FK payer |
| `requestId` | string | no | FK for job payment |
| `subscriptionId` | string | no | FK for membership |
| `amount` | number | yes | |
| `currency` | string | yes | `INR` |
| `status` | enum | yes | `pending` \| `verified` \| `failed` \| `refunded` |
| `paymentGateway` | enum | yes | `upi_manual` \| `razorpay` \| `stripe` |
| `gatewayTransactionId` | string | no | |
| `idempotencyKey` | string | yes | Unique |
| `paidAt` | timestamp | no | |
| `invoiceUrl` | string | no | Receipt PDF |
| `proofImageUrl` | string | no | UPI screenshot |

---

## 13. `invoices/{invoiceId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `invoiceId` | string | yes | PK |
| `requestId` | string | yes | FK |
| `userId` | string | yes | FK |
| `subtotal` | number | yes | |
| `tax` | number | yes | |
| `discount` | number | no | |
| `total` | number | yes | |
| `pdfUrl` | string | no | |
| `generatedAt` | timestamp | yes | |

---

## 14. `subscriptions/{subscriptionId}`

**Changed:** `subscriptionId` PK (not `userId`). Users can have multiple historical subscriptions.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `subscriptionId` | string | yes | PK |
| `userId` | string | yes | FK |
| `planId` | string | yes | FK → `membership_plans` |
| `planType` | enum | yes | `monthly` \| `yearly` |
| `startDate` | timestamp | yes | |
| `endDate` | timestamp | yes | |
| `status` | enum | yes | `pending` \| `active` \| `expired` \| `cancelled` |
| `autoRenew` | boolean | yes | |
| `amount` | number | yes | |
| `currency` | string | yes | |
| `name` | string | yes | Billing name |
| `mobile` | string | yes | |
| `alternateMobile` | string | no | |
| `addressId` | string | no | FK |
| `paymentId` | string | no | FK latest payment |

**Migration:** Legacy docs at `subscriptions/{userId}` remain readable; new writes use auto-ID.

---

## 15. `membership_plans/{planId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `planId` | string | yes | PK e.g. `yearly_premium` |
| `name` | string | yes | NIVASA Annual |
| `price` | number | yes | |
| `currency` | string | yes | |
| `billingCycle` | enum | yes | `monthly` \| `yearly` |
| `benefits` | array | yes | List of strings |
| `isActive` | boolean | yes | |

---

## 16. `notifications/{notificationId}`

| Field | Type | Required |
|-------|------|----------|
| `notificationId` | string | yes |
| `userId` | string | yes |
| `type` | enum | yes |
| `title` | string | yes |
| `body` | string | yes |
| `data` | map | no |
| `read` | boolean | yes |
| `expiresAt` | timestamp | no |

---

## 17. `emergency_contacts/{contactId}`

| Field | Type | Required |
|-------|------|----------|
| `contactId` | string | yes |
| `userId` | string | yes |
| `name` | string | yes |
| `phone` | string | yes |
| `relation` | string | yes | Spouse, Parent, etc. |

---

## 18. `support_tickets/{ticketId}`

| Field | Type | Required |
|-------|------|----------|
| `ticketId` | string | yes |
| `userId` | string | yes |
| `subject` | string | yes |
| `description` | string | no |
| `status` | enum | yes | `open` \| `in_progress` \| `resolved` \| `closed` |
| `priority` | enum | no | |
| `assignedTo` | string | no | Admin UID |

---

## Relationship matrix

| From | To | Card | Key |
|------|-----|------|-----|
| users | addresses | 1:N | userId |
| users | service_requests | 1:N | userId |
| users | subscriptions | 1:N | userId |
| users | payments | 1:N | userId |
| users | reviews | 1:N | userId |
| users | emergency_contacts | 1:N | userId |
| users | support_tickets | 1:N | userId |
| users | notifications | 1:N | userId |
| addresses | service_requests | 1:N | addressId |
| service_categories | service_requests | 1:N | categoryId |
| service_requests | request_assignments | 1:N | requestId |
| service_requests | request_images | 1:N | requestId |
| service_requests | chat_messages | 1:N | requestId |
| service_requests | status_history | 1:N | requestId |
| service_requests | reviews | 1:1 | requestId |
| service_requests | invoices | 1:1 | requestId |
| service_requests | payments | 1:N | requestId |
| workers | request_assignments | 1:N | workerId |
| workers | reviews | 1:N | workerId |
| workers | worker_location_tracking | 1:N | workerId |
| membership_plans | subscriptions | 1:N | planId |

---

## Storage paths

| Path | Purpose |
|------|---------|
| `users/{uid}/avatar.jpg` | Profile photo |
| `workers/{workerId}/profile.jpg` | Worker photo |
| `service_requests/{requestId}/{imageId}.jpg` | Request photos |
| `invoices/{invoiceId}.pdf` | Invoice PDF |
| `payments/{uid}/proof_{paymentId}.jpg` | Payment proof |

---

## Implementation status

| Layer | Path | v2 Status |
|-------|------|-----------|
| Schema spec | `docs/database-schema.md` | ✅ |
| ER diagram | `docs/database-er-diagram.*` | ✅ |
| Security rules | `firestore.rules` | ✅ |
| Indexes | `firestore.indexes.json` | ✅ |
| Dart constants | `lib/core/db/` | ✅ |
| Repositories | `lib/services/repositories/` | Partial — extend as features ship |

**Schema version:** `kSchemaVersion = 2`
