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

function New-WordApp {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    return $word
}

function Close-WordDocument {
    param(
        $Document
    )

    if ($null -ne $Document) {
        $Document.Close([ref]$false)
    }
}

function Quit-WordApp {
    param(
        $Word
    )

    if ($null -ne $Word) {
        $Word.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Word) | Out-Null
    }
}

function Add-Paragraph {
    param(
        $Document,
        [string]$Text,
        [int]$FontSize = 11,
        [switch]$Bold,
        [int]$SpaceAfter = 6
    )

    $paragraph = $Document.Content.Paragraphs.Add()
    $paragraph.Range.Text = $Text
    $paragraph.Range.Font.Size = $FontSize
    $paragraph.Range.Font.Bold = [int]$Bold.IsPresent
    $paragraph.SpaceAfter = $SpaceAfter
    $paragraph.Range.InsertParagraphAfter() | Out-Null
    return $paragraph
}

function Add-BulletList {
    param(
        $Document,
        [string[]]$Items
    )

    foreach ($item in $Items) {
        $paragraph = $Document.Content.Paragraphs.Add()
        $paragraph.Range.Text = $item
        $paragraph.Range.Font.Size = 11
        $paragraph.Range.ListFormat.ApplyBulletDefault()
        $paragraph.SpaceAfter = 0
        $paragraph.Range.InsertParagraphAfter() | Out-Null
    }

    $Document.Content.Paragraphs.Add().Range.InsertParagraphAfter() | Out-Null
}

function Add-NumberedList {
    param(
        $Document,
        [string[]]$Items
    )

    foreach ($item in $Items) {
        $paragraph = $Document.Content.Paragraphs.Add()
        $paragraph.Range.Text = $item
        $paragraph.Range.Font.Size = 11
        $paragraph.Range.ListFormat.ApplyNumberDefault()
        $paragraph.SpaceAfter = 0
        $paragraph.Range.InsertParagraphAfter() | Out-Null
    }

    $Document.Content.Paragraphs.Add().Range.InsertParagraphAfter() | Out-Null
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
    $table.Borders.Enable = 1
    $table.Range.Font.Size = 10
    $table.Rows.Item(1).Range.Font.Bold = 1

    for ($col = 0; $col -lt $Headers.Count; $col++) {
        $table.Cell(1, $col + 1).Range.Text = $Headers[$col]
    }

    for ($row = 0; $row -lt $Rows.Count; $row++) {
        for ($col = 0; $col -lt $Headers.Count; $col++) {
            $table.Cell($row + 2, $col + 1).Range.Text = [string]$Rows[$row][$col]
        }
    }

    $table.Range.InsertParagraphAfter() | Out-Null
    $Document.Content.Paragraphs.Add().Range.InsertParagraphAfter() | Out-Null
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

        Add-Paragraph -Document $doc -Text "The Living Project Cheat Sheet" -FontSize 20 -Bold -SpaceAfter 10 | Out-Null
        Add-Paragraph -Document $doc -Text "Current public release: $version" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "One-line install" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text $installCommand -FontSize 11 | Out-Null

        Add-Paragraph -Document $doc -Text "What the installer creates" -FontSize 14 -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "START-HERE.md for the first-run prompt",
            "$workspaceFolder\seeds for project seed statements",
            "$workspaceFolder\context for context briefs and working memory",
            "$workspaceFolder\phases for the seven phase guides",
            "$workspaceFolder\compost for post-mortems and learnings",
            "$workspaceFolder\cultivate-log.md for portfolio awareness"
        )

        Add-Paragraph -Document $doc -Text "Use this prompt" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Use The Living Project framework in this folder. Treat this as my active workspace. Read `$workspaceFolder\QUICKSTART.md`, figure out the right phase automatically, ask me only the minimum questions needed, and write the outputs into `$workspaceFolder` as we go." | Out-Null
        Add-Paragraph -Document $doc -Text "Codex shortcut: Use `$living-project in this folder and guide me to the right next step." | Out-Null

        Add-Paragraph -Document $doc -Text "The seven phases" -FontSize 14 -Bold | Out-Null
        Add-Table -Document $doc -Headers @("Phase", "Purpose") -Rows @(
            @("SEED", "Define the real problem and root need."),
            @("NOURISH", "Load complete context before generation."),
            @("GROW", "Generate drafts, options, and candidate outputs."),
            @("PRUNE", "Critique, improve, and reduce risk."),
            @("REPOT", "Restructure scope or architecture deliberately."),
            @("COMPOST", "Extract lessons and restart with stronger insight."),
            @("CULTIVATE", "Manage multiple active projects as a portfolio.")
        )

        Add-Paragraph -Document $doc -Text "How to know where to start" -FontSize 14 -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "New project or fuzzy idea: start with SEED.",
            "You already have notes, requirements, or research: move into NOURISH.",
            "You need a first draft or multiple options: move into GROW.",
            "You already have output and want it improved: move into PRUNE.",
            "Scope is drifting or the container feels too small: use REPOT.",
            "The current direction is failing: use COMPOST.",
            "You need priorities across multiple efforts: use CULTIVATE."
        )

        Add-Paragraph -Document $doc -Text "Upgrade commands" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "npx -y @the-living-project/the-living-project-cli upgrade" | Out-Null
        Add-Paragraph -Document $doc -Text "npx -y @the-living-project/the-living-project-cli doctor" | Out-Null

        Add-Paragraph -Document $doc -Text "Release model" -FontSize 14 -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "GitHub is the source of truth for changes and releases.",
            "npm is the public distribution channel.",
            "Trusted publishing is configured for tagged GitHub releases.",
            "The standard release tag format is living-project-vX.Y.Z."
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

        Add-Paragraph -Document $doc -Text "The Living Project v3 Cheat Sheet" -FontSize 20 -Bold -SpaceAfter 10 | Out-Null
        Add-Paragraph -Document $doc -Text "High-level prompt guidance for any user" -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Install: $installCommand" | Out-Null

        Add-Paragraph -Document $doc -Text "Core thesis" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Context is the strongest determinant of output quality. Every phase should clarify intent, load context, generate deliberately, and improve with critique." | Out-Null

        Add-Paragraph -Document $doc -Text "Core loop" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "SEED -> NOURISH -> GROW -> PRUNE -> repeat" | Out-Null
        Add-Paragraph -Document $doc -Text "Strategic phases: REPOT | COMPOST | CULTIVATE" | Out-Null

        Add-Paragraph -Document $doc -Text "Phase guide" -FontSize 14 -Bold | Out-Null
        Add-Table -Document $doc -Headers @("Phase", "What to do", "Prompt guidance") -Rows @(
            @("SEED", "Find the root problem, answer the 5Ws, and write a clear seed statement.", "Ask the assistant to run 5 Whys on the problem, challenge assumptions, and produce a one-paragraph seed statement with blind spots."),
            @("NOURISH", "Gather the relevant documents, stakeholder inputs, constraints, and prior work.", "Ask the assistant to synthesize the project context, flag contradictions, and tell you what important context is still missing."),
            @("GROW", "Generate directional drafts, options, and iterations using the seed and context.", "Ask for multiple approaches, then compare them against the seed criteria before developing one further."),
            @("PRUNE", "Critique, tighten, simplify, and reduce risk before shipping the output.", "Ask the assistant to review the draft against the original goal, identify gaps and risks, score it, and improve it."),
            @("REPOT", "Decide whether the project has outgrown its current scope, structure, or resources.", "Ask for a comparison of constrained, expanded, and split-project options, including risks, effort, and time to value."),
            @("COMPOST", "Extract validated learnings, reusable pieces, and a stronger next seed.", "Ask the assistant to summarize validated and invalidated assumptions, reusable components, and a stronger restart brief."),
            @("CULTIVATE", "Compare multiple active efforts, risks, blockers, and cross-pollination opportunities.", "Ask the assistant to review all active projects together and recommend where attention should go this week.")
        )

        Add-Paragraph -Document $doc -Text "Good usage patterns" -FontSize 14 -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Start with the problem, not the deliverable.",
            "Feed the assistant enough context to be specific.",
            "Ask for options before converging too early.",
            "Use critique before sharing work broadly.",
            "Treat $workspaceFolder as the durable memory layer for the project."
        )

        Add-Paragraph -Document $doc -Text "Current state" -FontSize 14 -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Public npm package is live at @the-living-project/the-living-project-cli.",
            "The standard install command is tested and working.",
            "GitHub Actions trusted publishing is configured for tagged releases.",
            "Codex skill support is installed when available, but the workspace also works with a universal prompt."
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

        Add-Paragraph -Document $doc -Text "The Living Project Whitepaper" -FontSize 20 -Bold -SpaceAfter 10 | Out-Null
        Add-Paragraph -Document $doc -Text "Version $version" -Bold | Out-Null

        Add-Paragraph -Document $doc -Text "Executive summary" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "The Living Project is a model-agnostic framework and installable CLI for AI-assisted project work. It combines a one-line public installer, a structured workspace, an optional Codex skill, and an upgrade model that preserves user work while refreshing managed framework files." | Out-Null

        Add-Paragraph -Document $doc -Text "Live public package" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "@the-living-project/the-living-project-cli" | Out-Null
        Add-Paragraph -Document $doc -Text "Install command: $installCommand" | Out-Null

        Add-Paragraph -Document $doc -Text "The problem this solves" -FontSize 14 -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "Teams often start with deliverables instead of the real problem.",
            "Context is incomplete or never carried forward cleanly.",
            "First drafts are over-trusted and under-reviewed.",
            "Scope drift is recognized too late.",
            "Abandoned work rarely becomes reusable insight."
        )

        Add-Paragraph -Document $doc -Text "Framework design" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "The Living Project uses a seven-phase model: SEED, NOURISH, GROW, PRUNE, REPOT, COMPOST, and CULTIVATE. The core loop is SEED to NOURISH to GROW to PRUNE, repeating until the output is ready to ship or hand off." | Out-Null

        Add-Paragraph -Document $doc -Text "Phase guidance" -FontSize 14 -Bold | Out-Null
        Add-Table -Document $doc -Headers @("Phase", "What to do", "Prompt guidance") -Rows @(
            @("SEED", "Clarify the real problem, root need, audience, and urgency.", "Ask for root-cause analysis, a structured seed statement, key assumptions, and likely blind spots."),
            @("NOURISH", "Load context from notes, documents, constraints, and prior work.", "Ask for a context inventory, contradictions, and the questions a domain expert would still need answered."),
            @("GROW", "Generate one or more directional outputs and iterate.", "Ask for multiple approaches, clear tradeoffs, and regeneration based on what should change and what should stay."),
            @("PRUNE", "Critique and improve the work against the original goal.", "Ask for gaps, redundancies, logic issues, risks, a score, and a repaired version."),
            @("REPOT", "Re-evaluate the shape of the project when the current container is too small.", "Ask for a pros and cons analysis across constraining, expanding, or splitting the effort."),
            @("COMPOST", "Extract value from a stalled or completed direction.", "Ask for validated assumptions, invalidated assumptions, reusable components, and a stronger restart brief."),
            @("CULTIVATE", "Step back and manage multiple active efforts as a portfolio.", "Ask for risk review, dependencies, cross-pollination opportunities, and recommendations for where attention should go next.")
        )

        Add-Paragraph -Document $doc -Text "Product architecture" -FontSize 14 -Bold | Out-Null
        Add-NumberedList -Document $doc -Items @(
            "Public npm package for distribution.",
            "CLI runtime for init, upgrade, and doctor.",
            "Workspace payload under $workspaceFolder.",
            "Optional Codex skill support through the $skillName skill."
        )

        Add-Paragraph -Document $doc -Text "Workspace contract" -FontSize 14 -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "START-HERE.md is the visible first-run handoff.",
            "$workspaceFolder\seeds stores seed statements.",
            "$workspaceFolder\context stores context briefs and working memory.",
            "$workspaceFolder\phases stores reusable guidance for the framework.",
            "$workspaceFolder\compost stores post-mortems and extracted learnings.",
            "$workspaceFolder\cultivate-log.md tracks portfolio and weekly review."
        )

        Add-Paragraph -Document $doc -Text "Current release state" -FontSize 14 -Bold | Out-Null
        Add-BulletList -Document $doc -Items @(
            "GitHub repository is live and is the source of truth.",
            "Public npm package is published.",
            "Trusted publishing is configured through GitHub Actions.",
            "CI validates package behavior on main and pull requests.",
            "The one-line install command is tested and working."
        )

        Add-Paragraph -Document $doc -Text "Release model" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "Standard tag format: living-project-vX.Y.Z" | Out-Null
        Add-Paragraph -Document $doc -Text "Tagged releases publish through GitHub Actions with npm trusted publishing." | Out-Null

        Add-Paragraph -Document $doc -Text "Conclusion" -FontSize 14 -Bold | Out-Null
        Add-Paragraph -Document $doc -Text "The Living Project has moved from concept to working product: a public package, a working installer, a structured workspace framework, and an upgradeable operating model for AI-assisted project work." | Out-Null

        Save-Docx -Document $doc -Path $DocxPath
        Save-Pdf -Document $doc -Path $PdfPath
    }
    finally {
        Close-WordDocument -Document $doc
        Quit-WordApp -Word $word
    }
}

$cheatSheetPaths = @(
    (Join-Path $documentsDir "organic_development_cheatsheet.docx"),
    (Join-Path $documentsDir "the_living_project_cheatsheet_v3.docx")
)

$detailedCheatSheetPaths = @(
    (Join-Path $documentsDir "organic_development_cheatsheet_v2.docx"),
    (Join-Path $documentsDir "the_living_project_cheatsheet_v3_detailed.docx")
)

foreach ($path in $cheatSheetPaths) {
    Build-CheatSheet -Path $path
}

foreach ($path in $detailedCheatSheetPaths) {
    Build-CheatSheetV3 -Path $path
}

Build-Whitepaper `
    -DocxPath (Join-Path $documentsDir "Organic  Product Development.docx") `
    -PdfPath (Join-Path $documentsDir "organic_development_v2.pdf")

Build-Whitepaper `
    -DocxPath (Join-Path $documentsDir "The Living Project Whitepaper.docx") `
    -PdfPath (Join-Path $documentsDir "the_living_project_v3.pdf")

Write-Host "Generated updated The Living Project documents in $documentsDir"
