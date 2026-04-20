// ============================================================
// RUN_ExportSquareUp
// Reads the Square Up sheet, builds JSON, and pushes it to the
// italy-2026 GitHub Pages repo via the GitHub Contents API.
//
// HOW TO USE:
//   1. Paste this script into Excel Online → Automate → New Script
//   2. Fill in your GitHub PAT in GITHUB_TOKEN below
//   3. Run the script — data/square-up.json in the repo is updated
//      and italy.daveandmike.net/trip-costs.html reflects it live.
//
// ONE-TIME SETUP — Create a GitHub Personal Access Token (PAT):
//   1. Go to https://github.com/settings/tokens
//   2. Click "Generate new token" → "Fine-grained token"
//   3. Repository access: Only select repositories → italy-2026
//   4. Permissions → Repository permissions → Contents → Read and Write
//   5. Click "Generate token" and copy it here
// ============================================================

async function main(workbook: ExcelScript.Workbook): Promise<void> {

  // ── CONFIG ──────────────────────────────────────────────────
  const GITHUB_TOKEN   = "YOUR_PAT_HERE";          // ← paste your PAT
  const GITHUB_OWNER   = "DaveM61";
  const GITHUB_REPO    = "italy-2026";
  const GITHUB_FILE    = "data/square-up.json";
  const COMMIT_MESSAGE = "Update Square Up data from Excel";
  // ────────────────────────────────────────────────────────────

  const sheet = workbook.getWorksheet("Square Up");

  // ── READ PARTICIPANT ROWS ────────────────────────────────────
  // Square Up layout (0-based column indices):
  //   F(5)  = Participant name
  //   G(6)  = Lodging
  //   H(7)  = Groceries
  //   I(8)  = Alcohol
  //   J(9)  = Restaurants
  //   K(10) = Other
  //   L(11) = Total Owed  [not used — we use Adjusted Balance instead]
  //   M(12) = Paid
  //   N(13) = Payments Made
  //   O(14) = Balance Due
  //   R(17) = Adjusted Balance  → exported as "totalOwed" on the web page

  const FIRST_ROW = 4;   // Row 5 in Excel = index 4 (0-based)
  const LAST_ROW  = 10;  // Row 11 in Excel = index 10

  interface Participant {
    name:         string;
    lodging:      number;
    groceries:    number;
    alcohol:      number;
    restaurants:  number;
    other:        number;
    totalOwed:    number;
    paid:         number;
    paymentsMade: number;
    balanceDue:   number;
  }

  const participants: Participant[] = [];

  for (let r = FIRST_ROW; r <= LAST_ROW; r++) {
    const name = sheet.getCell(r, 5).getValue() as string;
    if (!name || String(name).trim() === "") continue;

    const num = (col: number): number => {
      const v = sheet.getCell(r, col).getValue();
      return (typeof v === "number" && isFinite(v)) ? round2(v) : 0;
    };

    participants.push({
      name:         String(name).trim(),
      lodging:      num(6),
      groceries:    num(7),
      alcohol:      num(8),
      restaurants:  num(9),
      other:        num(10),
      totalOwed:    num(17),   // Adjusted Balance → "Total Owed" on the web page
      paid:         num(12),
      paymentsMade: num(13),
      balanceDue:   num(14)
    });
  }

  if (participants.length === 0) {
    console.log("No participant data found in Square Up. Nothing pushed.");
    return;
  }

  // ── BUILD JSON ───────────────────────────────────────────────
  const payload = {
    tripName:    "Italy 2026",
    lastUpdated: new Date().toISOString(),
    participants
  };

  const jsonString = JSON.stringify(payload, null, 2);

  // GitHub API requires content as Base64
  const b64Content = toBase64(jsonString);

  // ── PUSH TO GITHUB ───────────────────────────────────────────
  const apiUrl  = `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/contents/${GITHUB_FILE}`;
  const headers = {
    "Authorization": `Bearer ${GITHUB_TOKEN}`,
    "Accept":        "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "Content-Type":  "application/json"
  };

  // Step 1: GET current file SHA (required by GitHub to update an existing file)
  let sha = "";
  const getResponse = await fetch(apiUrl, { method: "GET", headers });

  if (getResponse.ok) {
    const fileData = await getResponse.json() as { sha: string };
    sha = fileData.sha;
  } else if (getResponse.status !== 404) {
    // 404 just means the file doesn't exist yet — that's fine for first run
    const errText = await getResponse.text();
    console.log(`Warning getting existing file (${getResponse.status}): ${errText}`);
  }

  // Step 2: PUT updated content
  const putBody: Record<string, string> = {
    message: COMMIT_MESSAGE,
    content: b64Content
  };
  if (sha) putBody.sha = sha;   // required when updating an existing file

  const putResponse = await fetch(apiUrl, {
    method:  "PUT",
    headers,
    body:    JSON.stringify(putBody)
  });

  if (putResponse.ok) {
    console.log(`✅ Square Up data pushed to GitHub (${sha ? "updated" : "created"}).`);
  } else {
    const errText = await putResponse.text();
    console.log(`❌ GitHub push failed (${putResponse.status}): ${errText}`);
  }
}

// ── HELPERS ──────────────────────────────────────────────────

function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

// Minimal Base64 encoder (btoa-equivalent for Office Script context)
function toBase64(str: string): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  // Convert string to UTF-8 bytes
  const bytes: number[] = [];
  for (let i = 0; i < str.length; i++) {
    const code = str.charCodeAt(i);
    if (code < 128) {
      bytes.push(code);
    } else if (code < 2048) {
      bytes.push((code >> 6) | 192, (code & 63) | 128);
    } else {
      bytes.push((code >> 12) | 224, ((code >> 6) & 63) | 128, (code & 63) | 128);
    }
  }
  // Encode bytes to Base64
  let result = "";
  for (let i = 0; i < bytes.length; i += 3) {
    const b0 = bytes[i], b1 = bytes[i + 1] ?? 0, b2 = bytes[i + 2] ?? 0;
    const pad = 3 - (bytes.length - i < 3 ? bytes.length - i : 3);
    result +=
      chars[b0 >> 2] +
      chars[((b0 & 3) << 4) | (b1 >> 4)] +
      (pad < 2 ? chars[((b1 & 15) << 2) | (b2 >> 6)] : "=") +
      (pad < 1 ? chars[b2 & 63] : "=");
  }
  return result;
}
