# Google Workspace Auth (crystal-auth)

CrystalAI connects to Gmail, Calendar, Drive, and other Google Workspace APIs through the `gws` CLI tool, which is authenticated via a small sidecar called `crystal-auth`. This doc explains what's happening, how to connect a Google account, and what to do when something goes wrong.

## How it works

You never touch a Google Cloud Console, never create an OAuth client, never download a `credentials.json`. Here's what actually happens when you run `crystal-auth login`:

1. `crystal-auth` on your machine contacts `auth.buildcrystal.ai` — an auth broker server run by the CrystalAI team.
2. The broker generates a session ID and gives you back a Google sign-in URL.
3. Your browser opens to Google. You sign in to the account you want to connect and click Allow on the consent screen.
4. Google redirects back to the broker, which exchanges the authorization code for a pair of tokens (a long-lived `refresh_token` and a short-lived `access_token`) using the real OAuth client secret, which never leaves the broker.
5. The broker hands those tokens back to your local `crystal-auth`, which saves them to `~/.config/crystal-auth/accounts/<label>/credentials.json` (mode 0600).
6. Every subsequent `gws` command — through the `gws-unix.sh` or `gws-windows.bat` wrapper — calls `crystal-auth get-token <label>` first, which returns a fresh access token, and then runs `gws` with the `GOOGLE_WORKSPACE_CLI_TOKEN` environment variable set. `gws` uses that token directly and skips its own credential loading entirely.

The important property: the real OAuth client_secret exists in exactly one place — the broker VM — and never gets copied to any student's machine. Your machine only ever holds a refresh token scoped to your specific Google account, which has the same security profile as an SSH key.

## Connecting an account

To connect a Google account (first time, or to add another account):

```bash
python3 ~/.claude/scripts/crystal-auth.py login <label>
```

On Windows, use `python` instead of `python3` and `%USERPROFILE%\.claude\scripts\crystal-auth.py` for the path.

`<label>` is a short name you pick for the account. Use something short and lowercase: `personal`, `work`, `school`. If you have multiple Google accounts you want to connect (personal Gmail plus a work Google Workspace account, for example), run this once per account with a different label.

The flow:
1. Your browser opens to `accounts.google.com`.
2. Sign in with the account you want to connect.
3. You see a consent screen listing the scopes CrystalAI needs (Gmail, Calendar, Drive, Contacts, profile info). Click **Allow**.
4. You'll see an **"This app isn't verified"** warning screen. This is expected — click **Advanced**, then **"Go to crystalos (unsafe)"**. Google shows this warning for any app that hasn't been through their formal verification process, which isn't economical at pilot scale. "Unsafe" is just their default wording; nothing is actually unsafe.
5. Click Allow on the real consent screen.
6. Browser shows "Authorization successful. You can close this tab and return to your terminal."
7. Close the tab. The terminal prints "logged in as '<label>'."

## Using a connected account

Once connected, any `gws` command through the wrappers uses your connected account. Usage:

```bash
# macOS / Linux
~/.claude/scripts/gws-unix.sh <label> gmail users getProfile --params '{"userId":"me"}'

# Windows
%USERPROFILE%\.claude\scripts\gws-windows.bat <label> gmail users getProfile --params "{\"userId\":\"me\"}"
```

Most CrystalAI skills that touch Gmail or Calendar already use these wrappers — you don't need to know the wrapper syntax unless you're writing your own skill.

## Checking status

See what accounts you have connected:

```bash
python3 ~/.claude/scripts/crystal-auth.py status
```

Output looks like:

```
personal: access token valid for 54m12s, 9 scopes, refresh_token present
work: access token expired (will refresh on next use), 9 scopes, refresh_token present
```

Expired access tokens are fine — `crystal-auth get-token` automatically refreshes them on the next call.

## Disconnecting an account

```bash
python3 ~/.claude/scripts/crystal-auth.py logout <label>
```

This removes the local credentials file. It does not revoke access on Google's side — if you want to fully revoke, also go to [myaccount.google.com/permissions](https://myaccount.google.com/permissions) and remove "crystalos" from the list of connected apps.

## Troubleshooting

**"no credentials for 'xxx'. Run: crystal-auth login xxx"**
You haven't logged in for this account yet, or `crystal-auth logout` was run. Run the login command.

**"refresh token for 'xxx' has been revoked or expired. Run: crystal-auth login xxx"**
Google has invalidated your refresh token. Common causes: you changed your Google account password, you manually removed "crystalos" from your Google permissions, or six months have passed without any skill using this account. Just re-run login — it's a 30-second fix.

**"cannot reach auth server" / "network error"**
`auth.buildcrystal.ai` is unreachable. Check your internet connection. If that's fine, the auth server itself may be down — contact your instructor. Existing access tokens keep working for about an hour after they were issued, so commands may continue to succeed briefly even when refresh is failing.

**"This app isn't verified" warning is too scary / I can't get past it**
This is Google's standard screen for any OAuth app they haven't formally verified. Click "Advanced" in the lower-left of the warning, then click the text that says "Go to crystalos (unsafe)". Despite the wording, nothing is actually unsafe — the app just hasn't paid for Google's verification audit yet.

**gws commands return 401 Unauthorized**
Your access token expired and refresh is failing. Run `crystal-auth get-token <label>` manually — it will either return a fresh token (in which case try your command again) or print an error explaining why refresh is failing.

**gws commands return 403 insufficient_scope**
The scope needed for this API wasn't granted at login time. Run `crystal-auth logout <label>` and then `crystal-auth login <label>` to get fresh consent with the full default scope set. (If this keeps happening for the same API, the scope may not be in the default set — ask your instructor.)

## For the curious: architecture details

The full architecture of the auth broker system — why it's built this way, why `gws` isn't forked, why the client_secret lives where it does, how failure modes are handled — is documented in the consulting project at `crystal-consulting/_meta/deliverables/gws-auth-architecture.md`. The short version: `gws` has a `GOOGLE_WORKSPACE_CLI_TOKEN` environment variable that bypasses its own auth entirely and uses a supplied access token directly. We exploit that to run auth through our broker without modifying `gws` at all.

The broker itself is a small FastAPI app running on a dedicated Linode VM under systemd with strict hardening flags. Source lives at `Projects/buildcrystal-auth/` (not part of CrystalAI — separate infrastructure repo).
