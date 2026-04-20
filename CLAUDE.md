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

## Known decisions
- All black (`var(--text)`) backgrounds replaced with `var(--slate)` site-wide
- `italy-2026/index.html` back-link points to `https://travel.daveandmike.net` (not a subdomain)
- Header photo: `assets/italy-header.jpg`
