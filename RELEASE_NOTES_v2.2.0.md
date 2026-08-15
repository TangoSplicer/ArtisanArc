# ArtisanArc Personal v2.2.0+17 — Release Notes

**Release date:** 15 August 2026

**Release commit:** `f18d2eb`
**Verified Android workflow:** [Run 31889154375](https://github.com/TangoSplicer/ArtisanArc/actions/runs/31889154375)

## Release status

The Android workflow completed successfully with dependency setup, code generation, tests, persistent release signing, APK assembly and artifact upload. The resulting **`artisan-arc-apk`** artifact is the signed Personal Edition build for this release.

| Verification | Result |
|---|---|
| Local regression suite | **39 tests passed** |
| Local static analysis | **No errors**; 32 pre-existing info/warning findings remain |
| GitHub Actions build | **Succeeded** |
| Signing behaviour | Uses the repository’s persistent Android release identity for update-compatible APKs |

## What is new in v2.2

The new **Maker Operations** dashboard brings the maker’s immediate offline priorities into one place. It summarises low material stock, overdue and upcoming project deadlines, private commission deadlines, seven-day sales and any active stall session. Each work-queue item opens its existing detailed local record, and the screen provides direct actions for a new order, stall selling, stocktake and label printing.

The dashboard also adds five **Seasonal workflow** views: All-year rhythm, Spring markets, Summer fairs, Autumn launch and Winter gifting. They provide concise production, order, label and event-day guidance without external calendars, accounts, notifications or data uploads.

## Included in the expanded Personal Edition

| Release | Key outcome |
|---|---|
| v1.8.0+13 | Guided stocktake, adjustment audit trail and archive/restore for inventory. |
| v1.9.0+14 | Decimal measured material stock, local suppliers and purchase history. |
| v2.0.0+15 | Project Cost & Price estimates plus private local commissions. |
| v2.1.0+16 | QR labels, direct scan-to-sell confirmation and safe add-only CSV import/export. |
| v2.2.0+17 | Maker Operations dashboard and seasonal workflow views. |

## Installation

Download the **`artisan-arc-apk`** artifact from the verified workflow, extract it, and install the APK on Android. Because releases use the same persistent signing key, the new APK should install over an existing Personal Edition version rather than requiring an uninstall. Make a portable backup in **Settings** before updating as standard practice.

## Privacy and scope

All primary workflows remain offline-first and local. This release does not introduce payment processing, social integrations, automated supplier scraping, cloud accounts, server services or customer-data sync.

For feature details and the longer delivery record, see [`README.md`](README.md) and [`ROADMAP.md`](ROADMAP.md).
