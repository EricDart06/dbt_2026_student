# Session 1 — Setup (semester week 3)

**Goal:** by the end of the hour, everyone has the tools installed, has a Snowflake key,
and is signed up for a Snowflake account.

**You leave with:** VS Code, Git, uv, and the dbt extension installed; a key pair in your
`.ssh` folder; your name and public key on the sign-up sheet.

**Files you write this week:** none.

---

## Before class

Nothing. Bring a laptop you can install software on (not a locked-down lab machine).

---

## The hour

| Min | What we do | Guide |
|---|---|---|
| 0–10 | **What this is.** The raw → staging → modeled → marts picture from the [README](../README.md). The hackathon in week 9 uses the warehouse you build. | — |
| 10–30 | **Install the tools:** VS Code, Git, connect Git to GitHub, uv, the dbt extension. | [getting-started.md](../setup/getting-started.md) Part 1 |
| 30–40 | **Make your Snowflake key** and find it in File Explorer / Finder. Write down the full path. | Part 2 |
| 40–50 | **Sign up:** your name, email, public key, and an animal username on the sign-up sheet. | Part 3 |
| 50–60 | **Get the project:** fork and clone the [student repo](https://github.com/MLMecham/dbt_2026_student), run `uv sync`. | Part 4 |

The Snowflake login itself (Part 3, steps 3–6) only works after the instructor runs the
setup script, so it may have to wait until after class.

---

## Step by step

### 1. Install the tools (Part 1)
Go in order: VS Code → Git → `git config` with your name and email → uv → the dbt
extension. **Close and reopen your terminal after installing uv**, or `uv` won't be found.

✅ `git --version` and `uv --version` both print a version.

### 2. Make your key (Part 2)
Copy the commands exactly: Snowflake needs an RSA key in PKCS8 format. Press Enter twice
at the passphrase prompt. Then run the step 2b command: it converts your public key and
**copies it to your clipboard**, ready to paste into the sign-up sheet.

**Don't open or copy `snowflake_key.pub` yourself.** It starts with `ssh-rsa AAAA...`,
which is the wrong format. What you paste must start with `-----BEGIN PUBLIC KEY-----`.

✅ You can see `snowflake_key` and `snowflake_key.pub` in your `.ssh` folder, and you've
written down the full path to `snowflake_key`.

### 3. Sign up (Part 3)
Paste the **whole** public key block, including the `BEGIN` and `END` lines. Pick an
animal that nobody else has taken; that animal is your Snowflake username.

### 4. Get the project (Part 4)
Open <https://github.com/MLMecham/dbt_2026_student> and click **Fork** (top right). Clone
**your fork**, open the folder in VS Code, and run `uv sync` in the terminal.

✅ `uv run dbt --version` lists `snowflake` under Plugins.

---

## Definition of done

- [ ] `git --version` and `uv --version` work
- [ ] Key files exist, and you know the path to `snowflake_key`
- [ ] You're on the sign-up sheet with your public key and animal username
- [ ] The project is cloned and `uv sync` finished

---

## Stuck?

| Problem | Try |
|---|---|
| `uv` not found after installing | Close **every** terminal and open a new one. On Windows, restart VS Code. |
| `ssh-keygen` not found (Windows) | Run it from Git Bash, or install Git first and reopen PowerShell. |
| Can't see the `.ssh` folder (Mac) | In Finder, **Cmd + Shift + .** shows hidden files. |
| What you pasted starts with `ssh-rsa` | You copied the `.pub` file. Run the step 2b command and paste again. |
| The key has the wrong format | Delete both key files and redo step 2a with the exact command, including `-m PKCS8`. |

---

## Homework before session 2

1. Join the [class DataCamp group](https://www.datacamp.com/groups/shared_links/95e4f07f7af720aba23dbded5a2dba284eecbf3cd1853aeb5b76a5eedb5dde9f)
   and work through [Introduction to SQL](https://app.datacamp.com/learn/courses/introduction-to-sql).
2. Watch the assigned SQL tutorials: `SELECT` → `WHERE` → `GROUP BY` → CTE.
3. When your Snowflake account is ready, finish Parts 5–6 of the setup guide:
   fill in `profiles.yml`, then run `uv run dbt debug` until it says **All checks passed!**
