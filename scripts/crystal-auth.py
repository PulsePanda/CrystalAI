#!/usr/bin/env python3
"""crystal-auth — OAuth sidecar for gws that keeps the client_secret off the student's machine.

Talks to the buildcrystal.ai auth broker. Stores refresh tokens locally at
~/.config/crystal-auth/accounts/<account>/credentials.json (mode 0600).

Commands:
    crystal-auth login <account>        Open browser, authorize, store refresh token
    crystal-auth get-token <account>    Print a fresh access token to stdout
    crystal-auth logout <account>       Remove the local credentials file for <account>
    crystal-auth status                 List all accounts with refresh token status

All commands exit 0 on success, 1 on recoverable user errors (bad arg, missing creds),
2 on unrecoverable errors (auth server down, network failure).

Stdlib only — no pip dependencies. Requires Python 3.9+.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import webbrowser
from pathlib import Path
from typing import Any
from urllib import error, parse, request


DEFAULT_SERVER = "https://auth.buildcrystal.ai"
DEFAULT_SCOPES = [
    "https://www.googleapis.com/auth/gmail.modify",
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/calendar.events",
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/contacts.readonly",
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/userinfo.profile",
    "openid",
]
POLL_INTERVAL_SECONDS = 2
POLL_TIMEOUT_SECONDS = 300
REFRESH_LEEWAY_SECONDS = 60


def _config_root() -> Path:
    return Path(os.environ.get("CRYSTAL_AUTH_HOME", Path.home() / ".config" / "crystal-auth"))


def _credentials_path(account: str) -> Path:
    return _config_root() / "accounts" / account / "credentials.json"


def _server_url() -> str:
    return os.environ.get("CRYSTAL_AUTH_SERVER", DEFAULT_SERVER).rstrip("/")


def _load_credentials(account: str) -> dict[str, Any] | None:
    path = _credentials_path(account)
    if not path.exists():
        return None
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        print(f"crystal-auth: failed to read {path}: {e}", file=sys.stderr)
        return None


def _save_credentials(account: str, data: dict[str, Any]) -> None:
    path = _credentials_path(account)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2))
    os.chmod(path, 0o600)


def _http_post(url: str, body: dict[str, Any], timeout: float = 20.0) -> tuple[int, dict[str, Any]]:
    data = json.dumps(body).encode("utf-8")
    req = request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json", "Accept": "application/json"},
        method="POST",
    )
    try:
        with request.urlopen(req, timeout=timeout) as resp:
            return resp.status, json.loads(resp.read().decode("utf-8"))
    except error.HTTPError as e:
        try:
            payload = json.loads(e.read().decode("utf-8"))
        except (ValueError, OSError):
            payload = {"error": "http_error", "message": str(e)}
        return e.code, payload
    except error.URLError as e:
        raise RuntimeError(f"network error: {e.reason}") from e


def _http_get(url: str, timeout: float = 20.0) -> tuple[int, dict[str, Any]]:
    req = request.Request(url, headers={"Accept": "application/json"}, method="GET")
    try:
        with request.urlopen(req, timeout=timeout) as resp:
            return resp.status, json.loads(resp.read().decode("utf-8"))
    except error.HTTPError as e:
        try:
            payload = json.loads(e.read().decode("utf-8"))
        except (ValueError, OSError):
            payload = {"error": "http_error", "message": str(e)}
        return e.code, payload
    except error.URLError as e:
        raise RuntimeError(f"network error: {e.reason}") from e


def cmd_login(args: argparse.Namespace) -> int:
    server = _server_url()

    print(f"crystal-auth: starting login for '{args.account}' via {server}", file=sys.stderr)

    try:
        status, payload = _http_post(
            f"{server}/auth/start",
            {"scopes": DEFAULT_SCOPES},
        )
    except RuntimeError as e:
        print(f"crystal-auth: cannot reach auth server ({e})", file=sys.stderr)
        return 2

    if status != 200 or "session_id" not in payload:
        print(f"crystal-auth: auth server returned error: {payload}", file=sys.stderr)
        return 2

    session_id = payload["session_id"]
    auth_url = payload["auth_url"]

    print("crystal-auth: opening your browser to authorize...", file=sys.stderr)
    print(f"crystal-auth: if the browser doesn't open, visit this URL manually:", file=sys.stderr)
    print(auth_url, file=sys.stderr)
    print("", file=sys.stderr)

    try:
        webbrowser.open(auth_url, new=2)
    except webbrowser.Error:
        pass

    print("crystal-auth: waiting for authorization...", file=sys.stderr)
    start_time = time.time()
    while time.time() - start_time < POLL_TIMEOUT_SECONDS:
        time.sleep(POLL_INTERVAL_SECONDS)
        try:
            status, poll = _http_get(f"{server}/auth/status/{session_id}")
        except RuntimeError as e:
            print(f"crystal-auth: network error while polling: {e}", file=sys.stderr)
            return 2

        if status == 404 or poll.get("status") == "expired":
            print("crystal-auth: session expired before authorization completed", file=sys.stderr)
            return 2

        if poll.get("status") == "failed":
            err = poll.get("error", "unknown")
            print(f"crystal-auth: authorization failed: {err}", file=sys.stderr)
            return 2

        if poll.get("status") == "complete":
            creds = {
                "refresh_token": poll["refresh_token"],
                "access_token": poll["access_token"],
                "expires_at": poll["expires_at"],
                "scopes": poll["scopes"],
                "account": args.account,
            }
            _save_credentials(args.account, creds)
            print(f"crystal-auth: logged in as '{args.account}'.", file=sys.stderr)
            return 0

    print("crystal-auth: timed out waiting for authorization", file=sys.stderr)
    return 2


def cmd_get_token(args: argparse.Namespace) -> int:
    creds = _load_credentials(args.account)
    if creds is None:
        print(
            f"crystal-auth: no credentials for '{args.account}'. Run: crystal-auth login {args.account}",
            file=sys.stderr,
        )
        return 1

    now = int(time.time())
    cached_expires = creds.get("expires_at", 0)
    if creds.get("access_token") and cached_expires > now + REFRESH_LEEWAY_SECONDS:
        print(creds["access_token"])
        return 0

    server = _server_url()
    try:
        status, payload = _http_post(
            f"{server}/auth/refresh",
            {"refresh_token": creds["refresh_token"]},
        )
    except RuntimeError as e:
        print(f"crystal-auth: network error refreshing token: {e}", file=sys.stderr)
        return 2

    if status == 401 and payload.get("error") == "invalid_grant":
        print(
            f"crystal-auth: refresh token for '{args.account}' has been revoked or expired.\n"
            f"              Run: crystal-auth login {args.account}",
            file=sys.stderr,
        )
        return 1

    if status != 200 or "access_token" not in payload:
        msg = payload.get("message") or payload.get("error") or str(payload)
        print(f"crystal-auth: refresh failed ({status}): {msg}", file=sys.stderr)
        return 2

    creds["access_token"] = payload["access_token"]
    creds["expires_at"] = payload["expires_at"]
    _save_credentials(args.account, creds)
    print(payload["access_token"])
    return 0


def cmd_logout(args: argparse.Namespace) -> int:
    path = _credentials_path(args.account)
    if not path.exists():
        print(f"crystal-auth: no credentials to remove for '{args.account}'", file=sys.stderr)
        return 0
    path.unlink()
    print(f"crystal-auth: removed credentials for '{args.account}'", file=sys.stderr)
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    accounts_dir = _config_root() / "accounts"
    if not accounts_dir.exists():
        print("crystal-auth: no accounts configured")
        return 0

    now = int(time.time())
    found = False
    for account_dir in sorted(accounts_dir.iterdir()):
        if not account_dir.is_dir():
            continue
        creds = _load_credentials(account_dir.name)
        if creds is None:
            continue
        found = True
        expires_at = creds.get("expires_at", 0)
        if expires_at > now:
            delta = expires_at - now
            state = f"access token valid for {delta // 60}m{delta % 60}s"
        else:
            state = "access token expired (will refresh on next use)"
        scope_count = len(creds.get("scopes", []))
        print(f"{account_dir.name}: {state}, {scope_count} scopes, refresh_token present")

    if not found:
        print("crystal-auth: no accounts configured")

    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="crystal-auth",
        description="OAuth sidecar for gws — brokers Google OAuth through auth.buildcrystal.ai",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    login_parser = subparsers.add_parser("login", help="Authorize a Google account")
    login_parser.add_argument("account", help="Account label (e.g. personal, umb)")
    login_parser.set_defaults(func=cmd_login)

    gettoken_parser = subparsers.add_parser("get-token", help="Print a fresh access token")
    gettoken_parser.add_argument("account", help="Account label")
    gettoken_parser.set_defaults(func=cmd_get_token)

    logout_parser = subparsers.add_parser("logout", help="Remove local credentials for an account")
    logout_parser.add_argument("account", help="Account label")
    logout_parser.set_defaults(func=cmd_logout)

    status_parser = subparsers.add_parser("status", help="List configured accounts")
    status_parser.set_defaults(func=cmd_status)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
