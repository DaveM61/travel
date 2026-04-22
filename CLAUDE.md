# travel.daveandmike.net — Repo Context

See ~/Documents/Git/CLAUDE.md for the full dave&mike visual system.

## Structure
- `index.html` — travel landing page (inline styles, no external stylesheet)
- `italy-2026/` — subdirectory for Italy 2026 trip, served at travel.daveandmike.net/italy-2026/
  - `style.css` — **shared stylesheet for all italy-2026 content pages** — CSS changes usually go here, not inline
  - `index.html` — italy-2026 landing (inline styles override gradient + add .header-title-block)
  - All other .html files are content pages that link to style.css

## italy-2026 content pages
- All use `.header-title-block` (defined in style.css)
- Header structure: eyebrow "Italy 2026" · h1 [page title] · subtitle [descriptor]
- Gradient override is in style.css `@media (max-width: 600px)` block

## italy.daveandmike.net redirect
The standalone `italy-2026` repo (`~/Documents/Git/italy-2026/italy-2026/`) now serves only as a redirect shim. Its `index.html` does a meta-refresh to `https://travel.daveandmike.net/italy-2026/`. The CNAME file (`italy.daveandmike.net`) must stay in place — removing it breaks the domain mapping. Old content is archived within that repo but not served.

## travel/index.html — trip listing layout
- 2-column `.trips-grid` layout: "Active Trips & Planning" | "Trip Archive"
- Column headers use slate eyebrow style with a thin border-bottom rule
- Active trips: Italy 2026 (May 11–Jun 22), Ski/Ride 2027–Park City (Feb 12–26, inactive)
- `.inactive-link` class: faded (var(--faded)), no href, cursor default — for planned trips without pages yet
- Trip Archive column: "Coming Soon" in `.coming-soon` style

## italy-2026/excursions.html — itinerary list
- List is in chronological order by confirmed date
- Link titles are bold (font-weight 700) and blue (var(--slate))
- Confirmed trips listed with "Name — Date" format above a `.itin-divider` rule
- Undated/unscheduled trips listed below the divider without dates
- Confirmed schedule: Matera May 21–22 · Itria Valley May 30 · Montepulciano Jun 3 · Firenze Jun 4 · Castello di Verrazzano Jun 6–7
- Florence file remains `florence-june5.html` (filename not changed despite date correction to Jun 4)

## Known decisions
- All black (`var(--text)`) backgrounds replaced with `var(--slate)` site-wide
- `italy-2026/index.html` back-link points to `https://travel.daveandmike.net` (not a subdomain)
- Header photo: `assets/italy-header.jpg`
