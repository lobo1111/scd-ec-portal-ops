# Admin companies (Ops portal)

## Business
- **Problem**: Operators need to manage admin companies (legal entities that own communities).
- **Users**: Ops portal users (operators).
- **Value**: List, search, add, and edit admin companies; view counts (communities, admin users) per company; offline-first list with periodic and on-demand refresh.
- **Non-goals**: Admin users management, community transfer (separate features).

## Functional
- **List**: Table with Legal name, Contact email, Communities count, Admin users count, Actions (Show details). Client-side search by name or email.
- **Add company**: Modal with legal name, contact email, optional address; submit creates via API and refreshes local list.
- **Edit company**: Same modal pre-filled; submit updates via API and refreshes local list.
- **Show details**: Navigate to company detail (optional for v1) or open detail drawer/modal.
- **Refresh**: Pull-to-refresh or Refresh button; also periodic sync and sync on screen focus/resume.
- **Offline**: List reads from local store first; sync from API on resume, timer, and manual refresh.

## Technical
- **Source of truth**: `lib/features/admin_companies/` (screens, modal, feature descriptor).
- **Data**: Local in-memory store (or Drift later); sync via SyncService registering entity `admin_companies`; GraphQL listAdminCompanies, createAdminCompany, updateAdminCompany.
- **Routing**: Path `/admin/companies`; nav label "Admin companies" / "Companies".
- **Failure modes**: No network → show cached list; sync fails → keep showing cache, optional error indicator.
