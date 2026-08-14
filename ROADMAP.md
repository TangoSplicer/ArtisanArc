# ArtisanArc Personal Edition — Product Roadmap

## Purpose

This roadmap builds from the current offline-first Personal Edition into a dependable day-to-day maker tool. The next releases should **strengthen the workflow that is already in place**, rather than adding broad features too quickly. The key user journey is now clear:

> **Materials Stock → plan a make → create finished items → Inventory tally → stall or sale → reporting.**

The recommended sequence prioritises data safety, the bridge between materials and created items, fast in-person selling, and meaningful profitability reporting. Cloud accounts, payments, and multi-user features should remain out of scope unless they become a genuine requirement; they would compromise the simplicity and privacy of the Personal Edition.

## Current baseline

The current build already provides searchable craft-focused selection controls, separate **Inventory · Created Items** and **Materials Stock** areas, project planning, shopping lists, compliance records, offline craft hints, labels, QR support, reports and exports, starter data, onboarding, dark mode, and a rapid **On-the-day Sales** flow. Sales reduce the finished-item tally, while materials remain visible for future makes. The current verified APK is built by the repository’s GitHub Actions workflow.[1]

| Capability | Current state | Primary next opportunity |
|---|---|---|
| Finished creations | Tally, pricing, images, QR and sales reduction | Create a finished item directly from a project and consume materials automatically |
| Materials stock | Separate list, searchable categories and low-stock alert | Add maker-specific material attributes, reorder points and reservations |
| Projects | Supplies, milestones and craft selection | Tie material consumption, cost and progress to a completed item |
| Stall sales | Fast quantity-based capture and event/venue metadata | Add an active session, payments, discounts, cash reconciliation and returns |
| Reports | Revenue by month/event, CSV/PDF and project reports | Add profit, material cost, best-sellers and stock movement |
| Data safety | Local data, manual backup and clear controls | Introduce stable release signing, automatic snapshots and a safer restore flow |

## Roadmap at a glance

| Release iteration | Theme | Outcome | Priority |
|---|---|---|---|
| **1.3 — Safe foundation** | Release reliability and data protection | Updates install cleanly and local maker data is resilient | **Critical** |
| **1.4 — Make to sell** | Material-to-finished-item workflow | A project can consume supplies and produce finished inventory | **Highest user value** |
| **1.5 — Better stall days** | Event selling and reconciliation | A maker can run a whole table/stall session offline | **High** |
| **1.6 — Know the numbers** | Cost, profit and stock insights | Decisions are based on profit and materials, not only revenue | **High** |
| **1.7 — Everyday polish** | Fast daily use, accessibility and personalisation | Less tapping, fewer errors and better long-term usability | **Medium** |
| **Later, only if needed** | Optional expansion | Controlled scope without weakening the Personal Edition | **Deliberate** |

---

# 1.3 — Safe foundation

## Why this should be next

The most important technical improvement is a **persistent Android release-signing key** stored safely as repository secrets. Current cloud builds can have a different signing identity between releases, which can force an uninstall before an update. That risks losing local data and creates friction precisely when the app begins to contain useful records.

## Scope

| Work item | User-facing outcome | Definition of done |
|---|---|---|
| Persistent Android signing | Future APKs install as normal updates | Two successive cloud-built APKs install over one another without an uninstall |
| Versioned local data migrations | Updates preserve old inventory, stock, projects and sales | Existing Hive records are opened and classified safely after each schema change |
| Automatic local backup snapshots | A bad edit or accidental clear is recoverable | Keep a small rotating set of dated backups on-device; show creation time and size |
| Restore preview and confirmation | Restores are understandable and safe | Show what will be replaced before a restore happens |
| Diagnostics export | Support can diagnose an issue without cloud tracking | Settings can export anonymised local app/version/error information as a text file |
| Core workflow regression suite | Fewer regressions in releases | Automated checks cover data migration, sale reductions, navigation, selector rendering and dark mode |

## Explicit non-goals

This iteration should **not** add cloud sync, accounts, advertising, payment processing or a server. The goal is a safer local app and a smoother update experience.

---

# 1.4 — Make to sell

## Product objective

The separate inventories become most useful when ArtisanArc can describe the transition from available materials to a finished piece. This is the strongest next functional improvement because it connects the way a maker works to the way they sell.

## Scope

| Work item | User journey | Key design choice |
|---|---|---|
| Project bill of materials | Add yarn, tools/notions and required quantities to a project | Keep tools as non-consumable by default; consume yarn, eyes, stuffing, hardware and packaging |
| Material attributes | Record yarn weight, fibre, colour, dye lot, metres/grams, hook/needle size and gauge | Show only fields relevant to the selected material category |
| Create finished item from project | Tap **Complete make** to create one or more finished items | Pre-fill name, images, price suggestion and linked project |
| Material consumption | Confirm what was used before completing | Reduce chosen consumables and keep a visible stock-movement history |
| Partial makes and waste | Record “made 3 of 5” or unused/wasted material | Avoid forcing perfect quantities for a real craft workflow |
| Material reservations | A project can reserve required stock | Show “available”, “reserved”, and “short” amounts so planning remains credible |
| Reorder points | Set a minimum amount for commonly used materials | Low-material alerts become meaningful and action-oriented |

## Acceptance scenario

A maker can select a crochet project, confirm that it used two balls of yarn, safety eyes and stuffing, create three finished keyrings, and immediately see lower material quantities plus three more saleable created items.

---

# 1.5 — Better stall days

## Product objective

The current On-the-day Sales page captures sales quickly. The next step is to make it a complete offline table/stall companion without turning it into a complex point-of-sale system.

## Scope

| Work item | User-facing outcome | Notes |
|---|---|---|
| Active event session | Start “Saturday Makers Market” with venue, table fee and cash float | Keep one active session prominent on Home and Business Tools |
| Payment method capture | Record cash, card, bank transfer or other | Use payment method in end-of-day totals; do not process payments in-app |
| Fast basket and quantity controls | Sell several different makes in one transaction | Preserve the current single-tap quantity speed for repeat sales |
| Optional discounts | Record a fixed or percentage discount with reason | Keep price overrides transparent in reports |
| Returns and voids | Correct mistakes without deleting the audit trail | A return restores the created-item tally; a void must require confirmation |
| Cash-up / end-of-day close | Compare expected cash with counted cash | Include cash float, card total, fees, table fee and a note field |
| Simple receipt/share record | Create a locally shareable sale summary | No printer dependency in the first version; sharing a PDF is enough |

## Acceptance scenario

At a market, a maker starts a session, records card and cash sales, applies one discount, corrects a mistaken sale, closes the session, and sees expected cash, event revenue, fees and stock changes without an internet connection.

---

# 1.6 — Know the numbers

## Product objective

Revenue is useful, but the next reporting layer should help answer whether a maker is actually making money and which items are worth making again.

## Scope

| Work item | Insight delivered |
|---|---|
| Material cost per project/item | “What did this make cost in supplies?” |
| Sale profit and margin | “What did I keep after materials, discounts and event fees?” |
| Best sellers and slow movers | “Which finished pieces sell most often and which remain tallied?” |
| Event profitability | “Was this market worth attending after table and travel costs?” |
| Stock movement history | “Why did this yarn, hook or finished item quantity change?” |
| Date/range filters | Compare a market, month, season or custom period |
| Printable stocktake | Count physical created items and materials, then reconcile differences |
| Reports dashboard | Put the most useful three or four metrics on one offline home/report view |

## Guardrails

Costing should remain transparent. The user must be able to override a suggested material cost and see where a number came from. Avoid over-complicated tax calculations in the Personal Edition; retain exportable records instead.

---

# 1.7 — Everyday polish

## Product objective

Once the core workflow is solid, improve the app’s speed, clarity and accessibility through small changes that compound over daily use.

| Work item | Benefit |
|---|---|
| Home quick actions | One-tap actions for add created item, add material, start stall session and open today’s project |
| Pinned/favourite materials and projects | Surface the things used every week |
| Dashboard customisation | Let the user choose whether Home emphasises stock, projects, sales or reminders |
| Smarter search | Search across created items, materials, projects and sales from one place |
| Filter chips and saved views | Quickly switch between yarn weight, project, event or “needs reordering” |
| Bulk actions | Adjust several stock lines, assign a location, label a group or archive completed work |
| Accessible interaction review | Larger tap targets, screen-reader labels, colour-independent statuses and font-size testing |
| Additional device checks | Validate dark/light mode, system Back and overflow behaviour on small and large Android phones |
| Import/export polish | Import a simple CSV for stock and map columns before saving |

---

# Later, only if it earns its place

These ideas are reasonable, but they should not be started until the prior iterations are stable and regularly used.

| Optional idea | When it becomes worthwhile | Caution |
|---|---|---|
| Barcode/QR labels with scan-to-sell | When there are many repeated product lines at events | Keep a manual path for handmade one-offs |
| Photo-first catalogue | When created makes need stronger visual browsing | Images add storage and backup considerations |
| Pattern library | When project notes become numerous | Respect copyright; store references and user-authored notes, not copied commercial patterns |
| Optional encrypted cloud backup | Only when a second-device recovery need outweighs offline simplicity | Must be opt-in, transparent and separate from normal app use |
| Desktop companion/export workflow | When stocktakes and reporting become awkward on a phone | Start with well-structured CSV/PDF exports before building another app |
| Supplier price history | When repeat materials purchasing is frequent | Add manually entered prices first; avoid brittle web scraping |

## Recommended order of implementation

The recommended immediate order is:

1. **Persistent signing and automatic local backups.** This protects the data the app is beginning to collect and removes the update-installation risk.
2. **Material consumption and “complete make” workflow.** This makes the new Inventory/Materials Stock split genuinely useful.
3. **Stall session and cash-up.** This extends the already functioning quick-sale screen into a complete event-day workflow.
4. **Cost and profit reports.** These become trustworthy only after material consumption and event costs exist.
5. **Everyday polish.** Implement only the highest-friction items observed while using the prior releases.

## Release discipline

Every iteration should preserve the following standard:

| Release requirement | Standard |
|---|---|
| Offline-first | The principal workflow works without an account, a server or an internet connection |
| Data safety | Migration and restore checks are completed before modifying stored models |
| APK delivery | A GitHub Actions APK artifact is built and verified on each release commit |
| Usability | The happy path is tested on the actual route sequence, including Android system Back |
| Accessibility | Light and dark themes, text contrast, selector rendering and touch targets are checked |
| Scope control | Each release has one primary workflow outcome, rather than a collection of loosely connected features |

## Decision checkpoint

After **1.4**, use the app for a few real makes. If creating a finished item from materials feels natural, continue to **1.5**. If the main friction is still finding or counting supplies, spend the next small iteration on material attributes, filters and stocktaking before expanding stall-day features.

## References

[1]: https://github.com/TangoSplicer/ArtisanArc/actions "ArtisanArc GitHub Actions build history"
