# travel.daveandmike.net — Repo Context

See ~/Documents/Git/CLAUDE.md for the full dave&mike visual system.

## Structure
- `index.html` — travel landing page (inline styles, no external stylesheet)
- `italy-2026/` — subdirectory for Italy 2026 trip, served at travel.daveandmike.net/italy-2026/
  - `style.css` — **shared stylesheet for all italy-2026 content pages** — CSS changes usually go here, not inline
  - `index.html` — italy-2026 landing (inline styles override gradient + add .header-title-block)
  - All other .html files are content pages that link to style.css

## italy-2026 content pages
- All use `.header-title-block` (defined in style.css, compact "in-header" variant re-declared per-page in a `<style>` override — same pattern as `matrix.html` used historically)
- Header structure: eyebrow "Italy 2026" (or location name) · h1 [page title] · subtitle [descriptor]
- Gradient override is in style.css `@media (max-width: 600px)` block
- Shared component classes added to style.css: `.page-nav` (tab nav under back-bar, used on index/ostuni/pergine-valdarno/photos), `.content-card` / `.lodging-card` / `.wine-note` (location-page write-ups — reuse `.card-grid`/`.card-section` for layout)

## italy-2026 — retrospective site (rebuilt 2026-07-01, replaced the planning site)
Trip is over; the old planning pages (flights, calendar, accommodations, living, excursions, trip-costs, medical, plus ~13 day-trip detail pages) were deleted and archived to SD (`Travel/2026/Trip1 2026-05-11_Italy/2026_07_01_PlanningWebSite/`). Current pages:
- `index.html` — vertical scrolling timeline (`.tl-wrap`/`.tl-stop` classes, page-specific, not in style.css), Puglia leg then Tuscany leg
- `ostuni.html`, `pergine-valdarno.html` — location pages: lodging card, restaurant cards, wine note, excursion/day-trip cards
- `photos.html` — full-trip photo gallery, all 169 dated originals from SD `Journal/` folder (filenames like `20260511-233.jpg`). Two asset variants: `assets/photos/thumb/` (~600px, grid) and `assets/photos/full/` (~1600px, lightbox). Vanilla JS lightbox (click thumbnail, arrow keys/buttons to navigate, Esc/backdrop-click to close) — no external libraries. This is the reusable pattern for any future trip's all-photos page.
- **TL-numbered hero photos** (`assets/TL1.jpg`–`TL12.jpg`): curated shots assigned sequentially in chronological stop order (TL1 = Ostuni arrival … TL12 = Chiusi). The authoritative source for which TL# belongs to which stop is the inline `(TLn)` tags in Dave's SD narrative doc (`Journal/Italy 2026 Narrative.docx`) — a separately-typed "photo assignment table" in an earlier decision doc had the numbering wrong and cost a correction round; trust the narrative doc's inline tags first.
- TL1 needed `style="object-position: top;"` (portrait shot, default center-crop cut off the top) — pattern for fixing other over-cropped portrait photos: adjust the vertical % in that same inline `object-position` (0% = top, 50% = center, 100% = bottom).

## italy.daveandmike.net redirect
The standalone `italy-2026` repo (`~/Documents/Git/italy-2026/italy-2026/`) now serves only as a redirect shim. Its `index.html` does a meta-refresh to `https://travel.daveandmike.net/italy-2026/`. The CNAME file (`italy.daveandmike.net`) must stay in place — removing it breaks the domain mapping. Old content is archived within that repo but not served.

## travel/index.html — trip listing layout
- 2-column `.trips-grid` layout: "Where We're Going" | "Where We've Been" (renamed 2026-07-01 from "Active Trips & Planning" / "Trip Archive")
- Column headers use slate eyebrow style with a thin border-bottom rule
- Where We're Going: Ski/Ride 2027–Park City (Feb 12–26, inactive). Where We've Been: Italy 2026 (May 10–Jun 22) — moved here once the trip concluded and the retrospective site went live
- `.inactive-link` class: faded (var(--faded)), no href, cursor default — for planned trips without pages yet
- When a trip wraps, move its link from "Where We're Going" to "Where We've Been"

## Known decisions
- All black (`var(--text)`) backgrounds replaced with `var(--slate)` site-wide
- `italy-2026/index.html` back-link points to `https://travel.daveandmike.net`; `ostuni.html`/`pergine-valdarno.html`/`photos.html` back-links point to `index.html` (one level up within the site, not the travel root)
- Header photo: `assets/italy-header.jpg` on `index.html`; location pages (`ostuni.html`, `pergine-valdarno.html`) use their own TL-numbered hero photo instead
