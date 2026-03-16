---
description: Generate interactive HTML dashboards and visualizations from code or data analysis
context: fork
allowed-tools: Read, Write, Grep, Glob, Bash
model: sonnet
---

# Visualize

Generate interactive HTML reports and dashboards from codebase analysis or data.

## User Input

```text
$ARGUMENTS
```

## Process

1. **Determine Visualization Type** — Based on $ARGUMENTS, decide what to visualize:
   - **Codebase overview**: File tree, module dependencies, language breakdown
   - **Dependency graph**: Package dependencies as an interactive network
   - **Test coverage**: Coverage heatmap by module/file
   - **Git activity**: Commit frequency, contributor heatmap, file churn
   - **Custom data**: Parse CSV/JSON and render charts

2. **Gather Data** — Use Glob, Grep, Read, and Bash to collect the raw data:
   - File counts by extension: `find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn`
   - Package dependencies: Read package.json, requirements.txt, Cargo.toml, go.mod
   - Git stats: `git log --format='%H|%an|%ad|%s' --date=short`
   - Test results: Run test suite with coverage flags
   - LOC: `wc -l` or `cloc` if available

3. **Generate HTML** — Create a self-contained HTML file with:
   - Embedded CSS (no external dependencies)
   - Inline SVG charts OR embedded Chart.js via CDN
   - Responsive layout
   - Dark mode support
   - Interactive tooltips and hover states
   - Print-friendly styles

4. **Write Output** — Save to `./visualization-report.html` (or a name matching the topic)

5. **Open** — Use `open` (macOS) to display in browser

## HTML Template Structure

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>[Report Title]</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
      /* Self-contained styles */
      :root {
        --bg: #0d1117;
        --fg: #c9d1d9;
        --accent: #58a6ff;
      }
      body {
        font-family: -apple-system, system-ui, sans-serif;
        background: var(--bg);
        color: var(--fg);
        margin: 0;
        padding: 2rem;
      }
      .card {
        background: #161b22;
        border: 1px solid #30363d;
        border-radius: 8px;
        padding: 1.5rem;
        margin: 1rem 0;
      }
      .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 1rem;
      }
      h1,
      h2 {
        color: var(--fg);
        border-bottom: 1px solid #30363d;
        padding-bottom: 0.5rem;
      }
      table {
        width: 100%;
        border-collapse: collapse;
      }
      th,
      td {
        padding: 8px 12px;
        text-align: left;
        border-bottom: 1px solid #30363d;
      }
      th {
        color: var(--accent);
      }
      .stat {
        font-size: 2rem;
        font-weight: bold;
        color: var(--accent);
      }
      @media (prefers-color-scheme: light) {
        :root {
          --bg: #fff;
          --fg: #24292f;
          --accent: #0969da;
        }
        .card {
          background: #f6f8fa;
          border-color: #d0d7de;
        }
      }
    </style>
  </head>
  <body>
    <h1>[Title]</h1>
    <p>Generated: [timestamp]</p>
    <div class="grid">
      <!-- Summary cards -->
      <!-- Charts -->
      <!-- Tables -->
    </div>
    <script>
      // Chart.js initialization
    </script>
  </body>
</html>
```

## Visualization Types

### Codebase Overview

- Language breakdown pie/donut chart
- File count by directory (treemap or bar chart)
- LOC summary table
- Top 10 largest files

### Dependency Graph

- Interactive node-link diagram (d3-force or plain SVG)
- Color by: direct vs. dev dependency
- Size by: sub-dependency count
- Highlight outdated packages

### Git Activity

- Commit heatmap (calendar view)
- Contributor bar chart
- File churn ranking (most modified files)
- Branch activity timeline

### Test Coverage

- Module-level heatmap (red/yellow/green)
- Coverage trend over recent commits
- Uncovered file list with line counts

## Quality Standards

- HTML must be fully self-contained (single file, works offline except CDN)
- All charts must have labels, legends, and tooltips
- Responsive down to 375px width
- Generated timestamp on every report
- Data source attribution (what commands/files were used)
