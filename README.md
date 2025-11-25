# Claude Code Plugin Marketplace (Public)

This repository hosts a **public plugin marketplace** for Claude Code.  
It provides a central location where users can discover and install plugins,  
including your plugin:

**claudecode-pydantic-subagent-factory**

To support installation of plugins from *private or restricted GitHub repositories*,  
this repo includes two credential‑setup scripts:

- `configure-claude-plugin-git-creds.sh` – for Linux/macOS/WSL  
- `Configure-ClaudePlugin-GitCreds.ps1` – for Windows PowerShell 5+

These scripts ensure that Claude Code can clone a specific plugin repository through  
**HTTPS + PAT (Personal Access Token)** without interactive prompts.

---

# 📌 What These Scripts Do

Both scripts perform the following steps:

1. **Configure Git globally** to use:
   - `credential.helper store`
   - `credential.useHttpPath true`

2. **Store a GitHub PAT** in the user’s credential store  
   *BUT scoped only to a single plugin repository path.*

3. **Allow Claude Code to install plugins non‑interactively**,  
   preventing TUI lockups caused by Git credential prompts.

4. **Warn the user** that PATs may expire and they may need to contact  
   **Patrick Miron (GitHub: DragonAngel1st)** for renewal.

---

# 📂 Script Links

| Script | Platform | Description |
|--------|----------|-------------|
| [`configure-claude-plugin-git-creds.sh`](./configure-claude-plugin-git-creds.sh) | Linux / macOS / WSL | Configures repo‑scoped HTTPS + PAT credentials |
| [`Configure-ClaudePlugin-GitCreds.ps1`](./Configure-ClaudePlugin-GitCreds.ps1) | Windows PowerShell 5+ | Same as above, for native Windows |

---

# 🔧 How the Scripts Work

### ✔ HTTPS + PAT for **one GitHub repo only**
The scripts create a line in:

```
~/.git-credentials        (Unix)
%USERPROFILE%\.git-credentials (Windows)
```

Example line:

```
https://YOUR_USERNAME:YOUR_PAT@github.com/DragonAngel1st/ClaudeCodePydanticSubagentFactory_plugin
```

Combined with:

```
git config --global credential.useHttpPath true
```

This ensures **only this specific repo** uses the stored PAT.

All other repos remain unaffected, including:

- SSH‑based repos (`git@github.com:...`)
- Other GitHub HTTPS repos
- GitLab, Bitbucket, self‑hosted Git servers

---

# 🛠 Using the Scripts

## Linux/macOS/WSL

```bash
chmod +x configure-claude-plugin-git-creds.sh
./configure-claude-plugin-git-creds.sh
```

You will be asked for:

- GitHub username
- GitHub PAT (hidden input)

## Windows (PowerShell 5)

```powershell
Set-ExecutionPolicy -Scope Process RemoteSigned
.\Configure-ClaudePlugin-GitCreds.ps1
```

You will be asked for the same information.

---

# ⚠️ PAT Expiry Warning

GitHub PATs can expire depending on organization policies.

If Claude Code suddenly fails to install plugins and you see:

```
Repository not found
fatal: could not read from remote repository
```

Your PAT is likely expired.

👉 Contact **Patrick Miron (GitHub: DragonAngel1st)** for renewal.

---

# 🔄 Modifying the Scripts for Another Plugin

To adapt the scripts for a *different plugin repository*:

1. Open either script.
2. Modify these two variables:

```bash
REPO_OWNER="DragonAngel1st"
REPO_NAME="ClaudeCodePydanticSubagentFactory_plugin"
```

For example, if you create a future plugin:

```
https://github.com/DragonAngel1st/MyNextClaudePlugin.git
```

Change:

```bash
REPO_NAME="MyNextClaudePlugin"
```

3. Save the script and run it again.

That's it! Git will now store credentials **only** for that new repo.

---

# ✔ Summary

This repo provides:

- A public Claude Code plugin marketplace
- Two scripts to configure HTTPS+PAT authentication for private plugins
- A safe Git configuration strategy that does not affect other repos
- Easy extensibility for future plugins

If you have additional plugins you want to support or distribute,  
simply duplicate and edit the scripts as described above.

---

If you want, I can also:
- Add badges  
- Add automatic installation instructions  
- Add a table of plugins maintained by you  
- Provide an example `marketplace.json` structure

Let me know!