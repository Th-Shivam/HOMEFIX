# NIVASA — Database ER Diagram

**Backend:** Cloud Firestore (NoSQL)  
**Schema version:** 1.0  
**See also:** [database-schema.md](./database-schema.md)

---

## View live diagrams (recommended)

Open **[database-er-diagram.html](./database-er-diagram.html)** in your browser — all diagrams render interactively with zoom and dark theme.

---

## 1. Entity Relationship Diagram

![ER Diagram — all collections and relationships](./diagrams/er-diagram.png)

<details>
<summary>Mermaid source (for editors that support preview)</summary>

```mermaid
erDiagram
    USERS ||--o| SUBSCRIPTIONS : "has"
    USERS ||--o{ SERVICE_REQUESTS : "raises"
    USERS ||--o{ PAYMENTS : "makes"
    USERS ||--o{ NOTIFICATIONS : "receives"
    USERS ||--o{ REVIEWS : "writes"
    USERS |o--o| WORKERS : "linkedUserId"
    SUBSCRIPTIONS ||--o{ PAYMENTS : "paid_via"
    WORKERS ||--o{ SERVICE_REQUESTS : "assigned_to"
    WORKERS ||--o{ REVIEWS : "rated_in"
    SERVICE_REQUESTS ||--|{ STATUS_HISTORY : "logs"
    SERVICE_REQUESTS ||--o| REVIEWS : "has"
    COUNTERS ||--o{ SERVICE_REQUESTS : "ticketId"
    APP_CONFIG ||--o{ SUBSCRIPTIONS : "pricing"

    USERS {
        string uid PK
        string name
        string email
        string phone
        enum role
        enum authProvider
        timestamp createdAt
    }

    SUBSCRIPTIONS {
        string userId PK
        enum planType
        enum paymentStatus
        timestamp subscriptionEndDate
        number amount
    }

    SERVICE_REQUESTS {
        string requestId UK
        string userId FK
        string assignedWorkerId FK
        enum category
        enum status
        enum priority
    }

    STATUS_HISTORY {
        string entryId PK
        string fromStatus
        string toStatus
        timestamp createdAt
    }

    WORKERS {
        string workerId PK
        string name
        enum type
        boolean available
        number rating
    }

    PAYMENTS {
        string paymentId PK
        string userId FK
        string idempotencyKey UK
        enum status
        number amount
    }

    REVIEWS {
        string reviewId PK
        string requestId FK
        string workerId FK
        number rating
    }

    NOTIFICATIONS {
        string notificationId PK
        string userId FK
        boolean read
    }

    APP_CONFIG {
        string docId PK
        number monthlyPrice
        number yearlyPrice
    }

    COUNTERS {
        string counterId PK
        number lastNumber
    }
```

</details>

---

## 2. Architecture Overview

![Architecture — Firebase Auth, Firestore, Storage](./diagrams/architecture-flow.png)

<details>
<summary>Mermaid source</summary>

```mermaid
flowchart TB
    subgraph AUTH["Firebase Auth"]
        AUTH_UID["uid"]
    end

    subgraph FIRESTORE["Cloud Firestore"]
        U[("users")]
        S[("subscriptions")]
        SR[("service_requests")]
        SH[("status_history")]
        W[("workers")]
        P[("payments")]
        R[("reviews")]
        N[("notifications")]
        AC[("app_config")]
        C[("counters")]

        U -->|"1:1"| S
        U -->|"1:N"| SR
        U -->|"1:N"| P
        U -->|"1:N"| N
        U -.->|"optional"| W
        W -->|"assigns"| SR
        SR -->|"subcollection"| SH
        SR -->|"1:1 review"| R
        W --> R
        S --> P
        C -->|"NVS-IDs"| SR
        AC -.->|"pricing"| S
    end

    subgraph STORAGE["Firebase Storage"]
        ST1["users/uid/avatar"]
        ST2["service_requests/id/photos"]
        ST3["payments/uid/proof"]
    end

    AUTH_UID --> U
    SR -.-> ST2
    U -.-> ST1
    P -.-> ST3
```

</details>

---

## 3. Service Request Lifecycle

![Service request status state machine](./diagrams/request-lifecycle.png)

<details>
<summary>Mermaid source</summary>

```mermaid
stateDiagram-v2
    [*] --> requested : customer submits
    requested --> finding_technician : system dispatches
    finding_technician --> assigned : worker matched
    assigned --> in_progress : work started
    in_progress --> on_the_way : worker en route
    on_the_way --> completed : job done
    requested --> cancelled : cancel
    finding_technician --> cancelled : cancel
    assigned --> cancelled : cancel
    in_progress --> cancelled : cancel
    completed --> [*]
    cancelled --> [*]
```

</details>

---

## Relationship summary

| From | To | Cardinality | Join key |
|------|-----|-------------|----------|
| `users` | `subscriptions` | 1 : 1 | `users.uid` = `subscriptions.userId` |
| `users` | `service_requests` | 1 : N | `users.uid` = `service_requests.userId` |
| `users` | `payments` | 1 : N | `users.uid` = `payments.userId` |
| `users` | `notifications` | 1 : N | `users.uid` = `notifications.userId` |
| `users` | `reviews` | 1 : N | `users.uid` = `reviews.userId` |
| `users` | `workers` | 0 : 1 | `users.uid` = `workers.linkedUserId` |
| `workers` | `service_requests` | 1 : N | `workers.workerId` = `service_requests.assignedWorkerId` |
| `workers` | `reviews` | 1 : N | `workers.workerId` = `reviews.workerId` |
| `service_requests` | `status_history` | 1 : N | subcollection under request doc |
| `service_requests` | `reviews` | 1 : 0..1 | `service_requests.requestId` = `reviews.requestId` |
| `subscriptions` | `payments` | 1 : N | `subscriptions.userId` = `payments.subscriptionId` |

---

## Diagram files

| File | Format | Description |
|------|--------|-------------|
| [database-er-diagram.html](./database-er-diagram.html) | HTML | **Open in browser** — live interactive diagrams |
| [diagrams/er-diagram.png](./diagrams/er-diagram.png) | PNG | Entity relationship diagram |
| [diagrams/architecture-flow.png](./diagrams/architecture-flow.png) | PNG | System architecture |
| [diagrams/request-lifecycle.png](./diagrams/request-lifecycle.png) | PNG | Ticket status flow |
| [diagrams/*.mmd](./diagrams/) | Mermaid | Source files (editable) |

---

## Legend

| Symbol | Meaning |
|--------|---------|
| **PK** | Primary key / document ID |
| **FK** | Foreign key (logical reference) |
| **UK** | Unique key |
| **1:1** | One document per user |
| **1:N** | One-to-many |
| **subcollection** | Nested under parent document in Firestore |
