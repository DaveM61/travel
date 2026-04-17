# Trip Costs — Setup Reference

How the live expense table on `trip-costs.html` works, and what to update for each new trip.

---

## How It Works

1. The Travel Planner Excel workbook (OneDrive) contains an Office Script on the **Square Up** sheet.
2. When you run the script, it reads the expense data and pushes it to GitHub as `square-up.json` via the GitHub Contents API — no desktop required.
3. GitHub commits the file to the repo. The live `trip-costs.html` page fetches it on every load via a relative path: `data/square-up.json`.

---

## Current Setup — Italy 2026

| Config value | Setting |
|---|---|
| `GITHUB_OWNER` | `DaveM61` |
| `GITHUB_REPO` | `travel` |
| `GITHUB_FILE` | `italy-2026/data/square-up.json` |
| Local path | `/Users/davidmusel/Documents/Git/travel/italy-2026/data/square-up.json` |

---

## Setting Up a New Trip

### 1. Duplicate the Excel workbook
Copy the Italy 2026 workbook and rename it for the new trip.

### 2. Update the Office Script
In Excel Online → Automate, open the script and change these three lines at the top:

```typescript
const GITHUB_OWNER   = "DaveM61";
const GITHUB_REPO    = "travel";
const GITHUB_FILE    = "TRIP-ID/data/square-up.json";  // ← update TRIP-ID
```

**Example for Iowa 2026:**
```typescript
const GITHUB_FILE    = "iowa-2026/data/square-up.json";
```

Do the same in `RUN_ExportSquareUp.bas` if you use the VBA version.

### 3. Create the data folder in the repo
In your local repo at `/Users/davidmusel/Documents/Git/travel/`, create:
```
TRIP-ID/
  data/
    square-up.json    ← copy from an existing trip as a starter
```
Commit and push via GitHub Desktop before running the script for the first time.

### 4. Verify the PAT has access to the `travel` repo
Your GitHub Personal Access Token must have **Read and Write** access to the `travel` repository. To check or update:
- Go to https://github.com/settings/tokens
- Find your PAT and confirm `travel` is in its allowed repositories

---

## File Reference

| File | Purpose |
|---|---|
| `RUN_ExportSquareUp.ts` | Office Script (TypeScript) — paste into Excel Online → Automate |
| `RUN_ExportSquareUp.bas` | VBA version — for local Excel if needed |
| `data/square-up.json` | Live data file fetched by `trip-costs.html` |
