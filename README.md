# ArtisanArc Personal

**ArtisanArc Personal** is a fully offline-first Android toolkit for independent makers. It keeps materials, finished makes, projects, private customer orders, stall sales, reports and safety backups on the device. There are **no accounts, subscriptions, payment processing, supplier scraping, or cloud services required** for the principal workflow.

> **Core maker journey:** Materials Stock → plan a make → complete a make → Created Items tally → stall or sale → reports and review.

## Current release

| Item | Status |
|---|---|
| Current version | **v2.2.0+17** |
| Edition | ArtisanArc Personal — all features unlocked |
| Storage model | Local Hive records and on-device backup files |
| Android updates | Persistently signed release APKs, so compatible updates install without deleting local data |
| Latest verified build | [GitHub Actions run 31889154375](https://github.com/TangoSplicer/ArtisanArc/actions/runs/31889154375) |

## What it does

| Workflow area | Included capabilities |
|---|---|
| **Created Items** | Keeps an integer tally of finished makes that are ready to sell. Normal sales reduce this tally; material stock is not affected by a sale. |
| **Materials Stock** | Tracks yarn, hooks, notions and supplies separately, with decimal measured quantities, units, reorder points, stocktakes, audit history and archive/restore. |
| **Projects and pricing** | Supports craft-focused planning, linked supplies, reservations, unit-aware material deduction, completed-make records, transparent cost/price estimates and recorded historical production costs. |
| **Private procurement** | Stores suppliers, purchases, quantities, total paid and local unit-cost history without web scraping or external accounts. |
| **Commissions** | Keeps customer name, optional local contact note, project link, due date, deposit, balance and order status locally. A plain-text summary is shared only when the maker chooses to do so. |
| **Stall and sales** | Supports an active event session, fast basket sales, payment methods, discounts, returns, voids, cash-up and sales reporting. QR labels can prefill a standard sale for fast confirmation. |
| **Labels and CSV** | Prints item labels with optional local QR payloads. Inventory CSV imports are previewed first and only add new records; existing records are never overwritten. Exports preserve measured quantities, units and reorder points for round trips. |
| **Maker Operations** | Shows local low-material alerts, overdue and upcoming projects/orders, seven-day sales, active-stall context and seasonal planning views for spring markets, summer fairs, autumn launches and winter gifting. |
| **Data safety** | Provides rotating local safety snapshots, portable backup/restore preview, starter data and Settings-based clear controls. |

## Using ArtisanArc Personal

The Home hub provides direct access to Created Items, Materials Stock, Project Planner, Business Tools, Commissions & Orders, Maker Operations and Reports & Export. Most lists use a searchable picker rather than a long static dropdown. App bars provide Back and Home navigation, and normal Android system Back returns to the preceding screen.

For an event, start or resume a stall session from **Business Tools** or **Maker Operations**. Record sales manually, through the quick basket, or by scanning an item QR label into the standard New Sale screen. Review the event’s cash-up before closing the session.

For seasonal planning, open **Maker Operations**, choose an appropriate seasonal view and use the dashboard’s local work queues to open the relevant material, project or commission record. These seasonal views are guidance only; they do not contact an external calendar or upload data.

## Install the signed Android APK

1. Open the repository’s [Actions page](https://github.com/TangoSplicer/ArtisanArc/actions).
2. Select the most recent successful **ArtisanArc Build** for the required version.
3. Download the **`artisan-arc-apk`** artifact.
4. Extract the artifact and install the APK on an Android device. Android may ask for permission to install from the browser or file manager.
5. For a later release signed with the same key, install the new APK normally over the existing one. Keep a portable backup before any major update as normal good practice.

## Local backup guidance

Use **Settings** to make a portable backup before a large CSV import, data clean-up or a device change. Restore always presents a preview before replacing local data. The app also keeps a small rotating set of automatic local safety snapshots.

## Development and release checks

| Requirement | Version / command |
|---|---|
| Flutter | 3.22.0 |
| Dart SDK | `>=3.1.0 <4.0.0` |
| Android build | Java 17, minSdk 21, targetSdk 34 |
| Tests | `flutter test` |
| Static analysis | `flutter analyze` |
| Code generation | `dart run build_runner build --delete-conflicting-outputs` |
| Release build | `flutter build apk --release` |

The repository workflow performs clean setup, dependency retrieval, icon/splash generation, mock generation, tests, persistent release signing, APK assembly and artifact upload. See [`docs/RELEASE_SIGNING.md`](docs/RELEASE_SIGNING.md) for signing-maintenance guidance.

## Product boundaries

ArtisanArc Personal deliberately does **not** include payment processing, social-media integrations, shared cloud accounts, automated supplier scraping or server-side collaboration. This keeps the personal workflow private, understandable and dependable when offline.

## Release history

The detailed delivery record and future scope are maintained in [`ROADMAP.md`](ROADMAP.md). v1.8 added stocktake and archives; v1.9 added measured material stock and private procurement; v2.0 added cost previews and commissions; v2.1 added QR labels, scan-to-sell and safe CSV import; v2.2 added the Maker Operations dashboard and seasonal workflow views.
