#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const packageRoot = path.resolve(__dirname, "..");

const manifestPath = path.join(packageRoot, "package-manifest.json");
const releaseConfigPath = path.join(packageRoot, "release.config.json");
const readmeTemplatePath = path.join(packageRoot, "templates", "README.template.md");
const oneLineTemplatePath = path.join(packageRoot, "templates", "ONE-LINE-INSTALL.template.txt");

const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
const releaseConfig = JSON.parse(fs.readFileSync(releaseConfigPath, "utf8"));

assertConfig(releaseConfig);

const packageJson = {
  name: releaseConfig.packageName,
  version: manifest.version,
  description: releaseConfig.packageDescription,
  type: "module",
  bin: {
    "living-project": "./bin/living-project.js",
  },
  files: [
    "bin",
    "payload",
    "CHEAT-SHEET.md",
    "package-manifest.json",
    "README.md",
    "install.cmd",
    "install.ps1",
    "ONE-LINE-INSTALL.txt",
    ".npmignore",
  ],
  engines: {
    node: ">=18",
  },
  keywords: [
    "living-project",
    "ai-workflow",
    "framework",
    "installer",
    "mcp",
    "cli",
  ],
  license: releaseConfig.license,
  author: releaseConfig.author,
  repository: releaseConfig.repositoryUrl,
  homepage: releaseConfig.homepageUrl,
  bugs: releaseConfig.bugsUrl,
  publishConfig: {
    access: releaseConfig.npmAccess,
  },
  scripts: {
    start: "node ./bin/living-project.js",
    doctor: "node ./bin/living-project.js doctor",
    "release:prepare": "node ./scripts/prepare-release.mjs",
    "release:pack": "npm pack",
  },
};

writeFile(
  path.join(packageRoot, "package.json"),
  `${JSON.stringify(packageJson, null, 2)}\n`,
);

renderTemplate(readmeTemplatePath, path.join(packageRoot, "README.md"), {
  PACKAGE_NAME: releaseConfig.packageName,
});

renderTemplate(oneLineTemplatePath, path.join(packageRoot, "ONE-LINE-INSTALL.txt"), {
  PACKAGE_NAME: releaseConfig.packageName,
});

console.log(`Prepared release assets for ${releaseConfig.packageName} v${manifest.version}`);

function renderTemplate(templatePath, outputPath, replacements) {
  let content = fs.readFileSync(templatePath, "utf8");
  for (const [key, value] of Object.entries(replacements)) {
    content = content.replaceAll(`__${key}__`, value);
  }
  writeFile(outputPath, content);
}

function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content, "utf8");
}

function assertConfig(config) {
  const required = [
    "packageName",
    "packageDescription",
    "npmAccess",
    "author",
    "license",
    "repositoryUrl",
    "bugsUrl",
    "homepageUrl",
  ];

  for (const field of required) {
    if (!config[field] || typeof config[field] !== "string") {
      throw new Error(`release.config.json is missing a valid "${field}" value.`);
    }
  }
}
