# RTZ-GPX-Converter

A proposed offline macOS Apple Silicon utility for converting maritime RTZ route plans into GPX 1.1 routes for personal weather assessment in Windy. It is not an ECDIS replacement or an approved navigation system.

## Project status

**Planning only.** The repository currently contains governance and planning documents; there is no application code, conversion script, GUI, Finder action, package, or test suite.

Read [the master plan](docs/RTZ-GPX-PLAN.md), then [REPORT.md](REPORT.md) and [PROGRESS.md](PROGRESS.md). The master plan is awaiting review and approval.

## Safety and privacy

Route files and vessel positions can be sensitive. Real routes and their derived GPX files must remain outside Git unless the user explicitly authorizes their inclusion. The planned converter must work offline, preserve source RTZ files, and make no automatic navigational decisions.

## Governance

Follow [AGENTS.md](AGENTS.md). The sequence is: approve the master plan; prepare detailed plans for each stage; cross-check the complete plan set and resolve findings; obtain explicit authorization; then implement one stage at a time.
