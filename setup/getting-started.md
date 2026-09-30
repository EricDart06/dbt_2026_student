# Getting Started

Work through this top to bottom. Each part ends with a check, so you know it worked
before you move on. If you get stuck, write down **which step** and **the exact error
message**, then bring it to class or paste it into a chatbot.

| Part | What you'll do | Time |
|---|---|---|
| [1](#part-1--install-the-tools) | Install VS Code, Git, and uv | 20 min |
| [2](#part-2--make-your-snowflake-key) | Make your Snowflake key | 10 min |
| [3](#part-3--sign-up-for-snowflake) | Sign up and log in to Snowflake | 10 min |
| [4](#part-4--get-the-project) | Get the project and install dbt | 10 min |
| [5](#part-5--fill-in-your-profilesyml) | Fill in your `profiles.yml` | 10 min |
| [6](#part-6--test-your-connection) | Test your connection | 5 min |
| [7](#part-7--sql-practice-homework) | SQL practice (homework) | ongoing |

---

## Part 1 — Install the tools

### 1a. VS Code
Download and install: <https://code.visualstudio.com/download>

### 1b. Git
Download and install: <https://git-scm.com/downloads>
- **Windows:** the default options are fine.
- **Mac:** open **Terminal** and run `git --version`. If Git isn't installed, your Mac
  will offer to install it for you.

### 1c. Connect Git to GitHub
1. Make a GitHub account if you don't have one: <https://github.com/signup>
2. Tell Git who you are. In a terminal (VS Code: **Terminal → New Terminal**):
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@byui.edu"
   ```
3. In VS Code, click the **Accounts** icon (bottom-left person icon) and choose
   **Sign in with GitHub** ([guide](https://code.visualstudio.com/docs/sourcecontrol/github)).

### 1d. uv (installs Python and dbt for you)
uv is one tool that installs the right Python version and every package this project
needs. Full instructions: <https://docs.astral.sh/uv/getting-started/installation/>

**Windows** (PowerShell):
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Mac** (Terminal):
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Close and reopen your terminal**, then check that it worked:
```bash
uv --version
```

### 1e. dbt VS Code extension
Install the official dbt extension:
<https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt>. Make a free dbt
account when it prompts you.

It adds a **Preview** button above each CTE in a dbt model, which we use from session 2
on. If the buttons don't show up once the project is open, press **Ctrl/Cmd + Shift + P**
and run **Developer: Reload Window**.

✅ **Check:** `git --version` and `uv --version` both print a version number.

---

## Part 2 — Make your Snowflake key

Instead of a password, dbt logs in to Snowflake with a **key pair**:
- a **private key**, which stays on your computer. Never share it or commit it.
- a **public key**, which you give to the instructor so Snowflake recognizes you.

> Snowflake needs an **RSA** key in a specific format, so use the exact commands below.
> A plain `ssh-keygen` makes the wrong kind of key.

### 2a. Generate the key

**Windows** (PowerShell):
```powershell
New-Item -ItemType Directory -Force "$HOME\.ssh"
ssh-keygen -t rsa -b 2048 -m PKCS8 -f "$HOME\.ssh\snowflake_key"
```

**Mac** (Terminal):
```bash
mkdir -p ~/.ssh
ssh-keygen -t rsa -b 2048 -m PKCS8 -f ~/.ssh/snowflake_key
```

When it asks for a passphrase, **press Enter twice** to leave it empty.

This creates two files in your `.ssh` folder:

| File | What it is |
|---|---|
| `snowflake_key` | **private** key. Stays on your computer. dbt uses it. |
| `snowflake_key.pub` | public key |

### 2b. Print your public key in Snowflake's format

**Windows:**
```powershell
ssh-keygen -e -m PKCS8 -f "$HOME\.ssh\snowflake_key.pub"
```

**Mac:**
```bash
ssh-keygen -e -m PKCS8 -f ~/.ssh/snowflake_key.pub
```

It prints a block like this. Copy **all** of it, including the BEGIN and END lines:
```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAll3bXsdFW/OL/Qmh0jIf
...
-----END PUBLIC KEY-----
```

### 2c. Find your key file (remember how to do this!)

**You'll need the full path to `snowflake_key` in Part 5.** Here's how to find it:

**Windows:**
1. Open **File Explorer**.
2. Click the address bar, type `%USERPROFILE%\.ssh`, and press Enter.
3. You'll see `snowflake_key` and `snowflake_key.pub`.
4. Your path is `C:\Users\<your-windows-username>\.ssh\snowflake_key`.

**Mac:**
1. Open **Finder**.
2. Press **Cmd + Shift + G** (Go to Folder), type `~/.ssh`, and press Enter.
3. `.ssh` is a hidden folder. If you ever browse to your home folder
   (**Cmd + Shift + H**) and can't see it, press **Cmd + Shift + .** (period) to show
   hidden files.
4. Your path is `/Users/<your-mac-username>/.ssh/snowflake_key`.

Either way, you end up in the same place: a `.ssh` folder in your home folder that
holds `snowflake_key`.

✅ **Check:** you can see both key files, and you've written down the full path to `snowflake_key`.

---

## Part 3 — Sign up for Snowflake

1. Fill in the sign-up sheet with your **first name, last name, school email, and public
   key** (the whole block from step 2b):
   <https://webmailbyui-my.sharepoint.com/:x:/g/personal/chazclar_byui_edu/IQBtNtDOQHPRSbpjQPQRiFBIAZMBpJ_56uE69Xjzx4lT4wk?e=8kefPm>
2. On the sheet, **pick an open animal username**. That animal is your Snowflake
   username. Write it down; you'll need it in Part 5.
3. **Wait** until Brother Clark runs his setup script.
4. Go to <https://vxzjsrc-ag60135.snowflakecomputing.com/>
5. Log in with your **animal username** and the **temporary password** from the
   sign-up sheet.
6. When it asks about MFA, **choose the passkey option**. Don't set up an authenticator app.

✅ **Check:** you can log in to Snowflake in your browser.

---

## Part 4 — Get the project

1. Fork the student repo on GitHub (link coming soon), then clone your fork in VS Code:
   **Ctrl/Cmd + Shift + P → Git: Clone**.
2. Open a terminal in the project folder and install everything:
   ```bash
   uv sync
   ```
   This installs Python, dbt, and the Snowflake connector into a `.venv`
   folder inside the project. The first run takes a minute or two.
3. Confirm dbt is installed:
   ```bash
   uv run dbt --version
   ```

> **Always use `uv run dbt ...`**, not plain `dbt`. That runs the dbt this project
> installed, not some other copy on your computer.

<details>
<summary>uv won't install? Fallback with pip</summary>

Only use this if uv doesn't work. You'll need Python 3.12 or 3.13 from
<https://www.python.org/downloads/> first.

```bash
# Mac / Linux
pip install dbt-core dbt-snowflake
# If that fails on Mac, try:
pip3 install dbt-core dbt-snowflake

# Windows
python -m pip install dbt-core dbt-snowflake
```

With pip, drop the `uv run` part: type `dbt debug` instead of `uv run dbt debug`.
</details>

✅ **Check:** `uv run dbt --version` lists `snowflake` under Plugins.

---

## Part 5 — Fill in your `profiles.yml`

`profiles.yml` tells dbt **how to connect to Snowflake as you**. It lives in a `.dbt`
folder in your home folder, **not** in the project, so your personal details never get
committed to GitHub.

1. Create the folder and file:
   - **Windows:** `C:\Users\<you>\.dbt\profiles.yml`
   - **Mac:** `/Users/<you>/.dbt/profiles.yml` (use Cmd + Shift + G → `~/.dbt`,
     same as in Part 2c)
2. Copy the contents of [`profiles.example.yml`](profiles.example.yml) into it.
3. Change **only these three lines**:

| Setting | What to put | Example |
|---|---|---|
| `user` | your animal username from Part 3 | `OTTER` |
| `private_key_path` | full path to your private key from Part 2c | `C:/Users/jsmith/.ssh/snowflake_key` |
| `schema` | `lastname_firstname`, lowercase | `smith_john` |

Everything else (account, role, warehouse, database) is the same for everyone. Leave
it as provided.

```yaml
olist:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: VXZJSRC-AG60135

      user: OTTER                                   # <-- yours
      private_key_path: C:/Users/jsmith/.ssh/snowflake_key   # <-- yours
      schema: smith_john                            # <-- yours

      role: STUDENT
      warehouse: STUDENT_WH
      database: DBT_LABS_DB

      threads: 4
```

**Common mistakes:**
- **Windows paths:** use forward slashes (`C:/Users/...`) or it may not parse.
  Don't use Git-Bash-style paths like `/c/Users/...`.
- **Point at the private key** (`snowflake_key`), not `snowflake_key.pub`.
- **Indentation matters** in YAML. Use spaces, not tabs, and keep the lines lined up
  exactly as shown.

**Why `schema` is your name:** everyone shares the same database and schemas, so dbt
puts your name on the front of every table you build (`STAGING.SMITH_JOHN__STG_SELLERS`,
`MODELED.SMITH_JOHN__DIM_SELLERS`, ...). That way nobody overwrites anyone else's work.
Use exactly `lastname_firstname`, lowercase, and make sure nobody else in class has the
same one.

---

## Part 6 — Test your connection

From the project's `dbt` folder:

```bash
cd dbt
uv run dbt debug
```

You're set up when **every line says OK** and it ends with:

```
All checks passed!
```

If it fails, the last few lines tell you why:

| Error says | Fix |
|---|---|
| `profiles.yml file [ERROR not found]` | The file is in the wrong place or misnamed. Check Part 5, step 1. |
| `Could not find profile named 'olist'` | The first line of `profiles.yml` must be exactly `olist:` |
| `No such file or directory: '...snowflake_key'` | `private_key_path` is wrong. Redo Part 2c. |
| `JWT token is invalid` / authentication failed | Your public key isn't registered yet, or doesn't match. Tell Brother Clark. |
| `Incorrect username or password` | Check `user` is your animal username. |

---

## Part 7 — SQL practice (homework)

1. **Join the class DataCamp group** (free access):
   <https://www.datacamp.com/groups/shared_links/95e4f07f7af720aba23dbded5a2dba284eecbf3cd1853aeb5b76a5eedb5dde9f>
2. **Take Introduction to SQL:**
   <https://app.datacamp.com/learn/courses/introduction-to-sql>
3. **Practice with a chatbot.** Paste in each query you write and ask it to explain the
   query line by line. Ask it to quiz you on `WHERE` vs. `HAVING`.

By session 2 you should be comfortable with `SELECT`, `WHERE`, and `GROUP BY`. We'll
practice them together in class and build up to CTEs; joins come in session 4.
