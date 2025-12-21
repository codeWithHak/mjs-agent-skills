---
name: browsing-with-playwright
description: |
  Automates browser interactions via Playwright MCP server.
  Use when tasks require web browsing, form submission, web scraping,
  UI testing, screenshot capture, or any browser interaction.
  NOT when only fetching static content (use curl/wget instead).
---

## Quick Start

```bash
# Start server
bash scripts/start-server.sh

# Navigate and interact
python3 scripts/mcp-client.py call -u http://localhost:8808 -t browser_navigate \
  -p '{"url": "https://example.com"}'
```

## Instructions

1. Start Playwright MCP server:
   ```bash
   bash scripts/start-server.sh
   ```

2. Navigate to target URL:
   ```bash
   python3 scripts/mcp-client.py call -u http://localhost:8808 -t browser_navigate \
     -p '{"url": "https://example.com"}'
   ```

3. Get element refs via snapshot:
   ```bash
   python3 scripts/mcp-client.py call -u http://localhost:8808 -t browser_snapshot -p '{}'
   ```

4. Interact using refs from snapshot:
   ```bash
   # Click
   python3 scripts/mcp-client.py call -u http://localhost:8808 -t browser_click \
     -p '{"element": "Submit", "ref": "e42"}'

   # Type
   python3 scripts/mcp-client.py call -u http://localhost:8808 -t browser_type \
     -p '{"element": "Search", "ref": "e15", "text": "query", "submit": true}'
   ```

5. Run verification: `python3 scripts/verify.py`

6. Stop server when done:
   ```bash
   bash scripts/stop-server.sh
   ```

## If Verification Fails

1. Run diagnostic: `pgrep -f "@playwright/mcp"`
2. Check: Server process running on port 8808
3. **Stop and report** - do not proceed with downstream steps

## References

See [references/playwright-tools.md](references/playwright-tools.md) for complete tool documentation.
