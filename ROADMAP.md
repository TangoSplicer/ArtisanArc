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
| **1.3 — Safe foundation** | Release reliability and data protection | Updates install cleanly and local maker data is resilient | **Delivered in v1.3.0+8** |
| **1.4 — Make to sell** | Material-to-finished-item workflow | A project can consume supplies and produce finished inventory | **Delivered in v1.4.0+9; release verification pending** |
| **1.5 — Better stall days** | Event selling and reconciliation | A maker can run a whole table/stall session offline | **Delivered in v1.5.0+10; release verification pending** |
| **1.6 — Know the numbers** | Cost, profit and stock insights | Decisions are based on profit and materials, not only revenue | **Delivered in v1.6.0+11; release verification pending** |
| **1.7 — Everyday polish** | Fast daily use, accessibility and personalisation | Less tapping, fewer errors and better long-term usability | **Delivered in v1.7.0+12; release verification pending** |
| **1.8 — Trust the count** | Stocktake and archiving foundations | Physical counts can correct the local tally without losing history | **Delivered in v1.8.0+13; release verification pending** |
| **1.9 — Buy and measure with confidence** | Flexible material units and private procurement | Material costs and stock quantities reflect real purchases and measured use | **Delivered in v1.9.0+14; signed APK verified** |
| **2.0 — Price with clarity, fulfil locally** | Project cost previews and customer commissions | Makers can price work transparently and track private orders without a server | **Delivered in v2.0.0+15; signed APK verified** |
| **2.1 — Label, scan and bring data safely** | QR labels, scan-to-sell and CSV workflow | Physical labels and reusable CSV files accelerate routine stock and sale work offline | **Delivered in v2.1.0+16; release verification pending** |
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

## Delivery record — v1.4.0+9

| Delivered capability | Implementation outcome |
|---|---|
| Linked bill of materials | Each project supply can link to a specific Materials Stock record, capture an estimated unit cost, and distinguish a consumable from a reusable tool. |
| Complete Make | The project detail screen validates live local stock, lets the maker choose the completed quantity and optional sale price/waste note, then creates a saleable finished-item tally. |
| Safe material deduction | Only linked consumables are reduced; an unlinked or short consumable blocks completion before any records are changed. Linked reusable tools remain visible but are never deducted. |
| Reservations and shortages | Project supplies show available, reserved and short amounts, with clear linked/unlinked status. |
| Reorder points | Materials have optional item-specific reorder points, used by the low-stock dashboard in preference to the global threshold. |
| Local traceability | Completed projects retain generated finished-item IDs and local production notes; detailed stock-movement and profit reporting remain scheduled for **1.6**. |

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

## Delivery record — v1.5.0+10

| Delivered capability | Implementation outcome |
|---|---|
| Active offline session | A single active event session retains its event/venue, cash float, table fee and travel cost locally until cash-up. |
| Basket and payments | Fast plus/minus controls create a multi-item basket with cash, card, bank-transfer or other payment records; optional basket discounts are allocated transparently across the saved sale lines. |
| Corrections without deletion | Returns create a linked negative-revenue record and restore finished-item stock. Voids require a reason, preserve the original record, exclude its revenue and restore stock. |
| Cash-up and close | The close screen compares counted cash against expected cash, shows direct costs and net sales after those costs, then stores closeout notes locally. |
| Receipt and exports | A saved basket can be shared as a local text receipt. Sales CSV/PDF exports now include payment method, discount, status, session ID and adjustment reason. |

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

## Delivery record — v1.6.0+11

| Delivered capability | Implementation outcome |
|---|---|
| Captured production costs | Each completed make saves a local production run with its material cost at the time of completion, preventing later replacement costs from rewriting historical profit. |
| Honest gross-profit view | Analytics shows revenue, material cost of sales, gross profit and gross margin. Sales without a linked production-cost snapshot remain visible and are clearly flagged as having an unknown material cost. |
| Item and stock insight | Best-selling created items show net units sold, remaining finished quantity and attributable profit, while recent movement history records completed makes, sales, returns and void restorations. |
| Event profitability | Closed or historical stall sessions show revenue, captured material cost and direct table/travel costs, then calculate profit after those direct costs. |
| Data resilience | Production-cost history is included in snapshots, portable backups, restore previews and the Settings clear-data workflow. |

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

## Delivery record — v1.7.0+12

| Delivered capability | Implementation outcome |
|---|---|
| Home quick actions | The Home hub provides one-tap, touch-friendly routes to add a created item, add material, start or resume a stall session, and plan a project. |
| Smart offline search | A dedicated search screen finds local created items, materials, projects, and sale records without a server, account, or internet connection. Results use existing detail and history routes. |
| Actionable low-stock alerts | The Home low-material card now states the available and reorder quantities in text, gives screen readers a meaningful status label, and opens the relevant stock record on tap. |
| Accessibility-oriented interaction | Quick actions use 64-pixel targets, tooltips, standard Material controls, explicit search labels, and text alongside colour/status icons. |

---

# 1.8 — Trust the count

## Delivery record — v1.8.0+13

| Delivered capability | Implementation outcome |
|---|---|
| Guided stocktake | Makers can count all, created, or material records against the recorded tally; only changed lines are saved. |
| Adjustment audit trail | Each variance records prior quantity, physical count, signed change, reason, optional note, and local timestamp. |
| Archive instead of delete | Discontinued or seasonal inventory can be archived, hidden from daily stock and active sale baskets, then restored without losing historical sales or profit data. |
| Data safety | Adjustment history is registered with Hive and included in automatic snapshots, portable backup/restore, starter-data replacement, and Settings clear-all. |

---

# 1.9 — Buy and measure with confidence

## Delivery record — v1.9.0+14

| Delivered capability | Implementation outcome |
|---|---|
| Measured material stock | New and edited materials can use decimal quantities with unit-aware stock and reorder points, including grams, metres, litres, balls, and pieces. Existing integer records remain compatible. |
| Unit-aware production | Linked project supplies automatically use a selected material’s stored unit when appropriate. Completed makes deduct exact decimal amounts for compatible measured materials while retaining legacy whole-item behavior. |
| Private suppliers and purchases | A local Suppliers & Purchases screen stores manual supplier records, purchase quantities, total paid, and calculated unit cost; it updates material stock and the latest material cost without web scraping or an external account. |
| Measured stocktake audit | Physical counts can record decimal material variances. The adjustment history retains both compatibility values and exact measured before-and-after amounts. |
| Data safety | Supplier and purchase data are included in automatic snapshots, portable backup/restore, starter-data replacement, and Settings clear-all. |

---

# 2.0 — Price with clarity, fulfil locally

## Delivery record — v2.0.0+15

| Delivered capability | Implementation outcome |
|---|---|
| Transparent project Cost & Price preview | Project details show an explicitly labelled planning estimate for materials, optional labour, direct cost, target margin and suggested sale price. Planner-supplied unit estimates take precedence; otherwise, compatible latest local purchase unit costs are used. Missing or mismatched units are stated rather than guessed. |
| Historical costs remain separate | Completed-make production records continue to show the actual material cost captured at the time of production, separately from changing planning estimates and replacement prices. |
| Private local commissions | A dedicated Commissions & Orders workflow stores the customer name, optional local contact note, project link, due date, total, deposit, balance, status and notes entirely in local Hive data. No account, cloud service or payment processing is involved. |
| Guarded order lifecycle | Orders progress through enquiry, confirmed, in progress, ready, delivered or cancelled states. Invalid status jumps and deposits greater than the total are rejected. |
| Searchable project links and share-by-choice | The order editor uses the existing searchable project selection control. Makers can share a plain-text order summary only through an explicit action, retaining local-first control over customer information. |
| Data safety | Commission records are registered with Hive and included in automatic snapshots, portable backup/restore validation, starter-data replacement and Settings clear-all. |
| Regression coverage | Automated tests cover project-cost source priority, labour/margin price calculation, historic cost separation, commission balance calculation and lifecycle transitions. |

---

# 2.1 — Label, scan and bring data safely

## Delivery record — v2.1.0+16

| Delivered capability | Implementation outcome |
|---|---|
| Printable QR inventory labels | Label sheets can now print a chosen quantity of labels with item name, category, optional price and a stable local QR payload. Sheet generation continues automatically across pages. |
| Safe QR scanner lifecycle | The camera scanner pauses after one detection and lets its owning screen decide navigation. This removes the prior double-pop risk and supports clear retry feedback for invalid codes. |
| Scan-to-sell | The standard New Sale screen has a QR action that resolves an active finished item, preselects it, defaults quantity to one, and fills its stored price when available. Archived items, material-stock labels and unknown codes are rejected instead of being sold. |
| CSV import preview | A user-chosen local CSV is parsed before any write. Name, Type and Quantity are required; Category, Price, Location, Unit and Reorder Point are supported. Row-level invalid and duplicate feedback is shown before confirmation. |
| Add-only data safety | Import adds only new name/type combinations and never overwrites existing records. Measured material quantities, units and reorder points round-trip through the improved inventory CSV export format. |
| Regression coverage | Automated tests cover valid and invalid CSV rows, duplicate protection, measured-material parsing, export/import round trips, plus all prior local workflows. |

---

# Later, only if it earns its place

These ideas are reasonable, but they should not be started until the prior iterations are stable and regularly used.

| Optional idea | When it becomes worthwhile | Caution |
|---|---|---|
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
