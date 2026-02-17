<p align="center">
  <img src="https://raw.githubusercontent.com/dolutech/nfguard-cli/main/assets/logo_nfguard.png" alt="NFGuard Logo" width="420">
</p>

<h1 align="center">NFGuard — AI-Powered Security CLI</h1>

<p align="center">
  Multi-agent orchestration with 34+ integrated security tools.<br>
  Reconnaissance, vulnerability scanning, web testing, and automated reporting — all from your terminal.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.1.0-cyan?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/platform-Linux%20x86__64%20%7C%20WSL-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/release-February%202026-yellow?style=flat-square" alt="Release">
</p>

---

## What is NFGuard?

NFGuard is a security CLI that uses a **multi-agent AI architecture** to orchestrate 34+ security tools. You describe what you need in natural language, and the AI orchestrator delegates tasks to specialized agents — each with access to the right tools for the job.

All tools are **bundled as pre-compiled binaries** — no manual installation of individual tools required.

<p align="center">
  <img src="https://raw.githubusercontent.com/dolutech/nfguard-cli/main/assets/nfguard-cli-print.png" alt="NFGuard CLI Demo" width="600">
</p>

---

## Features

- **Multi-Agent Orchestration** — An orchestrator AI delegates to 4 specialist agents (Recon, Web Testing, Vuln Scanning, Reporting), each with its own tools and system prompt
- **34+ Bundled Security Tools** — From subdomain enumeration to vulnerability scanning to web fuzzing, all pre-compiled and ready to use
- **Interactive REPL** — Rich terminal UI with tab completion, slash commands, conversation history, and real-time streaming
- **Natural Language Interface** — Just describe what you want; the AI figures out which tools and agents to use
- **Automated Workflows (Skills)** — One-command workflows: `/full-recon`, `/vuln-check`, `/web-audit`
- **Bash Guardrails** — AI can run shell commands with your approval; built-in safety filters block dangerous patterns
- **PDF/DOCX Reporting** — Generate professional security reports directly from scan findings
- **MCP Server & Client** — Expose tools via Model Context Protocol or connect external MCP tool servers
- **Session Memory & Context Compaction** — The AI remembers findings across the session and auto-summarizes long conversations
- **Custom Skills & Agents** — Create reusable workflows or specialist agents on the fly
- **Any LLM Provider** — Works with any OpenAI-compatible API: local models (Ollama, LM Studio), OpenRouter, OpenAI, and more

---

## Integrated Tools

### Reconnaissance & OSINT
`subfinder` · `amass` · `theharvester` · `shodan` · `uncover` · `alterx` · `asnmap` · `cdncheck` · `subzy` · `whois`

### DNS & Network
`dnsx` · `doggo` · `naabu` · `tlsx` · `mapcidr`

### Web Crawling & URLs
`katana` · `gau` · `waybackurls` · `unfurl` · `anew` · `httpx` · `webfetch`

### Content Discovery & Fuzzing
`gobuster` · `ffuf` · `feroxbuster`

### Vulnerability Scanning
`nuclei` · `dalfox` · `crlfuzz` · `sqlmap` · `arjun` · `interactsh`

### Reporting & Notifications
`reportgen` · `notify`

---

## AI Specialist Agents

| Agent | Focus | Tools |
|-------|-------|-------|
| **ReconAgent** | Reconnaissance, DNS, OSINT gathering | 18 tools |
| **WebTestingAgent** | Web app security (SQLi, XSS, fuzzing) | 12 tools |
| **VulnScanningAgent** | CVE scanning, severity prioritization | 3 tools |
| **ReportingAgent** | PDF/DOCX report generation | 1 tool |

---

## Platform Compatibility

| Platform | Supported |
|----------|-----------|
| Linux x86_64 (amd64) | Yes |
| WSL (Windows Subsystem for Linux) | Yes |
| macOS | Planned for future release |
| Linux ARM64 (aarch64) | Planned for future release |

---

## Quick Install

One command — download, install, and you're ready:

```bash
curl -sL https://github.com/dolutech/nfguard-cli/releases/download/v0.1.0/nfguard-0.1.0-linux-amd64.tar.gz -o /tmp/nfguard.tar.gz && curl -sL https://raw.githubusercontent.com/dolutech/nfguard-cli/main/install.sh -o /tmp/install.sh && sudo bash /tmp/install.sh
```

Then configure your LLM provider and launch:

```bash
nano ~/.nfguard/providers.yaml
nfguard
```

### What the installer does

- Downloads and extracts NFGuard to `/opt/nfguard/`
- Creates a symlink at `/usr/local/bin/nfguard` (available system-wide)
- Creates config templates at `~/.nfguard/` with secure permissions

### Manual Installation

If you prefer to install manually:

```bash
# Download
curl -sL https://github.com/dolutech/nfguard-cli/releases/download/v0.1.0/nfguard-0.1.0-linux-amd64.tar.gz -o nfguard.tar.gz
curl -sL https://raw.githubusercontent.com/dolutech/nfguard-cli/main/install.sh -o install.sh

# Install
chmod +x install.sh
sudo bash install.sh

# Configure and launch
nano ~/.nfguard/providers.yaml
nfguard
```

---

## Configuration

NFGuard works with **any OpenAI-compatible API endpoint**.

### Local LLM (Recommended)

We strongly recommend using a local LLM for maximum privacy — your security data never leaves your machine.

**Recommended models:** GPT-OSS 120B, Minimax M2.5, Qwen 3.5 397B-A17B, GLM-4.7-Flash

**Ollama:**
```yaml
# ~/.nfguard/providers.yaml
providers:
  ollama:
    base_url: http://localhost:11434/v1
    api_key: ollama
    default_model: gpt-oss-120b
```

**LM Studio:**
```yaml
providers:
  lmstudio:
    base_url: http://localhost:1234/v1
    api_key: lm-studio
    default_model: your-loaded-model
```

### Cloud Providers

Any OpenAI-compatible provider works.

**Chutes.ai (Recommended)** — Large catalog of open-weight models, decentralized infrastructure, competitive pricing:

```yaml
providers:
  chutes:
    base_url: https://llm.chutes.ai/v1
    api_key: your-chutes-api-key
    default_model: openai/gpt-oss-120b-TEE
```

Browse models at [chutes.ai](https://chutes.ai/) and use the model ID in your config.

> **Note:** Our recommendation of Chutes.ai is **not sponsored**. We recommend it based on its open-weight model catalog, decentralized architecture, and cost-effectiveness. You are free to use any OpenAI-compatible provider.

**OpenRouter, Anthropic, OpenAI, and others** also work:

```yaml
# OpenRouter
providers:
  openrouter:
    base_url: https://openrouter.ai/api/v1
    api_key: sk-or-xxxxxxxxxxxxxxxxxxxx
    default_model: z-ai/glm-5
```

```yaml
# Anthropic
providers:
  anthropic:
    base_url: https://api.anthropic.com/v1
    api_key: sk-ant-xxxxxxxxxxxxxxxxxxxxxxxx
    default_model: claude-sonnet-4-5-20250929
```

```yaml
# OpenAI
providers:
  openai:
    base_url: https://api.openai.com/v1
    api_key: sk-xxxxxxxxxxxxxxxxxxxxxxxx
    default_model: gpt-5.2
```

> **Important: Model Guardrails**
> Some proprietary models (e.g., GPT, Claude, Gemini) have built-in safety guardrails that may refuse to execute certain security testing tasks — even when you have explicit authorization to test the target. For this reason, we strongly recommend using **open-weight models** (GPT-OSS, Qwen, GLM, Minimax, etc.) which provide full control over model behavior. If you need a model perfectly tailored to your security workflow, consider **fine-tuning** an open-weight model for your specific use case.

---

## Usage

### Natural Language

Just describe what you want:

```
nfguard> Find all subdomains of example.com and check for open ports
nfguard> Scan target.com for vulnerabilities
nfguard> Test the login form for SQL injection
nfguard> Generate a PDF report of our findings
```

### Built-in Skills

```
nfguard> /full-recon example.com        # WHOIS + DNS + port scan
nfguard> /vuln-check target.com         # Shodan + Nuclei scan
nfguard> /web-audit https://app.com     # Nuclei + directory enumeration
```

### Slash Commands

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/exit` | Exit NFGuard |
| `/clear` | Clear conversation history |
| `/compact` | Compact context (summarize conversation) |
| `/export [fmt] [file]` | Export session (markdown/json/html) |
| `/providers` | List configured providers |
| `/provider <name>` | Switch active provider |
| `/models` | List available models |
| `/model <name>` | Switch active model |
| `/tools` | List security tools and status |
| `/agents` | List specialist agents |
| `/skills` | List available skills |
| `/mcp` | List MCP server connections |
| `/damage-control on\|off` | Toggle bash guardrails |
| `/create-agents` | Create a custom specialist agent |

### MCP Server Mode

Expose all tools via Model Context Protocol for use with MCP-compatible clients:

```bash
nfguard serve
```

---

## Uninstall

```bash
sudo bash install.sh --uninstall
```

This removes `/opt/nfguard/` and the symlink but preserves your `~/.nfguard/` configuration.

To also remove your config:

```bash
rm -rf ~/.nfguard/
```

---

## Architecture

```
                    ┌──────────────────────┐
                    │   You (Terminal)      │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Interactive REPL     │
                    │  prompt_toolkit+Rich  │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Orchestrator Agent   │
                    │  LLM ↔ tool_calls    │
                    └──┬────┬────┬────┬────┘
                       │    │    │    │
            ┌──────────▼┐ ┌▼────▼┐ ┌▼──────────┐ ┌▼──────────┐
            │ReconAgent │ │Web   │ │VulnScanner │ │Reporting  │
            │18 tools   │ │Test  │ │3 tools     │ │1 tool     │
            └───────────┘ │12    │ └────────────┘ └───────────┘
                          │tools │
                          └──────┘
                               │
                    ┌──────────▼───────────┐
                    │  Security Binaries   │
                    │  nuclei, naabu, ffuf │
                    │  subfinder, sqlmap...│
                    └──────────────────────┘
```

---

## License

This project is licensed under the **MIT License**.

NFGuard is a **community project** — currently distributed as a compiled binary.

---

## Disclaimer

NFGuard is intended for **authorized security testing only**. Always ensure you have explicit permission before testing any system. Unauthorized security testing is illegal in most jurisdictions. Use responsibly.

---

## Contact

- **Email:** [lucas@dolutech.com](mailto:lucas@dolutech.com)
- **Website:** [nfguard.org](https://nfguard.org)

---

<p align="center">
  <sub>Built for the security community.</sub>
</p>
