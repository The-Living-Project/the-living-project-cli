#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const packageRoot = path.resolve(__dirname, "..");
const manifest = JSON.parse(
  fs.readFileSync(path.join(packageRoot, "package-manifest.json"), "utf8"),
);

const payloadRoot = path.join(packageRoot, "payload");
const workspaceSource = path.join(payloadRoot, "workspace");
const skillSource = path.join(
  payloadRoot,
  "skill",
  manifest.skillFolderName,
);
const defaultSkillsRoot = path.join(os.homedir(), ".codex", "skills");

const colors = {
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  cyan: "\x1b[36m",
  red: "\x1b[31m",
  dim: "\x1b[2m",
  reset: "\x1b[0m",
};

function colorize(text, color) {
  if (!process.stdout.isTTY) {
    return text;
  }
  return `${colors[color] ?? ""}${text}${colors.reset}`;
}

function logStep(message, color = "cyan") {
  console.log(colorize(message, color));
}

function logError(message) {
  console.error(colorize(message, "red"));
}

function printHelp() {
  console.log(`
The Living Project ${manifest.version}

Usage:
  living-project init [workspace-name] [options]
  living-project upgrade [workspace-name] [options]
  living-project doctor [options]
  living-project help

Commands:
  init       Install the framework into a new or existing workspace
  upgrade    Refresh managed files and upgrade the installed skill
  doctor     Inspect workspace and skill installation health
  help       Show this help text

Options:
  --here                   Install into the current directory instead of creating a folder
  --root <path>            Root directory for workspace creation
  --workspace-name <name>  Explicit workspace name
  --skills-root <path>     Override the Codex skills directory
  --client <auto|codex|none>
                           Control client adapter installation
  --skip-skill-install     Do not install the Codex skill
  --skip-workspace-install Do not create or update the workspace files
  --no-backup              Skip backups before replacing managed files
  --json                   Output doctor results as JSON
  -h, --help               Show this help text

Examples:
  living-project init
  living-project init "Acme Migration"
  living-project init --here
  living-project upgrade --here
  living-project doctor --here
  npx -y @your-org/the-living-project-cli init "My Project"
`);
}

function parseArgs(argv) {
  const args = [...argv];
  let command = "init";

  if (args[0] && !args[0].startsWith("-")) {
    command = args.shift();
  }

  const options = {
    here: false,
    root: process.cwd(),
    workspaceName: null,
    skillsRoot: defaultSkillsRoot,
    client: "auto",
    skipSkillInstall: false,
    skipWorkspaceInstall: false,
    noBackup: false,
    json: false,
    help: false,
  };
  const positional = [];

  for (let index = 0; index < args.length; index += 1) {
    const value = args[index];

    if (value === "--here") {
      options.here = true;
      continue;
    }
    if (value === "--skip-skill-install") {
      options.skipSkillInstall = true;
      continue;
    }
    if (value === "--skip-workspace-install") {
      options.skipWorkspaceInstall = true;
      continue;
    }
    if (value === "--no-backup") {
      options.noBackup = true;
      continue;
    }
    if (value === "--json") {
      options.json = true;
      continue;
    }
    if (value === "-h" || value === "--help") {
      options.help = true;
      continue;
    }
    if (
      value === "--root" ||
      value === "--workspace-name" ||
      value === "--skills-root" ||
      value === "--client"
    ) {
      const next = args[index + 1];
      if (!next) {
        throw new Error(`Missing value for ${value}`);
      }
      index += 1;
      if (value === "--root") {
        options.root = path.resolve(next);
      } else if (value === "--workspace-name") {
        options.workspaceName = next;
      } else if (value === "--skills-root") {
        options.skillsRoot = path.resolve(next);
      } else if (value === "--client") {
        options.client = next;
      }
      continue;
    }

    positional.push(value);
  }

  if (!options.workspaceName && positional.length > 0) {
    options.workspaceName = positional[0];
  }

  return { command, options };
}

function ensureDir(targetPath) {
  fs.mkdirSync(targetPath, { recursive: true });
}

function getFullPath(targetPath) {
  return fs.realpathSync.native(targetPath);
}

function assertSafeChildPath(rootPath, candidatePath, label) {
  ensureDir(rootPath);
  const rootFull = getFullPath(rootPath);
  const candidateFull = path.resolve(candidatePath);
  const normalizedRoot = normalizeForComparison(rootFull);
  const normalizedCandidate = normalizeForComparison(candidateFull);
  const rootWithSep = normalizedRoot.endsWith(path.sep)
    ? normalizedRoot
    : `${normalizedRoot}${path.sep}`;

  if (normalizedCandidate !== normalizedRoot && !normalizedCandidate.startsWith(rootWithSep)) {
    throw new Error(
      `${label} path is outside the allowed root. Root: ${rootFull} Candidate: ${candidateFull}`,
    );
  }

  return candidateFull;
}

function normalizeForComparison(targetPath) {
  return process.platform === "win32" ? targetPath.toLowerCase() : targetPath;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, data) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
}

function readInstalledVersion(manifestPath) {
  if (!fs.existsSync(manifestPath)) {
    return null;
  }
  try {
    return readJson(manifestPath).version ?? null;
  } catch {
    return null;
  }
}

function copyPath(sourcePath, destinationPath) {
  ensureDir(path.dirname(destinationPath));
  fs.cpSync(sourcePath, destinationPath, {
    recursive: true,
    force: true,
  });
}

function removePath(targetPath) {
  if (fs.existsSync(targetPath)) {
    fs.rmSync(targetPath, { recursive: true, force: true });
  }
}

function backupPath(sourcePath, backupRoot, noBackup) {
  if (noBackup || !fs.existsSync(sourcePath)) {
    return null;
  }
  ensureDir(backupRoot);
  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  const leaf = path.basename(sourcePath);
  const destination = path.join(backupRoot, `${leaf}-${stamp}`);
  copyPath(sourcePath, destination);
  return destination;
}

function updateRootGitignore(workspacePath) {
  const gitignorePath = path.join(workspacePath, ".gitignore");
  const startMarker = "# >>> living-project >>>";
  const endMarker = "# <<< living-project <<<";
  const block = [
    startMarker,
    ".living-project/context/*.private.md",
    ".living-project/compost/*.private.md",
    endMarker,
  ].join("\n");

  if (!fs.existsSync(gitignorePath)) {
    fs.writeFileSync(gitignorePath, `${block}\n`, "utf8");
    return;
  }

  const existing = fs.readFileSync(gitignorePath, "utf8");
  const pattern = new RegExp(
    `${escapeRegex(startMarker)}[\\s\\S]*?${escapeRegex(endMarker)}`,
    "m",
  );

  if (pattern.test(existing)) {
    fs.writeFileSync(gitignorePath, existing.replace(pattern, block), "utf8");
    return;
  }

  const separator = existing.endsWith("\n") || existing.length === 0 ? "" : "\n";
  fs.writeFileSync(gitignorePath, `${existing}${separator}${block}\n`, "utf8");
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function resolveWorkspacePath(options) {
  if (options.here) {
    return path.resolve(options.root);
  }
  if (!options.workspaceName && fs.existsSync(path.join(options.root, manifest.workspaceFolderName))) {
    return path.resolve(options.root);
  }
  const workspaceName = options.workspaceName || "The Living Project Workspace";
  return path.resolve(options.root, workspaceName);
}

function detectCodexAvailability(skillsRoot) {
  const codexHome = path.dirname(skillsRoot);
  return fs.existsSync(codexHome) || fs.existsSync(skillsRoot);
}

function shouldInstallCodexSkill(options) {
  if (options.skipSkillInstall || options.client === "none") {
    return false;
  }
  if (options.client === "codex") {
    return true;
  }
  return detectCodexAvailability(options.skillsRoot);
}

function installSkill(options) {
  const skillDestination = path.join(options.skillsRoot, manifest.skillFolderName);
  const safeSkillDestination = assertSafeChildPath(
    options.skillsRoot,
    skillDestination,
    "Skill destination",
  );
  const backupRoot = path.join(options.skillsRoot, ".backups", "skills");
  const previousVersion = readInstalledVersion(
    path.join(safeSkillDestination, "install-manifest.json"),
  );
  const backupPathResult = backupPath(safeSkillDestination, backupRoot, options.noBackup);

  removePath(safeSkillDestination);
  ensureDir(options.skillsRoot);
  copyPath(skillSource, safeSkillDestination);

  writeJson(path.join(safeSkillDestination, "install-manifest.json"), {
    packageId: manifest.packageId,
    version: manifest.version,
    installedAt: new Date().toISOString(),
    previousVersion,
    backupPath: backupPathResult,
    installType: "codex-skill",
  });

  return safeSkillDestination;
}

function installWorkspace(options) {
  const workspacePath = resolveWorkspacePath(options);
  const safeWorkspacePath = assertSafeChildPath(options.root, workspacePath, "Workspace destination");
  const frameworkPath = path.join(safeWorkspacePath, manifest.workspaceFolderName);
  const frameworkBackupRoot = path.join(frameworkPath, "backups", "framework");
  const previousVersion = readInstalledVersion(path.join(frameworkPath, "install-manifest.json"));

  ensureDir(safeWorkspacePath);
  ensureDir(frameworkPath);

  if (previousVersion) {
    backupPath(path.join(frameworkPath, "phases"), frameworkBackupRoot, options.noBackup);
    backupPath(path.join(frameworkPath, "QUICKSTART.md"), frameworkBackupRoot, options.noBackup);
    backupPath(path.join(frameworkPath, ".gitignore"), frameworkBackupRoot, options.noBackup);
    backupPath(path.join(safeWorkspacePath, "START-HERE.md"), frameworkBackupRoot, options.noBackup);
  }

  copyManagedDirectory(
    path.join(workspaceSource, ".living-project", "phases"),
    path.join(frameworkPath, "phases"),
  );
  copyManagedFile(
    path.join(workspaceSource, ".living-project", "QUICKSTART.md"),
    path.join(frameworkPath, "QUICKSTART.md"),
  );
  copyManagedFile(
    path.join(workspaceSource, ".living-project", ".gitignore"),
    path.join(frameworkPath, ".gitignore"),
  );
  copyManagedFile(
    path.join(workspaceSource, "START-HERE.md"),
    path.join(safeWorkspacePath, "START-HERE.md"),
  );

  ensureDir(path.join(frameworkPath, "seeds"));
  ensureDir(path.join(frameworkPath, "context"));
  ensureDir(path.join(frameworkPath, "compost"));

  const cultivateLogPath = path.join(frameworkPath, "cultivate-log.md");
  if (!fs.existsSync(cultivateLogPath)) {
    copyManagedFile(
      path.join(workspaceSource, ".living-project", "cultivate-log.md"),
      cultivateLogPath,
    );
  }

  updateRootGitignore(safeWorkspacePath);

  writeJson(path.join(frameworkPath, "install-manifest.json"), {
    packageId: manifest.packageId,
    version: manifest.version,
    installedAt: new Date().toISOString(),
    previousVersion,
    rootPath: safeWorkspacePath,
    workspaceName: path.basename(safeWorkspacePath),
    managedFiles: [
      "START-HERE.md",
      ".living-project/QUICKSTART.md",
      ".living-project/.gitignore",
      ".living-project/phases/*",
    ],
  });

  return safeWorkspacePath;
}

function copyManagedFile(sourcePath, destinationPath) {
  ensureDir(path.dirname(destinationPath));
  fs.copyFileSync(sourcePath, destinationPath);
}

function copyManagedDirectory(sourcePath, destinationPath) {
  removePath(destinationPath);
  ensureDir(path.dirname(destinationPath));
  copyPath(sourcePath, destinationPath);
}

function runInitLike(command, options) {
  const actions = [];
  const notes = [];

  logStep("");
  logStep(`The Living Project ${manifest.version}`, "green");
  logStep("");

  let skillDestination = null;
  if (shouldInstallCodexSkill(options)) {
    logStep(`Installing Codex skill into ${path.join(options.skillsRoot, manifest.skillFolderName)}`);
    skillDestination = installSkill(options);
    actions.push("codex-skill");
  } else {
    notes.push(
      "Codex skill install skipped. The workspace remains fully usable with the universal prompt in START-HERE.md.",
    );
  }

  let workspacePath = null;
  if (!options.skipWorkspaceInstall) {
    const plannedWorkspacePath = resolveWorkspacePath(options);
    logStep(`Preparing workspace in ${plannedWorkspacePath}`);
    workspacePath = installWorkspace(options);
    actions.push(command === "upgrade" ? "workspace-upgrade" : "workspace-init");
  }

  logStep("");
  logStep(command === "upgrade" ? "Upgrade complete." : "Install complete.", "green");
  if (workspacePath) {
    logStep(`Workspace: ${workspacePath}`, "yellow");
  }
  if (skillDestination) {
    logStep(`Skill: ${skillDestination}`, "yellow");
  }
  if (notes.length > 0) {
    logStep("");
    for (const note of notes) {
      console.log(colorize(`Note: ${note}`, "dim"));
    }
  }
  if (workspacePath) {
    logStep("");
    logStep("Next step:", "green");
    logStep(`Open ${path.join(workspacePath, "START-HERE.md")} and paste the universal prompt into your AI tool.`);
  }

  return { actions, skillDestination, workspacePath, notes };
}

function runDoctor(options) {
  const workspacePath = resolveWorkspacePath(options);
  const frameworkPath = path.join(workspacePath, manifest.workspaceFolderName);
  const workspaceManifestPath = path.join(frameworkPath, "install-manifest.json");
  const skillPath = path.join(options.skillsRoot, manifest.skillFolderName);
  const skillManifestPath = path.join(skillPath, "install-manifest.json");
  const rootGitignore = path.join(workspacePath, ".gitignore");
  const startHerePath = path.join(workspacePath, "START-HERE.md");

  const result = {
    packageVersion: manifest.version,
    workspacePath,
    workspaceInstalled: fs.existsSync(workspaceManifestPath),
    workspaceVersion: readInstalledVersion(workspaceManifestPath),
    startHerePresent: fs.existsSync(startHerePath),
    phasesPresent: fs.existsSync(path.join(frameworkPath, "phases")),
    rootGitignorePresent: fs.existsSync(rootGitignore),
    codexSkillPath: skillPath,
    codexSkillInstalled: fs.existsSync(skillManifestPath),
    codexSkillVersion: readInstalledVersion(skillManifestPath),
    codexClientDetected: detectCodexAvailability(options.skillsRoot),
  };

  if (options.json) {
    console.log(JSON.stringify(result, null, 2));
    return;
  }

  logStep("");
  logStep("The Living Project doctor", "green");
  logStep("");
  console.log(`Workspace path: ${result.workspacePath}`);
  console.log(`Workspace installed: ${formatCheck(result.workspaceInstalled, result.workspaceVersion)}`);
  console.log(`START-HERE.md present: ${formatCheck(result.startHerePresent)}`);
  console.log(`Phase docs present: ${formatCheck(result.phasesPresent)}`);
  console.log(`Root .gitignore present: ${formatCheck(result.rootGitignorePresent)}`);
  console.log(`Codex detected: ${formatCheck(result.codexClientDetected)}`);
  console.log(`Codex skill installed: ${formatCheck(result.codexSkillInstalled, result.codexSkillVersion)}`);

  logStep("");
  if (!result.workspaceInstalled) {
    console.log(`Run: living-project init${options.here ? " --here" : ""}`);
  } else if (!result.codexSkillInstalled && result.codexClientDetected) {
    console.log("Run: living-project upgrade --client codex");
  } else {
    console.log("Everything needed for the basic workflow appears to be in place.");
  }
}

function formatCheck(value, version = null) {
  if (value) {
    return colorize(version ? `yes (${version})` : "yes", "green");
  }
  return colorize("no", "red");
}

function main() {
  const { command, options } = parseArgs(process.argv.slice(2));

  if (options.help || command === "help") {
    printHelp();
    return;
  }

  if (!["init", "upgrade", "doctor"].includes(command)) {
    throw new Error(`Unknown command: ${command}`);
  }

  if (!["auto", "codex", "none"].includes(options.client)) {
    throw new Error(`Unsupported client value: ${options.client}`);
  }

  if (command === "doctor") {
    runDoctor(options);
    return;
  }

  runInitLike(command, options);
}

try {
  main();
} catch (error) {
  logError(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
