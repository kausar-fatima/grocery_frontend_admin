<!-- ASSUMPTIONS: repo name grocery_frontend_admin; adjust links if names differ -->

# Fresh Grocery — Admin Console

Flutter admin app for platform oversight: user/partner approval, order and store visibility, promotions management, and platform stats.

## Related repositories

| App | Description |
|---|---|
| [grocery-backend](../../grocery-backend) | NestJS API powering the whole platform |
| [grocery_frontend_customer](../../grocery_frontend_customer) | Customer shopping app |
| [grocery_frontend_store](../../grocery_frontend_store) | Store/partner management app |
| [grocery_frontend_rider](../../grocery_frontend_rider) | Rider delivery app |

## Features

- Platform stats: users by role, orders by status, revenue, pending approvals
- User management: approve/reject store and rider registrations, role changes, soft-delete accounts
- Order and store oversight (read access across the platform)
- Promotions: create, edit, activate/deactivate, delete discount campaigns
- Admin-only access, enforced via role-gated routes on the backend

## Tech stack

- Flutter + `flutter_bloc`
- `dio` for networking
- `go_router` for navigation

## Getting started

### Prerequisites

- Flutter SDK (stable channel)
- The [backend](../../grocery-backend) running and reachable from your device/emulator
- An existing admin-role account in the database (admin accounts aren't self-registered through this app — seed one directly, or promote an existing user's role via the backend)

### Setup

```bash
git clone https://github.com/<your-username>/grocery_frontend_admin.git
cd grocery_frontend_admin
flutter pub get
```

### Backend connection

Set the API base URL for your target platform — see the equivalent section in the [customer app README](../../grocery_frontend_customer#backend-connection) for the exact pattern used across all four apps.

### Run

```bash
flutter run
```

## Project structure

```
lib/
├── core/            # network, theme
├── data/            # API clients, models
├── logic/           # Cubits (state management)
├── presentation/       # screens and widgets (stats, users, promotions, orders)
└── routes/           # go_router configuration
```

## License

Private project — not licensed for redistribution.
