[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$documentsDir = Join-Path $root "documents"

$installCommand = "npx -y @the-living-project/the-living-project-cli init"
$workspaceFolder = ".living-project"
$skillName = "living-project"
$version = "3.0.3"
$versionTag = "v" + ($version -replace "\.", "_")

# ── Design tokens ──
$brandColor = 0x6B4226        # warm brown RGB(38,66,107) stored as BGR for Word
$brandColorRGB = @{ R = 107; G = 66; B = 38 }
$accentColor = 0x2E8B57       # sea green
$accentColorRGB = @{ R = 87; G = 139; B = 46 }
$headerBgColor = 0xF0E6D8     # light warm tan for table headers BGR
$altRowColor = 0xFAF6F1       # very light warm tan for alternating rows BGR
$bodyFont = "Calibri"
$headingFont = "Calibri"
$codeFont = "Consolas"
$bodySize = 10.5
$smallSize = 9.5

function New-WordApp {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    return $word
}

function Close-WordDocument {
    param($Document)
    if ($null -ne $Document) { $Document.Close([ref]$false) }
}

function Quit-WordApp {
    param($Word)
    if ($null -ne $Word) {
        $Word.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Word) | Out-Null
    }
}

function Initialize-DocumentStyle {
    param($Document)

    # Page margins (in points: 1 inch = 72pt)
    $sec = $Document.Sections.Item(1)
    $sec.PageSetup.TopMargin = 54      # 0.75 inch
    $sec.PageSetup.BottomMargin = 54
    $sec.PageSetup.LeftMargin = 64.8   # 0.9 inch
    $sec.PageSetup.RightMargin = 64.8

    # Default body font
    $Document.Styles.Item(-1).Font.Name = $bodyFont   # wdStyleNormal = -1
    $Document.Styles.Item(-1).Font.Size = $bodySize
    $Document.Styles.Item(-1).Font.Color = 0x333333
    $Document.Styles.Item(-1).ParagraphFormat.SpaceAfter = 6
    $Document.Styles.Item(-1).ParagraphFormat.SpaceBefore = 0
    $Document.Styles.Item(-1).ParagraphFormat.LineSpacingRule = 4  # wdLineSpaceMultiple
    $Document.Styles.Item(-1).ParagraphFormat.LineSpacing = 14.4   # ~1.15x at 10.5pt

    # Heading 1 style
    $h1 = $Document.Styles.Item(-2)  # wdStyleHeading1
    $h1.Font.Name = $headingFont
    $h1.Font.Size = 20
    $h1.Font.Bold = 1
    $h1.Font.Color = $brandColor
    $h1.ParagraphFormat.SpaceBefore = 24
    $h1.ParagraphFormat.SpaceAfter = 8
    $h1.ParagraphFormat.KeepWithNext = -1

    # Heading 2 style
    $h2 = $Document.Styles.Item(-3)  # wdStyleHeading2
    $h2.Font.Name = $headingFont
    $h2.Font.Size = 14
    $h2.Font.Bold = 1
    $h2.Font.Color = $accentColor
    $h2.ParagraphFormat.SpaceBefore = 18
    $h2.ParagraphFormat.SpaceAfter = 6
    $h2.ParagraphFormat.KeepWithNext = -1

    # Heading 3 style
    $h3 = $Document.Styles.Item(-4)  # wdStyleHeading3
    $h3.Font.Name = $headingFont
    $h3.Font.Size = 12
    $h3.Font.Bold = 1
    $h3.Font.Color = 0x444444
    $h3.ParagraphFormat.SpaceBefore = 12
    $h3.ParagraphFormat.SpaceAfter = 4
    $h3.ParagraphFormat.KeepWithNext = -1
}

function Add-Title {
    param(
        $Document,
        [string]$Text,
        [string]$Subtitle = ""
    )

    $p = $Document.Content.Paragraphs.Add()
    $p.Range.Text = $Text
    $p.Range.Font.Name = $headingFont
    $p.Range.Font.Size = 26
    $p.Range.Font.Bold = 1
    $p.Range.Font.Color = $brandColor
    $p.SpaceAfter = 2
    $p.SpaceBefore = 0
    $p.Range.InsertParagraphAfter() | Out-Null

    if ($Subtitle) {
        $s = $Document.Content.Paragraphs.Add()
        $s.Range.Text = $Subtitle
        $s.Range.Font.Name = $headingFont
        $s.Range.Font.Size = 12
        $s.Range.Font.Bold = 0
        $s.Range.Font.Color = 0x666666
        $s.SpaceAfter = 4
        $s.Range.InsertParagraphAfter() | Out-Null
    }
}

function Add-Subtitle {
    param(
        $Document,
        [string]$Text
    )
    $p = $Document.Content.Paragraphs.Add()
    $p.Range.Text = $Text
    $p.Range.Font.Name = $headingFont
    $p.Range.Font.Size = 11
    $p.Range.Font.Bold = 0
    $p.Range.Font.Color = 0x888888
    $p.SpaceAfter = 16
    $p.Range.InsertParagraphAfter() | Out-Null
}

function Add-Divider {
    param($Document)
    $p = $Document.Content.Paragraphs.Add()
    $p.Range.Text = " "
    $p.SpaceBefore = 4
    $p.SpaceAfter = 4
    $p.Borders.Item(4).LineStyle = 1  # wdBorderBottom, wdLineStyleSingle
    $p.Borders.Item(4).LineWidth = 2  # wdLineWidth025pt
    $p.Borders.Item(4).Color = 0xDDDDDD
    $p.Range.InsertParagraphAfter() | Out-Null
}

function Add-Paragraph {
    param(
        $Document,
        [string]$Text,
        [int]$FontSize = 0,
        [switch]$Bold,
        [int]$SpaceAfter = 6,
        [switch]$Code,
        [switch]$Muted
    )

    $size = if ($FontSize -gt 0) { $FontSize } else { $bodySize }
    $paragraph = $Document.Content.Paragraphs.Add()
    $paragraph.Range.Text = $Text
    $paragraph.Range.Font.Name = if ($Code) { $codeFont } else { $bodyFont }
    $paragraph.Range.Font.Size = if ($Code) { $smallSize } else { $size }
    $paragraph.Range.Font.Bold = [int]$Bold.IsPresent
    $paragraph.Range.Font.Color = if ($Muted) { 0x888888 } elseif ($Code) { 0x444444 } else { 0x333333 }
    $paragraph.SpaceAfter = $SpaceAfter
    if ($Code) {
        $paragraph.Range.Shading.BackgroundPatternColor = 0xF5F5F5
        $paragraph.Format.LeftIndent = 14.4
    }
    $paragraph.Range.InsertParagraphAfter() | Out-Null
    return $paragraph
}

function Add-Heading {
    param(
        $Document,
        [string]$Text,
        [int]$Level = 2
    )

    $styleId = switch ($Level) {
        1 { -2 }  # wdStyleHeading1
        2 { -3 }  # wdStyleHeading2
        3 { -4 }  # wdStyleHeading3
        default { -3 }
    }

    $p = $Document.Content.Paragraphs.Add()
    $p.Range.Text = $Text
    $p.Style = $Document.Styles.Item($styleId)
    $p.Range.InsertParagraphAfter() | Out-Null
}

function Add-BulletList {
    param(
        $Document,
        [string[]]$Items,
        [switch]$Compact
    )

    foreach ($item in $Items) {
        $paragraph = $Document.Content.Paragraphs.Add()
        $paragraph.Range.Text = $item
        $paragraph.Range.Font.Name = $bodyFont
        $paragraph.Range.Font.Size = $bodySize
        $paragraph.Range.Font.Color = 0x333333
        $paragraph.Range.ListFormat.ApplyBulletDefault()
        $paragraph.SpaceAfter = if ($Compact) { 1 } else { 3 }
        $paragraph.SpaceBefore = 0
        $paragraph.Range.InsertParagraphAfter() | Out-Null
    }

    if (-not $Compact) {
        $spacer = $Document.Content.Paragraphs.Add()
        $spacer.SpaceAfter = 4
        $spacer.Range.Font.Size = 4
        $spacer.Range.InsertParagraphAfter() | Out-Null
    }
}

function Add-NumberedList {
    param(
        $Document,
        [string[]]$Items
    )

    foreach ($item in $Items) {
        $paragraph = $Document.Content.Paragraphs.Add()
        $paragraph.Range.Text = $item
        $paragraph.Range.Font.Name = $bodyFont
        $paragraph.Range.Font.Size = $bodySize
        $paragraph.Range.Font.Color = 0x333333
        $paragraph.Range.ListFormat.ApplyNumberDefault()
        $paragraph.SpaceAfter = 3
        $paragraph.SpaceBefore = 0
        $paragraph.Range.InsertParagraphAfter() | Out-Null
    }

    $spacer = $Document.Content.Paragraphs.Add()
    $spacer.SpaceAfter = 4
    $spacer.Range.Font.Size = 4
    $spacer.Range.InsertParagraphAfter() | Out-Null
}

function Add-Table {
    param(
        $Document,
        [string[]]$Headers,
        [object[][]]$Rows
    )

    $range = $Document.Content
    $range.Collapse(0)
    $table = $Document.Tables.Add($range, $Rows.Count + 1, $Headers.Count)

    # AutoFit to window width
    $table.AutoFitBehavior(2)  # wdAutoFitWindow

    # Font
    $table.Range.Font.Name = $bodyFont
    $table.Range.Font.Size = $smallSize
    $table.Range.Font.Color = 0x333333

    # Cell padding
    $table.TopPadding = 4
    $table.BottomPadding = 4
    $table.LeftPadding = 6
    $table.RightPadding = 6

    # Clean border style: light gray single borders
    $table.Borders.Enable = 1
    foreach ($borderIdx in @(1, 2, 3, 4, -1, -2)) {
        try {
            $border = $table.Borders.Item($borderIdx)
            $border.LineStyle = 1   # wdLineStyleSingle
            $border.LineWidth = 2   # wdLineWidth025pt
            $border.Color = 0xCCCCCC
        } catch {}
    }

    # Header row styling
    $headerRow = $table.Rows.Item(1)
    $headerRow.Range.Font.Bold = 1
    $headerRow.Range.Font.Color = 0xFFFFFF
    $headerRow.Range.Font.Size = $smallSize
    $headerRow.HeadingFormat = -1  # Repeat on new page

    for ($col = 0; $col -lt $Headers.Count; $col++) {
        $cell = $table.Cell(1, $col + 1)
        $cell.Range.Text = $Headers[$col]
        $cell.Shading.BackgroundPatternColor = $brandColor
    }

    # Data rows with alternating shading
    for ($row = 0; $row -lt $Rows.Count; $row++) {
        for ($col = 0; $col -lt $Headers.Count; $col++) {
            $cell = $table.Cell($row + 2, $col + 1)
            $cell.Range.Text = [string]$Rows[$row][$col]
            if ($row % 2 -eq 1) {
                $cell.Shading.BackgroundPatternColor = $altRowColor
            }
        }
    }

    $table.Range.InsertParagraphAfter() | Out-Null
    $spacer = $Document.Content.Paragraphs.Add()
    $spacer.SpaceAfter = 6
    $spacer.Range.Font.Size = 4
    $spacer.Range.InsertParagraphAfter() | Out-Null
}

function Save-Docx {
    param(
        $Document,
        [string]$Path
    )

    $Document.SaveAs2($Path, 16)
}

function Save-Pdf {
    param(
        $Document,
        [string]$Path
    )

    $Document.SaveAs2($Path, 17)
}

function Build-CheatSheet {
    param(
        [string]$Path
    )

    $word = $null
    $doc = $null

    try {
        $word = New-WordApp
        $doc = $word.Documents.Add()
        Initialize-DocumentStyle -Document $doc

        # ── Title ──
        Add-Title -Document $doc -Text "The Living Project v3" -Subtitle "Cheat Sheet"
        Add-Subtitle -Document $doc -Text "A model-agnostic AI project framework  |  Version $version  |  CC BY 4.0"
        Add-Divider -Document $doc

        # ── Install ──
        Add-Heading -Document $doc -Text "Install in one line" -Level 1
        Add-Paragraph -Document $doc -Text "Run this command in any terminal. Node 18 or later is required." | Out-Null
        Add-Paragraph -Document $doc -Text "npx -y @the-living-project/the-living-project-cli init" -Code | Out-Null
        Add-Paragraph -Document $doc -Text "Alternative package runners:" | Out-Null
        Add-BulletList -Document $doc -Items @(
            "pnpm dlx @the-living-project/the-living-project-cli init",
            "bunx @the-living-project/the-living-project-cli init",
            "yarn dlx @the-living-project/the-living-project-cli init"
        )
        Add-Paragraph -Document $doc -Text "Optional: name your workspace" | Out-Null
        Add-Paragraph -Document $doc -Text "npx -y @the-living-project/the-living-project-cli init `"My Project`"" -Code | Out-Null
        Add-Paragraph -Document $doc -Text "Install into the current directory instead of creating a new folder:" | Out-Null
        Add-Paragraph -Document $doc -Text "npx -y @the-living-project/the-living-project-cli init --here" -Code | Out-Null

        # ── What gets created ──
        Add-Heading -Document $doc -Text "What the installer creates" -Level 1
        Add-Table -Document $doc -Headers @("Path", "Purpose") -Rows @(
            @("START-HERE.md", "Visible first-run file with the universal prompt and Codex shortcut."),
            @("$workspaceFolder\seeds\", "One file per project seed statement. The root question that drives the work."),
            @("$workspaceFolder\context\", "Context briefs, stakeholder inputs, constraints, and working memory."),
            @("$workspaceFolder\phases\", "The seven phase guides the AI assistant reads to operate the framework."),
            @("$workspaceFolder\compost\", "Post-mortems, validated learnings, and reusable components from past cycles."),
            @("$workspaceFolder\cultivate-log.md", "Weekly portfolio review: active projects, risks, cross-pollination notes."),
            @("$workspaceFolder\QUICKSTART.md", "Zero-training start guide for first-time users."),
            @(".gitignore", "Auto-configured to exclude private context and compost files from version control.")
        )

        # ── Universal Prompt ──
        Add-Heading -Document $doc -Text "The universal prompt (works with any AI tool)" -Level 2
        Add-Paragraph -Document $doc -Text "Use The Living Project framework in this folder. Treat this as my active workspace. Read $workspaceFolder\QUICKSTART.md, figure out the right phase automatically, ask me only the minimum questions needed, and write the outputs into $workspaceFolder as we go." | Out-Null
        Add-Paragraph -Document $doc -Text "Codex shortcut (when the skill is installed):" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Use `$living-project in this folder and guide me to the right next step." | Out-Null

        # ── Core Loop ──
        Add-Heading -Document $doc -Text "The core loop" -Level 2
        Add-Paragraph -Document $doc -Text "SEED -> NOURISH -> GROW -> PRUNE -> repeat until ready to ship" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Strategic phases (use when needed): REPOT | COMPOST | CULTIVATE" | Out-Null

        # ── Phase Reference ──
        Add-Heading -Document $doc -Text "Phase quick reference" -Level 2
        Add-Table -Document $doc -Headers @("Phase", "Purpose", "Key action") -Rows @(
            @("SEED", "Define the real problem and root need.", "Run 5 Whys, answer the 5Ws, write a one-paragraph seed statement."),
            @("NOURISH", "Load every piece of relevant context.", "Gather prior art, constraints, stakeholder notes. Ask AI what is missing."),
            @("GROW", "Generate directional drafts and options.", "Ask for conservative, ambitious, and unconventional approaches. Iterate."),
            @("PRUNE", "Critique, tighten, and reduce risk.", "Restate the seed, ask AI to score 1-10, fix gaps and logical errors."),
            @("REPOT", "Restructure scope or architecture deliberately.", "Compare constrain vs. expand vs. split options with effort and risk."),
            @("COMPOST", "Extract learnings and restart smarter.", "List validated and invalidated assumptions. Write a stronger new seed."),
            @("CULTIVATE", "Manage multiple active projects as a portfolio.", "Weekly review: compare progress, flag risks, cross-pollinate insights.")
        )

        # ── Where to start ──
        Add-Heading -Document $doc -Text "How to know where to start" -Level 2
        Add-BulletList -Document $doc -Items @(
            "New project or fuzzy idea: start with SEED.",
            "You already have notes, emails, requirements, or research: move into NOURISH.",
            "You need a first draft, multiple options, or a working prototype: move into GROW.",
            "You already have output and want it reviewed or improved: move into PRUNE.",
            "Scope is drifting or the architecture feels too small: use REPOT.",
            "The current direction is failing or assumptions were invalidated: use COMPOST.",
            "You need to compare projects, set priorities, or decide where attention should go: use CULTIVATE."
        )

        # ── CLI commands ──
        Add-Heading -Document $doc -Text "CLI commands" -Level 2
        Add-Table -Document $doc -Headers @("Command", "What it does") -Rows @(
            @("npx -y @the-living-project/the-living-project-cli init", "Create a new workspace with full framework files and Codex skill."),
            @("npx -y @the-living-project/the-living-project-cli init `"Name`"", "Create a named workspace folder."),
            @("npx -y @the-living-project/the-living-project-cli init --here", "Install into the current directory."),
            @("npx -y @the-living-project/the-living-project-cli upgrade", "Refresh managed framework files while preserving user work."),
            @("npx -y @the-living-project/the-living-project-cli upgrade --here", "Upgrade the current directory workspace."),
            @("npx -y @the-living-project/the-living-project-cli doctor", "Inspect workspace and skill installation health."),
            @("npx -y @the-living-project/the-living-project-cli doctor --json", "Output doctor results as machine-readable JSON."),
            @("npx -y @the-living-project/the-living-project-cli help", "Show full help text with all flags and examples.")
        )

        # ── File guide ──
        Add-Heading -Document $doc -Text "File naming conventions" -Level 2
        Add-BulletList -Document $doc -Items @(
            "Seeds: $workspaceFolder\seeds\project-name.md",
            "Context briefs: $workspaceFolder\context\project-name-context.md",
            "Private context (git-ignored): $workspaceFolder\context\project-name.private.md",
            "Post-mortems: $workspaceFolder\compost\project-name-YYYY-MM-DD.md",
            "Portfolio review: $workspaceFolder\cultivate-log.md"
        )

        # ── Upgrades ──
        Add-Heading -Document $doc -Text "How upgrades work" -Level 2
        Add-BulletList -Document $doc -Items @(
            "Managed files (phases, QUICKSTART.md, .gitignore, START-HERE.md) are refreshed to the latest version.",
            "User work in seeds, context, compost, and cultivate-log.md is never touched.",
            "Previous managed files are backed up before replacement.",
            "The Codex skill is replaced and re-versioned automatically."
        )

        # ── Release model ──
        Add-Heading -Document $doc -Text "Release model" -Level 2
        Add-BulletList -Document $doc -Items @(
            "npm package: @the-living-project/the-living-project-cli",
            "Source of truth: GitHub (The-Living-Project/the-living-project-cli)",
            "Release automation: GitHub Actions with npm trusted publishing via OIDC.",
            "Tag format: living-project-vX.Y.Z",
            "License: CC BY 4.0"
        )

        Save-Docx -Document $doc -Path $Path
    }
    finally {
        Close-WordDocument -Document $doc
        Quit-WordApp -Word $word
    }
}

function Build-CheatSheetV3 {
    param(
        [string]$Path
    )

    $word = $null
    $doc = $null

    try {
        $word = New-WordApp
        $doc = $word.Documents.Add()
        Initialize-DocumentStyle -Document $doc

        # ── Title ──
        Add-Title -Document $doc -Text "The Living Project v3" -Subtitle "Detailed Practitioner Guide"
        Add-Subtitle -Document $doc -Text "Phase-by-phase guidance with prompt templates and multi-agent patterns"
        Add-Subtitle -Document $doc -Text "Version $version  |  @the-living-project/the-living-project-cli  |  CC BY 4.0"
        Add-Divider -Document $doc

        # ── Core thesis ──
        Add-Heading -Document $doc -Text "Core thesis" -Level 1
        Add-Paragraph -Document $doc -Text "Context is the strongest determinant of output quality. Most AI-assisted work fails because teams start with deliverables instead of problems, context is fragmented or never written down, first drafts are over-trusted, scope drift is recognized too late, and abandoned efforts are never mined for reusable insight. The Living Project solves this by turning the workspace itself into a durable operating model." | Out-Null

        # ── Install ──
        Add-Heading -Document $doc -Text "Installation" -Level 1
        Add-Paragraph -Document $doc -Text "Prerequisite: Node.js 18 or later." | Out-Null
        Add-Paragraph -Document $doc -Text "Standard install (creates a new workspace folder):" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text $installCommand -Code | Out-Null
        Add-Paragraph -Document $doc -Text "Named workspace:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "npx -y @the-living-project/the-living-project-cli init `"Q3 Product Roadmap`"" -Code | Out-Null
        Add-Paragraph -Document $doc -Text "Install into the current directory:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "npx -y @the-living-project/the-living-project-cli init --here" -Code | Out-Null
        Add-Paragraph -Document $doc -Text "Alternative runners:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "pnpm dlx @the-living-project/the-living-project-cli init",
            "bunx @the-living-project/the-living-project-cli init",
            "yarn dlx @the-living-project/the-living-project-cli init"
        )
        Add-Paragraph -Document $doc -Text "What happens when you run init:" -Bold | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "A workspace folder is created (or the current directory is used with --here).",
            "The $workspaceFolder directory is populated with phases, seeds, context, and compost folders.",
            "START-HERE.md is placed at the workspace root with the universal prompt.",
            "The living-project Codex skill is installed into ~/.codex/skills/ when Codex is detected.",
            "A .gitignore is configured to exclude private context and compost files."
        )

        # ── Core loop ──
        Add-Divider -Document $doc
        Add-Heading -Document $doc -Text "The framework" -Level 1
        Add-Paragraph -Document $doc -Text "Core loop: SEED -> NOURISH -> GROW -> PRUNE -> repeat until ready" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Strategic phases: REPOT | COMPOST | CULTIVATE" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "The core loop is the default path for every project. The strategic phases are invoked when scope changes, direction fails, or you need to manage multiple efforts." | Out-Null

        # ── SEED ──
        Add-Divider -Document $doc
        Add-Heading -Document $doc -Text "Phase 1: SEED -- Plant the Question" -Level 1
        Add-Paragraph -Document $doc -Text "Every project begins with a question, not an answer. The goal is to find the root problem, not the requested deliverable." | Out-Null
        Add-Paragraph -Document $doc -Text "What to do:" -Bold | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "Run the 5 Whys on the raw problem statement. Keep asking why until you reach root cause.",
            "Answer the 5W framework: Who is this for? What does it solve? Where does it live? When is it needed? Why does it matter now?",
            "Write a one-paragraph seed statement and save it to $workspaceFolder\seeds\project-name.md.",
            "Identify at least 2 assumptions you are making and 2 blind spots you might have."
        )
        Add-Paragraph -Document $doc -Text "Prompt template:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "The problem is [X]. Ask me 5 Whys -- challenge each of my answers and tell me when we have hit root cause. Do not accept my first answer." | Out-Null
        Add-Paragraph -Document $doc -Text "Follow-up prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Based on our root cause analysis, generate a structured seed statement answering: Who, What, Where, When, Why. Then identify 3 assumptions and 2 blind spots." | Out-Null
        Add-Paragraph -Document $doc -Text "Alternative framing prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Here is my problem statement: [X]. Generate 3 alternative framings. For each, explain what would change about the solution. Which framing is strongest and why?" | Out-Null
        Add-Paragraph -Document $doc -Text "Multi-agent pattern:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Agent A: Run the 5 Whys analysis on the raw problem.",
            "Agent B: Research how others have solved this class of problem.",
            "Agent C: Challenge the problem statement itself -- is this the right problem?"
        )
        Add-Paragraph -Document $doc -Text "Completion criteria:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "You have a root cause, not a symptom.",
            "All 5Ws are answered with specifics (no `"everyone`" or `"ASAP`").",
            "You can state the seed in one paragraph without jargon.",
            "You have identified at least 2 assumptions.",
            "Seed statement saved to $workspaceFolder\seeds\."
        )

        # ── NOURISH ──
        Add-Heading -Document $doc -Text "Phase 2: NOURISH -- Context Is Fertilizer" -Level 1
        Add-Paragraph -Document $doc -Text "This is the phase most teams skip, and it is the single biggest determinant of output quality. Load the AI workspace with every piece of relevant context before asking it to generate anything." | Out-Null
        Add-Paragraph -Document $doc -Text "What to do:" -Bold | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "Gather inputs: prior art, stakeholder notes, technical constraints, data, competitive analysis, internal docs.",
            "Compile a structured context brief and save it to $workspaceFolder\context\project-name-context.md.",
            "Ask the AI what context is missing -- let it tell you the gaps."
        )
        Add-Paragraph -Document $doc -Text "Prompt template:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Here is everything relevant to this project: [SEED STATEMENT] [DOCUMENTS AND DATA]. Summarize what you now know. Flag contradictions in the source material. Identify what context is MISSING that you would need to do great work. Produce a structured context inventory I can reuse across conversations." | Out-Null
        Add-Paragraph -Document $doc -Text "Completeness check prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Given the seed and context provided, what questions would a domain expert ask that I have not answered? What assumptions should be validated before we move to generation?" | Out-Null
        Add-Paragraph -Document $doc -Text "Multi-agent pattern:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Agent A: Summarize and cross-reference internal documents.",
            "Agent B: Research external best practices and competitive landscape.",
            "Agent C: Map stakeholder positions from communications."
        )
        Add-Paragraph -Document $doc -Text "Completion criteria:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Context brief saved to $workspaceFolder\context\.",
            "AI has confirmed no major contradictions in source material.",
            "You have addressed the AI missing-context questions.",
            "Your prompt could NOT apply to any random company -- it is specific.",
            "A colleague could read the context brief and understand the project."
        )

        # ── GROW ──
        Add-Heading -Document $doc -Text "Phase 3: GROW -- From What Exists to What Should Exist" -Level 1
        Add-Paragraph -Document $doc -Text "Bridge the gap between current state (documented in Nourish) and desired state (defined in Seed). This is directional generation, not open-ended." | Out-Null
        Add-Paragraph -Document $doc -Text "What to do:" -Bold | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "Generate with direction: always include context + outcome + constraints.",
            "Iterate rapidly: each output feeds the next round. Do not start over.",
            "Bias toward quantity: perfection comes in Prune. Generate variants."
        )
        Add-Paragraph -Document $doc -Text "Generation prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Given this context: [paste context brief]. Generate [specific deliverable] that achieves [seed outcome]. Format: [type, structure, length]. Audience: [reader]. Constraints: [boundaries]." | Out-Null
        Add-Paragraph -Document $doc -Text "Iteration prompt (round 2+):" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Here is your previous output: [paste or reference]. Corrections needed: [issues]. New direction: [changes]. Keep: [what worked]. Regenerate with these adjustments." | Out-Null
        Add-Paragraph -Document $doc -Text "Variant generation prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Generate 3 approaches: (1) Conservative -- minimal risk, proven patterns. (2) Ambitious -- stretches current capabilities. (3) Unconventional -- challenges assumptions. Evaluate each against: [seed criteria]. Recommend which to develop further." | Out-Null
        Add-Paragraph -Document $doc -Text "Multi-agent pattern:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Agent A: Conservative approach.",
            "Agent B: Ambitious approach.",
            "Agent C: Unconventional approach.",
            "Evaluate all three against seed criteria before picking a direction."
        )
        Add-Paragraph -Document $doc -Text "Completion criteria:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "At least one complete draft of the deliverable exists.",
            "The draft addresses the seed statement directly.",
            "You have iterated at least twice (no first drafts leave Grow).",
            "You can articulate what is good and what is weak about the output."
        )

        # ── PRUNE ──
        Add-Heading -Document $doc -Text "Phase 4: PRUNE -- Check Your Work, Make Improvements" -Level 1
        Add-Paragraph -Document $doc -Text "AI generates plausible content, not necessarily correct content. This is where human judgment meets AI capability. Turn the AI against its own work." | Out-Null
        Add-Paragraph -Document $doc -Text "What to do:" -Bold | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "Restate the seed when asking for critique -- the agent needs the measuring stick.",
            "Ask the AI to identify gaps, redundancies, logical errors, and risks.",
            "Request a score of 1-10 with justification, then ask it to fix what it found.",
            "Every element must earn its place. Cut ruthlessly."
        )
        Add-Paragraph -Document $doc -Text "Critique prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Review this output against the original goal: [RESTATE SEED]. Identify: (1) Gaps -- what is missing? (2) Redundancies -- what is repeated or unnecessary? (3) Logical errors -- what does not follow? (4) Risks -- what could go wrong if we ship this? Score 1-10 with justification. Then fix what you found." | Out-Null
        Add-Paragraph -Document $doc -Text "Robustness test prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Would this output have caught [specific known past failure]? Walk through the scenario and show where this solution handles or fails to handle it." | Out-Null
        Add-Paragraph -Document $doc -Text "Before/after validation prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Here is the version before pruning: [paste]. Here is the version after: [paste]. Did pruning improve or degrade the work? Be specific about what got better and what got worse." | Out-Null
        Add-Paragraph -Document $doc -Text "Multi-agent pattern:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Agent A: Critique for technical accuracy and completeness.",
            "Agent B: Critique for audience fit, clarity, and actionability.",
            "Where their feedback conflicts, you have found a blind spot worth investigating."
        )
        Add-Paragraph -Document $doc -Text "Completion criteria:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "AI self-critique has been run and addressed.",
            "Output scores 7+ against seed criteria.",
            "No major gaps or logical errors remain.",
            "A colleague could use the output without additional explanation.",
            "Decision made: REPOT? COMPOST? CULTIVATE? Or loop SEED-PRUNE again?"
        )

        # ── REPOT ──
        Add-Heading -Document $doc -Text "Phase 5: REPOT -- Does It Need a Bigger Pot?" -Level 1
        Add-Paragraph -Document $doc -Text "Evaluate whether the project has outgrown its scope, resources, or architecture. This is deliberate scope evolution, not scope creep." | Out-Null
        Add-Paragraph -Document $doc -Text "When to Repot vs. Compost:" -Bold | Out-Null
        Add-Table -Document $doc -Headers @("Signal", "Repot", "Compost instead") -Rows @(
            @("Core architecture", "Sound, needs more room", "Fundamentally wrong"),
            @("Assumptions", "Still valid, scope grew", "Key assumptions invalidated"),
            @("Team energy", "Excited but under-resourced", "Fatigued or disengaged"),
            @("Time ratio", "Building > fixing", "Fixing > building"),
            @("Requirements", "Shifted in scope, not kind", "Shifted in kind or domain"),
            @("Output quality", "Improving each cycle", "Plateaued or declining")
        )
        Add-Paragraph -Document $doc -Text "Prompt template:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Original scope: [seed statement]. Current state: [describe]. Evaluate three options: (a) Constrain back to original scope. (b) Expand with additional resources/time. (c) Split into sub-projects. For each: estimate effort, risk, and time to value." | Out-Null
        Add-Paragraph -Document $doc -Text "Multi-agent pattern:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Agent A: Model the constrained path (what do we cut?).",
            "Agent B: Model the expanded path (what do we need?).",
            "Compare timelines, risks, and resources side by side. The gardener decides."
        )
        Add-Paragraph -Document $doc -Text "Completion criteria:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Decision made: constrain, expand, or split.",
            "If expanding: resource plan drafted.",
            "If splitting: sub-project seeds written.",
            "Updated seed statement saved to $workspaceFolder\seeds\."
        )

        # ── COMPOST ──
        Add-Heading -Document $doc -Text "Phase 6: COMPOST -- Decompose the Old, Fertilize the New" -Level 1
        Add-Paragraph -Document $doc -Text "End a growth cycle deliberately. Composting is not failure -- it is the productive act of breaking down a completed or stalled effort so its nutrients feed the next thing you grow." | Out-Null
        Add-Paragraph -Document $doc -Text "When to Compost:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Core assumptions have been invalidated.",
            "You are spending more time fixing than building.",
            "The problem has been fundamentally reframed.",
            "Team energy is depleted on this direction.",
            "Output quality has plateaued despite iteration."
        )
        Add-Paragraph -Document $doc -Text "Composting prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "This project direction is not working. Before we stop, extract: (1) Every validated assumption (things we proved true). (2) Every invalidated assumption (things we proved false). (3) Reusable components (code, designs, research, templates). (4) Key learnings (what would we do differently?). (5) A NEW seed brief for the next attempt that incorporates all of the above. The new seed should be stronger than the original." | Out-Null
        Add-Paragraph -Document $doc -Text "Archive prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Generate a post-mortem covering: original seed and goals, what was attempted and resulted, root causes of the compost decision, validated learnings, recommended approach for the next cycle. Save to $workspaceFolder\compost\project-name-YYYY-MM-DD.md." | Out-Null
        Add-Paragraph -Document $doc -Text "Multi-agent pattern:" -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Agent A: Perform the post-mortem extraction.",
            "Agent B: Research what has changed in the landscape since you started.",
            "The new seed benefits from both -- internal learnings and external shifts."
        )

        # ── CULTIVATE ──
        Add-Heading -Document $doc -Text "Phase 7: CULTIVATE -- Tend to Several at Once" -Level 1
        Add-Paragraph -Document $doc -Text "Portfolio awareness across active project threads. This is the gardener stepping back to see the whole garden. Recommended cadence: weekly." | Out-Null
        Add-Paragraph -Document $doc -Text "Weekly cultivation prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Here are my active projects with current status: [list each with 2-3 lines, current phase, blockers]. Compare progress across all projects. Flag risks and upcoming dependencies. Identify cross-pollination opportunities. Recommend where to focus this week. Flag any project that may need a Repot or Compost decision." | Out-Null
        Add-Paragraph -Document $doc -Text "Cross-pollination prompt:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Project A just produced [insight/component]. Could this be applied to any of my other active projects? If so, how would it need to be adapted?" | Out-Null
        Add-Paragraph -Document $doc -Text "Maintenance:" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Update $workspaceFolder\cultivate-log.md weekly with: date, active project list and phases, key decisions made, cross-pollination actions taken." | Out-Null

        # ── Good usage patterns ──
        Add-Divider -Document $doc
        Add-Heading -Document $doc -Text "Good usage patterns" -Level 1
        Add-BulletList -Document $doc -Items @(
            "Start with the problem, not `"write me a document.`"",
            "Give the assistant the seed and the real context before asking it to generate.",
            "Let the assistant write into $workspaceFolder so the workspace becomes the source of truth.",
            "Ask for multiple approaches when the direction is still uncertain.",
            "Use critique intentionally before shipping or sharing output.",
            "Every new effort gets a seed. Every important project gets a living context brief.",
            "Every major draft gets pruned before wider review.",
            "Every stalled direction gets composted instead of silently abandoned.",
            "Every week, someone cultivates across the active project set."
        )

        # ── Manager prompts ──
        Add-Heading -Document $doc -Text "Manager shortcut prompts" -Level 2
        Add-BulletList -Document $doc -Items @(
            "Review this workspace and tell me which phase this project is in, what is missing, and what the next best action should be.",
            "Compare the active projects in this workspace, flag risks and dependencies, and recommend where attention should go this week."
        )

        # ── Contributor prompts ──
        Add-Heading -Document $doc -Text "Contributor shortcut prompts" -Level 2
        Add-BulletList -Document $doc -Items @(
            "Help me create a strong seed for this project and save it into $workspaceFolder\seeds.",
            "Turn my notes into a context brief and save it into $workspaceFolder\context.",
            "Review my current draft against the original seed, identify gaps and risks, and improve it."
        )

        # ── Rule of thumb ──
        Add-Heading -Document $doc -Text "Rule of thumb" -Level 2
        Add-BulletList -Document $doc -Items @(
            "If the work feels vague, go back to SEED.",
            "If the output feels generic, improve NOURISH.",
            "If the draft feels weak, iterate in GROW.",
            "If the result feels risky, run PRUNE."
        )

        # ── Minimum inputs ──
        Add-Divider -Document $doc
        Add-Heading -Document $doc -Text "Minimum inputs for each phase" -Level 1
        Add-Table -Document $doc -Headers @("Phase", "Required inputs") -Rows @(
            @("SEED", "Problem statement, audience, urgency, and why it matters now."),
            @("NOURISH", "Prior work, constraints, stakeholder notes, examples, and success criteria."),
            @("GROW", "Desired deliverable, format, audience, and constraints."),
            @("PRUNE", "The original seed statement plus the current draft or output."),
            @("REPOT", "Original scope, current scope, and what has changed."),
            @("COMPOST", "What failed, what was learned, and what should carry forward."),
            @("CULTIVATE", "Current project list, phases, blockers, and upcoming decisions.")
        )

        # ── CLI reference ──
        Add-Divider -Document $doc
        Add-Heading -Document $doc -Text "Full CLI reference" -Level 1
        Add-Table -Document $doc -Headers @("Flag", "Description") -Rows @(
            @("init [name]", "Install the framework into a new or existing workspace."),
            @("upgrade [name]", "Refresh managed files and upgrade the installed skill."),
            @("doctor", "Inspect workspace and skill installation health."),
            @("help", "Show full help text."),
            @("--here", "Install into the current directory instead of creating a folder."),
            @("--root <path>", "Root directory for workspace creation."),
            @("--workspace-name <name>", "Explicit workspace name."),
            @("--skills-root <path>", "Override the Codex skills directory."),
            @("--client <auto|codex|none>", "Control client adapter installation."),
            @("--skip-skill-install", "Do not install the Codex skill."),
            @("--skip-workspace-install", "Do not create or update the workspace files."),
            @("--no-backup", "Skip backups before replacing managed files."),
            @("--json", "Output doctor results as JSON.")
        )

        Save-Docx -Document $doc -Path $Path
    }
    finally {
        Close-WordDocument -Document $doc
        Quit-WordApp -Word $word
    }
}

function Build-Whitepaper {
    param(
        [string]$DocxPath,
        [string]$PdfPath
    )

    $word = $null
    $doc = $null

    try {
        $word = New-WordApp
        $doc = $word.Documents.Add()
        Initialize-DocumentStyle -Document $doc

        # ── Title ──
        Add-Title -Document $doc -Text "The Living Project" -Subtitle "Whitepaper"
        Add-Subtitle -Document $doc -Text "A model-agnostic framework for AI-assisted project work"
        Add-Subtitle -Document $doc -Text "Version $version  |  @the-living-project/the-living-project-cli  |  Author: Chamal Abeysekera  |  CC BY 4.0"
        Add-Divider -Document $doc

        # ── Executive Summary ──
        Add-Heading -Document $doc -Text "Executive summary" -Level 1
        Add-Paragraph -Document $doc -Text "The Living Project is a model-agnostic framework and installable CLI for running AI-assisted project work with stronger context, better iteration discipline, and safer release practices. It combines a one-line public installer, a structured local workspace, an optional Codex skill, and a release process that supports versioned upgrades over time." | Out-Null
        Add-Paragraph -Document $doc -Text "The framework treats projects as living systems. Seeds are planted with clear problem definitions. Context is loaded as fertilizer before generation begins. Outputs grow through directed iteration, get pruned through structured critique, and when directions fail, they are composted -- broken down into validated learnings that feed the next cycle. The workspace itself becomes the durable operating model." | Out-Null
        Add-Paragraph -Document $doc -Text "The current live package is @the-living-project/the-living-project-cli, installable with:" | Out-Null
        Add-Paragraph -Document $doc -Text $installCommand -Code | Out-Null

        # ── The Problem ──
        Add-Heading -Document $doc -Text "The problem" -Level 1
        Add-Paragraph -Document $doc -Text "Most AI-assisted work fails for predictable reasons:" | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Teams start with deliverables instead of the real problem. The first prompt is `"write me a strategy document`" when it should be `"help me understand what problem we are actually solving.`"",
            "Context is incomplete, fragmented, or never written down. The AI gets a thin slice of what matters and fills the gaps with generic best practices.",
            "First drafts are treated as finished work. A single generation pass is shipped without structured critique, review, or iteration.",
            "Scope drift is noticed too late. Requirements shift incrementally until the project is solving a different problem than the one it started with.",
            "Abandoned efforts are not mined for reusable insight. When a direction fails, the learnings die with it instead of feeding the next attempt.",
            "Every new project starts from scratch. There is no reusable system for starting, iterating, reviewing, and completing AI-assisted work."
        )
        Add-Paragraph -Document $doc -Text "The Living Project addresses these issues by turning the workspace itself into a durable, upgradeable operating model that any AI tool can read and write to." | Out-Null

        # ── Framework Design ──
        Add-Heading -Document $doc -Text "Framework design" -Level 1
        Add-Paragraph -Document $doc -Text "The Living Project uses a seven-phase structure organized into a core loop and three strategic phases." | Out-Null
        Add-Paragraph -Document $doc -Text "Core loop: SEED -> NOURISH -> GROW -> PRUNE -> repeat until the output is ready to ship or hand off." -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Strategic phases: REPOT | COMPOST | CULTIVATE -- invoked when scope changes, direction fails, or multiple efforts need portfolio-level management." -Bold | Out-Null

        # Phase table
        Add-Heading -Document $doc -Text "Phase overview" -Level 3
        Add-Table -Document $doc -Headers @("Phase", "Purpose", "Key technique", "Output location") -Rows @(
            @("1. SEED", "Define the real problem and root need.", "5 Whys analysis + 5W framework (Who, What, Where, When, Why).", "$workspaceFolder\seeds\"),
            @("2. NOURISH", "Load every piece of relevant context before generation.", "Context inventory, contradiction detection, gap analysis.", "$workspaceFolder\context\"),
            @("3. GROW", "Generate directional drafts, options, and candidate outputs.", "Variant generation (conservative, ambitious, unconventional). Rapid iteration.", "Working files"),
            @("4. PRUNE", "Critique, improve, reduce risk, and tighten quality.", "Seed-restated critique, 1-10 scoring, robustness testing.", "Refined output"),
            @("5. REPOT", "Restructure scope or architecture when the container is too small.", "Constrain vs. expand vs. split analysis with effort and risk estimates.", "$workspaceFolder\seeds\ (updated)"),
            @("6. COMPOST", "Extract learnings and restart with stronger insight.", "Validated/invalidated assumptions, reusable component extraction, post-mortem.", "$workspaceFolder\compost\"),
            @("7. CULTIVATE", "Manage multiple active projects as a portfolio.", "Weekly review: progress comparison, risk flagging, cross-pollination.", "$workspaceFolder\cultivate-log.md")
        )

        # Detailed phases
        Add-Heading -Document $doc -Text "Phase 1: SEED -- Plant the Question" -Level 3
        Add-Paragraph -Document $doc -Text "Every project begins with a question, not an answer. The Seed phase uses the 5 Whys technique to move past symptoms to root causes, then structures the finding into a one-paragraph seed statement answering: Who is this for? What does it solve? Where does it live? When is it needed? Why does it matter now? The seed is saved to $workspaceFolder\seeds\ and becomes the measuring stick for every subsequent phase. Practitioners also identify at least two assumptions and two blind spots before proceeding." | Out-Null

        Add-Heading -Document $doc -Text "Phase 2: NOURISH -- Context Is Fertilizer" -Level 3
        Add-Paragraph -Document $doc -Text "This is the phase most teams skip, and it is the single biggest determinant of output quality. Nourish loads the AI workspace with prior art, stakeholder notes, technical constraints, data, competitive analysis, and institutional knowledge. The result is a structured context brief saved to $workspaceFolder\context\. The AI validates completeness by flagging contradictions in source material and identifying what context is still missing." | Out-Null

        Add-Heading -Document $doc -Text "Phase 3: GROW -- From What Exists to What Should Exist" -Level 3
        Add-Paragraph -Document $doc -Text "Grow bridges the gap between current state (documented in Nourish) and desired state (defined in Seed). Generation is directional: every prompt includes context, outcome, and constraints. The framework biases toward quantity over perfection -- practitioners generate conservative, ambitious, and unconventional variants, then iterate rapidly. No first draft exits Grow without at least two rounds of refinement." | Out-Null

        Add-Heading -Document $doc -Text "Phase 4: PRUNE -- Check Your Work, Make Improvements" -Level 3
        Add-Paragraph -Document $doc -Text "AI generates plausible content, not necessarily correct content. Prune turns the AI against its own work. The seed statement is restated as the measuring stick. The AI identifies gaps, redundancies, logical errors, and risks, then scores the output 1-10 with justification and repairs what it found. Robustness testing validates the output against known past failures. Every element must earn its place." | Out-Null

        Add-Heading -Document $doc -Text "Phase 5: REPOT -- Does It Need a Bigger Pot?" -Level 3
        Add-Paragraph -Document $doc -Text "Repot evaluates whether a project has outgrown its scope, resources, or architecture. This is deliberate scope evolution, not scope creep. The framework distinguishes Repot from Compost using clear signals: if the core architecture is sound and assumptions are still valid, Repot. If assumptions are invalidated or the team is spending more time fixing than building, Compost instead. Repot produces a constrain, expand, or split decision with updated seed statements." | Out-Null

        Add-Heading -Document $doc -Text "Phase 6: COMPOST -- Decompose the Old, Fertilize the New" -Level 3
        Add-Paragraph -Document $doc -Text "Composting is not failure. It is the productive act of breaking down a completed or stalled effort so its nutrients feed the next thing grown. The Compost phase extracts validated assumptions, invalidated assumptions, reusable components, and key learnings. It produces a post-mortem saved to $workspaceFolder\compost\ and a stronger new seed brief that incorporates everything learned." | Out-Null

        Add-Heading -Document $doc -Text "Phase 7: CULTIVATE -- Tend to Several at Once" -Level 3
        Add-Paragraph -Document $doc -Text "Cultivate provides portfolio awareness across active project threads. On a weekly cadence, practitioners step back to compare progress, flag risks and dependencies, identify cross-pollination opportunities between projects, and decide which efforts need Repot or Compost decisions. The portfolio view is maintained in $workspaceFolder\cultivate-log.md." | Out-Null

        # ── Multi-Agent Patterns ──
        Add-Heading -Document $doc -Text "Multi-agent orchestration" -Level 1
        Add-Paragraph -Document $doc -Text "Each phase includes a documented multi-agent pattern for teams using AI tools that support parallel agent execution:" | Out-Null
        Add-Table -Document $doc -Headers @("Phase", "Agent strategy") -Rows @(
            @("SEED", "Agent A runs 5 Whys. Agent B researches prior solutions. Agent C challenges the problem statement."),
            @("NOURISH", "Agent A summarizes internal docs. Agent B researches external landscape. Agent C maps stakeholder positions."),
            @("GROW", "Agent A generates conservative approach. Agent B generates ambitious approach. Agent C generates unconventional approach."),
            @("PRUNE", "Agent A critiques for technical accuracy. Agent B critiques for audience fit and clarity."),
            @("REPOT", "Agent A models the constrained path. Agent B models the expanded path."),
            @("COMPOST", "Agent A performs post-mortem extraction. Agent B researches landscape changes since project start."),
            @("CULTIVATE", "Each project runs its own agent thread. Cultivate is where the gardener reviews across all threads.")
        )

        # ── Product Architecture ──
        Add-Heading -Document $doc -Text "Product architecture" -Level 1
        Add-Paragraph -Document $doc -Text "The implementation has four layers:" | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "Public npm package -- distributed through npm as @the-living-project/the-living-project-cli. Installable via npx, pnpm dlx, bunx, or yarn dlx. Requires Node.js 18 or later.",
            "CLI runtime -- a single Node.js executable that handles init (create workspace), upgrade (refresh managed files), and doctor (health check). Supports flags for workspace naming, installation location, skill root override, and client adapter control.",
            "Workspace payload -- creates a project folder with $workspaceFolder\ containing seeds, context, compost, phases, cultivate-log, and QUICKSTART.md. A visible START-HERE.md sits at the workspace root.",
            "Optional Codex skill -- installs a local living-project skill into ~/.codex/skills/ when Codex is detected. The skill provides automatic phase routing based on user intent. When Codex is not present, the workspace remains fully usable through the universal prompt in START-HERE.md."
        )

        # ── Workspace Contract ──
        Add-Heading -Document $doc -Text "Workspace contract" -Level 1
        Add-Paragraph -Document $doc -Text "The installer creates a workspace that behaves as the durable memory layer for the project. Files are divided into managed (framework-owned, refreshed on upgrade) and user-owned (never overwritten)." | Out-Null
        Add-Table -Document $doc -Headers @("Path", "Owner", "Purpose") -Rows @(
            @("START-HERE.md", "Managed", "Visible first-run handoff with universal prompt and Codex shortcut."),
            @("$workspaceFolder\QUICKSTART.md", "Managed", "Zero-training start guide."),
            @("$workspaceFolder\phases\", "Managed", "Seven phase guidance files read by the AI assistant."),
            @("$workspaceFolder\.gitignore", "Managed", "Excludes private context and compost from version control."),
            @("$workspaceFolder\seeds\", "User", "Seed statements for each project or sub-project."),
            @("$workspaceFolder\context\", "User", "Context briefs, stakeholder inputs, and working memory."),
            @("$workspaceFolder\compost\", "User", "Post-mortems, validated learnings, and reusable components."),
            @("$workspaceFolder\cultivate-log.md", "User", "Weekly portfolio review journal. Created once, never overwritten.")
        )

        # ── Installation Experience ──
        Add-Heading -Document $doc -Text "Installation experience" -Level 1
        Add-Paragraph -Document $doc -Text "The design goal is zero-training startup." | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "Run one command: $installCommand",
            "Open the generated workspace.",
            "Paste the universal prompt from START-HERE.md into any AI tool.",
            "The AI reads the workspace, detects the current phase, and guides the user forward."
        )
        Add-Paragraph -Document $doc -Text "This minimizes onboarding burden and makes the framework usable by people who do not already know the vocabulary. The universal prompt works with any capable AI tool. When the Codex skill is installed, users can also invoke the framework with a shorthand trigger." | Out-Null

        # ── CLI Reference ──
        Add-Heading -Document $doc -Text "CLI reference" -Level 1
        Add-Table -Document $doc -Headers @("Command / flag", "Description") -Rows @(
            @("init [workspace-name]", "Install the framework. Creates workspace folder, skill, and all framework files."),
            @("upgrade [workspace-name]", "Refresh managed files and upgrade the installed skill. Preserves all user work."),
            @("doctor", "Inspect workspace and skill health. Reports installed versions and missing components."),
            @("help", "Show full help text with all available flags and examples."),
            @("--here", "Install into the current directory instead of creating a new folder."),
            @("--root <path>", "Root directory for workspace creation."),
            @("--workspace-name <name>", "Explicit workspace name (alternative to positional argument)."),
            @("--skills-root <path>", "Override the default Codex skills directory (~/.codex/skills/)."),
            @("--client <auto|codex|none>", "Control client adapter: auto detects Codex, codex forces install, none skips."),
            @("--skip-skill-install", "Do not install the Codex skill."),
            @("--skip-workspace-install", "Do not create or update workspace files."),
            @("--no-backup", "Skip backups before replacing managed files during upgrade."),
            @("--json", "Output doctor results as machine-readable JSON.")
        )

        # ── Model-Agnostic Strategy ──
        Add-Heading -Document $doc -Text "Model-agnostic strategy" -Level 1
        Add-Paragraph -Document $doc -Text "The Living Project is not tied to a single model vendor. It stays portable by separating framework content, workspace structure, and optional client-specific integrations." | Out-Null
        Add-Paragraph -Document $doc -Text "The same workspace can be used with:" | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Codex, using the installed local skill for automatic phase routing.",
            "Claude, ChatGPT, Gemini, or any other AI tool, using the universal prompt in START-HERE.md.",
            "Custom integrations, by reading the phase files and workspace structure directly."
        )
        Add-Paragraph -Document $doc -Text "This keeps the method portable while still allowing richer local experiences where supported." | Out-Null

        # ── Upgrade Model ──
        Add-Heading -Document $doc -Text "Upgrade model" -Level 1
        Add-Paragraph -Document $doc -Text "The project supports versioned distribution and repeatable upgrades. This is essential for enterprise use because the framework itself can evolve while active project material remains intact." | Out-Null
        Add-Paragraph -Document $doc -Text "How upgrades work:" | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "Run: npx -y @the-living-project/the-living-project-cli upgrade",
            "Managed files (phases, QUICKSTART.md, .gitignore, START-HERE.md) are backed up, then replaced with the latest version.",
            "User work in seeds, context, compost, and cultivate-log.md is never touched.",
            "The Codex skill is replaced with the new version after backing up the previous installation.",
            "An install-manifest.json records the version, timestamp, and previous version for traceability."
        )

        # ── Release Infrastructure ──
        Add-Heading -Document $doc -Text "Release infrastructure" -Level 1
        Add-BulletList -Document $doc -Items @(
            "Source of truth: GitHub (The-Living-Project/the-living-project-cli).",
            "Distribution channel: npm (@the-living-project/the-living-project-cli).",
            "Release automation: GitHub Actions with npm trusted publishing via OIDC.",
            "CI validation: package behavior is tested on main and pull requests.",
            "Tag format: living-project-vX.Y.Z.",
            "Tagged releases publish automatically through the release workflow."
        )

        # ── Release History ──
        Add-Heading -Document $doc -Text "Release history" -Level 1
        Add-Table -Document $doc -Headers @("Version", "Summary") -Rows @(
            @("3.0.0", "First public npm release. Full workspace framework, CLI runtime, and Codex skill."),
            @("3.0.1", "Improved executable mapping for npm launch behavior."),
            @("3.0.2", "Simplified direct npx usage."),
            @("3.0.3", "Fixed Windows packaging behavior for workspace template .gitignore. Verified one-line install flow.")
        )

        # ── Key Principles ──
        Add-Heading -Document $doc -Text "Key principles" -Level 1
        Add-NumberedList -Document $doc -Items @(
            "Context is fertilizer. Always front-load context before generation.",
            "Never start with `"write me a...`" Start with the problem, not the deliverable.",
            "Use parallel agents. Multiple perspectives beat sequential refinement.",
            "Restate the seed when pruning. The agent needs the measuring stick.",
            "Composting is productive. Nothing is wasted -- learnings feed the next cycle.",
            "The workspace is the system. Not just a prompt pack -- it is an operational wrapper."
        )

        # ── Current State ──
        Add-Heading -Document $doc -Text "Current state" -Level 1
        Add-Paragraph -Document $doc -Text "As of version $version`:" | Out-Null
        Add-BulletList -Document $doc -Items @(
            "The GitHub repository is live and is the source of truth for all changes.",
            "The public npm package is published and installable worldwide.",
            "The one-line installer is tested and working across Windows, macOS, and Linux.",
            "Trusted publishing is configured through GitHub Actions for secure, automated releases.",
            "CI validates package behavior on main and pull requests.",
            "The workspace is usable with any AI tool through the universal prompt.",
            "The Codex skill is auto-installed when Codex is detected, providing automatic phase routing."
        )

        # ── Why This Matters ──
        Add-Heading -Document $doc -Text "Why this matters" -Level 1
        Add-Paragraph -Document $doc -Text "The Living Project is not just a prompt pack or template bundle. It is an operational wrapper around AI-assisted project work. Its main value is not only better outputs, but a better system for producing, revising, and sustaining those outputs across time." | Out-Null
        Add-Paragraph -Document $doc -Text "In practice, it gives teams:" | Out-Null
        Add-BulletList -Document $doc -Items @(
            "A repeatable way to start projects -- from root cause, not from a requested deliverable.",
            "A consistent method for loading context -- so AI generation is specific, not generic.",
            "A structured review habit -- so outputs are critiqued before they are shipped.",
            "A productive way to handle failure -- composting extracts value from every stalled direction.",
            "Portfolio awareness -- so multiple projects are managed as a garden, not a pile.",
            "An upgradeable framework -- that evolves over time without destroying user work.",
            "A portable system -- that moves across AI tools without vendor lock-in."
        )

        # ── Conclusion ──
        Add-Heading -Document $doc -Text "Conclusion" -Level 1
        Add-Paragraph -Document $doc -Text "The Living Project has moved from concept to deployable product. It now exists as a public npm package, a working CLI, a reusable workspace framework, and a release-managed system that can be improved over time without breaking user adoption. The seven-phase model provides the discipline most AI-assisted work is missing: start with the real problem, load sufficient context, generate with direction, critique before shipping, and recycle learnings when directions change." | Out-Null

        Save-Docx -Document $doc -Path $DocxPath
        Save-Pdf -Document $doc -Path $PdfPath
    }
    finally {
        Close-WordDocument -Document $doc
        Quit-WordApp -Word $word
    }
}

Build-CheatSheet `
    -Path (Join-Path $documentsDir "the_living_project_cheatsheet_$versionTag.docx")

Build-CheatSheetV3 `
    -Path (Join-Path $documentsDir "the_living_project_cheatsheet_${versionTag}_detailed.docx")

Build-Whitepaper `
    -DocxPath (Join-Path $documentsDir "the_living_project_whitepaper_$versionTag.docx") `
    -PdfPath (Join-Path $documentsDir "the_living_project_whitepaper_$versionTag.pdf")

Write-Host "Generated updated The Living Project documents in $documentsDir"
