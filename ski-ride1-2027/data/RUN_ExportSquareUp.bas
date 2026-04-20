' ============================================================
' RUN_ExportSquareUp  (VBA — Mac Excel desktop client)
'
' Reads the Square Up sheet, builds JSON, and pushes it to the
' italy-2026 GitHub Pages repo via the GitHub Contents API.
'
' Works on Mac because VBA writes a small Python helper to /tmp/
' and runs it via MacScript.  Python3 is built into macOS.
'
' HOW TO USE:
'   1. Open the VBA editor (Option + F11 or Tools → Macros → VBA editor)
'   2. Insert → Module, paste this entire file
'   3. Set your GitHub PAT in GITHUB_TOKEN below
'   4. Run RUN_ExportSquareUp from the Macros dialog
'      (or assign to a button on the Square Up sheet)
'
' ONE-TIME SETUP — Create a GitHub Fine-Grained PAT:
'   1. github.com → Settings → Developer settings → Personal access tokens
'      → Fine-grained tokens → Generate new token
'   2. Resource owner: DaveM61
'   3. Repository access: Only select repositories → italy-2026
'   4. Permissions → Repository permissions → Contents → Read and Write
'   5. Generate token, copy it, paste below
' ============================================================

Option Explicit

Sub RUN_ExportSquareUp()

    ' ── CONFIG — update GITHUB_TOKEN before first use ───────────
    Const GITHUB_TOKEN As String = "YOUR_PAT_HERE"   ' ← your Fine-grained PAT
    Const GITHUB_OWNER As String = "DaveM61"
    Const GITHUB_REPO  As String = "italy-2026"
    Const GITHUB_FILE  As String = "data/square-up.json"
    Const COMMIT_MSG   As String = "Update Square Up data from Excel"
    ' ─────────────────────────────────────────────────────────────

    Const TMP_DATA   As String = "/tmp/sq_data.txt"   ' JSON content (plain)
    Const TMP_SCRIPT As String = "/tmp/sq_push.py"    ' Python helper

    ' ── READ SQUARE UP SHEET ────────────────────────────────────
    ' Column layout (1-based VBA column numbers):
    '   F(6)  = Participant name
    '   G(7)  = Lodging
    '   H(8)  = Groceries
    '   I(9)  = Alcohol
    '   J(10) = Restaurants
    '   K(11) = Other
    '   L(12) = Total Owed  [skipped — we export Adjusted Balance instead]
    '   M(13) = Paid
    '   N(14) = Payments Made
    '   O(15) = Balance Due
    '   R(18) = Adjusted Balance  → exported as "totalOwed" on the web page

    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets("Square Up")

    ' Build ISO-8601 timestamp (local time)
    Dim ts As String
    ts = Format(Now(), "yyyy-mm-dd") & "T" & Format(Now(), "hh:mm:ss") & ".000Z"

    ' Collect participant rows 5–11
    Dim parts(6) As String
    Dim cnt As Integer
    cnt = 0

    Dim r As Integer
    For r = 5 To 11
        Dim nm As String
        nm = Trim(CStr(ws.Cells(r, 6).Value))
        If nm <> "" Then
            parts(cnt) = MakeParticipantJSON( _
                nm, _
                SafeNum(ws.Cells(r, 7).Value),   ' G  Lodging
                SafeNum(ws.Cells(r, 8).Value),   ' H  Groceries
                SafeNum(ws.Cells(r, 9).Value),   ' I  Alcohol
                SafeNum(ws.Cells(r, 10).Value),  ' J  Restaurants
                SafeNum(ws.Cells(r, 11).Value),  ' K  Other
                SafeNum(ws.Cells(r, 18).Value),  ' R  Adjusted Balance → totalOwed
                SafeNum(ws.Cells(r, 13).Value),  ' M  Paid
                SafeNum(ws.Cells(r, 14).Value),  ' N  Payments Made
                SafeNum(ws.Cells(r, 15).Value))  ' O  Balance Due
            cnt = cnt + 1
        End If
    Next r

    If cnt = 0 Then
        MsgBox "No participant data found in Square Up.", vbExclamation
        Exit Sub
    End If

    ' Join participant objects into a JSON array
    Dim arr As String
    Dim i As Integer
    For i = 0 To cnt - 1
        arr = arr & IIf(i > 0, ",", "") & parts(i)
    Next i

    ' Full JSON payload
    Dim Q As String: Q = Chr(34)
    Dim jsonStr As String
    jsonStr = "{" & _
        Q & "tripName"     & Q & ":" & Q & "Italy 2026" & Q & "," & _
        Q & "lastUpdated"  & Q & ":" & Q & ts           & Q & "," & _
        Q & "participants" & Q & ":[" & arr & "]}"

    ' ── WRITE JSON TO TEMP FILE ──────────────────────────────────
    Dim fn As Integer
    fn = FreeFile
    Open TMP_DATA For Output As #fn
    Print #fn, jsonStr
    Close #fn

    ' ── WRITE PYTHON HELPER SCRIPT ───────────────────────────────
    ' Python handles base64 encoding and the GitHub HTTPS API calls.
    ' All quoting complexity lives in Python, not VBA shell escaping.

    fn = FreeFile
    Open TMP_SCRIPT For Output As #fn

    Print #fn, "import json, base64, urllib.request, urllib.error"
    Print #fn, ""
    Print #fn, "TOKEN = '" & GITHUB_TOKEN & "'"
    Print #fn, "API   = 'https://api.github.com/repos/" & GITHUB_OWNER & "/" & GITHUB_REPO & "/contents/" & GITHUB_FILE & "'"
    Print #fn, "MSG   = '" & COMMIT_MSG & "'"
    Print #fn, ""
    Print #fn, "HDR = {"
    Print #fn, "    'Authorization': 'Bearer ' + TOKEN,"
    Print #fn, "    'Accept': 'application/vnd.github+json',"
    Print #fn, "    'Content-Type': 'application/json',"
    Print #fn, "    'X-GitHub-Api-Version': '2022-11-28'"
    Print #fn, "}"
    Print #fn, ""
    Print #fn, "# Base64-encode the JSON content"
    Print #fn, "with open('" & TMP_DATA & "', 'rb') as f:"
    Print #fn, "    b64 = base64.b64encode(f.read()).decode()"
    Print #fn, ""
    Print #fn, "# GET current file SHA (required to update an existing file)"
    Print #fn, "sha = ''"
    Print #fn, "try:"
    Print #fn, "    req = urllib.request.Request(API, headers=HDR)"
    Print #fn, "    with urllib.request.urlopen(req) as resp:"
    Print #fn, "        sha = json.load(resp).get('sha', '')"
    Print #fn, "except Exception:"
    Print #fn, "    pass  # file doesn't exist yet — first push"
    Print #fn, ""
    Print #fn, "# PUT updated content to GitHub"
    Print #fn, "payload = {'message': MSG, 'content': b64}"
    Print #fn, "if sha:"
    Print #fn, "    payload['sha'] = sha"
    Print #fn, "body = json.dumps(payload).encode()"
    Print #fn, "req = urllib.request.Request(API, data=body, headers=HDR, method='PUT')"
    Print #fn, "try:"
    Print #fn, "    with urllib.request.urlopen(req) as resp:"
    Print #fn, "        result = json.load(resp)"
    Print #fn, "        print('SUCCESS: sha=' + result.get('content', {}).get('sha', '?')[:8])"
    Print #fn, "except urllib.error.HTTPError as e:"
    Print #fn, "    print('ERROR ' + str(e.code) + ': ' + e.read().decode()[:300])"
    Print #fn, "except Exception as e:"
    Print #fn, "    print('ERROR: ' + str(e))"

    Close #fn

    ' ── RUN THE PYTHON SCRIPT ────────────────────────────────────
    Dim result As String
    result = MacScript("do shell script ""python3 " & TMP_SCRIPT & """")

    ' ── REPORT RESULT ────────────────────────────────────────────
    If Left(result, 7) = "SUCCESS" Then
        MsgBox "Square Up data pushed to GitHub." & Chr(13) & Chr(13) & _
               "italy.daveandmike.net/trip-costs.html" & Chr(13) & _
               "will refresh in about 60 seconds.", _
               vbInformation, "Export Complete"
    Else
        MsgBox "Push may have failed:" & Chr(13) & Chr(13) & result, _
               vbExclamation, "Export Warning"
    End If

End Sub

' ─────────────────────────────────────────────────────────────
' HELPERS
' ─────────────────────────────────────────────────────────────

' Safely convert a cell value to a rounded Double
Function SafeNum(v As Variant) As Double
    If IsNumeric(v) Then
        SafeNum = VBA.Round(CDbl(v), 2)
    Else
        SafeNum = 0
    End If
End Function

' Format a number for JSON (period decimal, 2 places, no $ or commas)
Function Fmt(n As Double) As String
    Fmt = Format(n, "0.00")
End Function

' Build one participant JSON object
Function MakeParticipantJSON( _
    nm          As String, _
    lodging     As Double, _
    groceries   As Double, _
    alcohol     As Double, _
    restaurants As Double, _
    other       As Double, _
    totalOwed   As Double, _
    paid        As Double, _
    paysMade    As Double, _
    balDue      As Double) As String

    Dim Q As String: Q = Chr(34)
    MakeParticipantJSON = "{" & _
        Q & "name"         & Q & ":" & Q & nm & Q & "," & _
        Q & "lodging"      & Q & ":" & Fmt(lodging)      & "," & _
        Q & "groceries"    & Q & ":" & Fmt(groceries)    & "," & _
        Q & "alcohol"      & Q & ":" & Fmt(alcohol)      & "," & _
        Q & "restaurants"  & Q & ":" & Fmt(restaurants)  & "," & _
        Q & "other"        & Q & ":" & Fmt(other)        & "," & _
        Q & "totalOwed"    & Q & ":" & Fmt(totalOwed)    & "," & _
        Q & "paid"         & Q & ":" & Fmt(paid)         & "," & _
        Q & "paymentsMade" & Q & ":" & Fmt(paysMade)     & "," & _
        Q & "balanceDue"   & Q & ":" & Fmt(balDue)       & "}"

End Function
