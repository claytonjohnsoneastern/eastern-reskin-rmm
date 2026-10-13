# Eastern RMM: modern draft

A modern theme for the Tactical RMM web console (tacticalrmm-web **v0.101.64**, the web
version used by Tactical RMM server 1.5.0 to 1.5.2), styled for Eastern Telephone &
Technologies. It changes how the console looks. Everything techs click, every menu and
every dialog stays where it was, so Tactical's documentation and any existing training
still match the screen.

## What is in this folder

| File | Purpose |
| --- | --- |
| `eastern-rmm-modern-web-v0.101.64.tar.gz` | The built console, ready to serve. |
| `apply-eastern-reskin.sh` | Run on the RMM server. Checks the web version, backs up the current files, installs, keeps the server's API address. `--rollback` restores the backup. |
| `eastern-reskin-v0.101.64-modern.patch` | The complete source change against upstream v0.101.64. |
| `rebuild-eastern-reskin.sh` | Rebuilds the theme for a newer Tactical web version. |

## What changed for techs

Nothing moved. The differences are visual:

- The header and the File / View / Agents / Settings / Tools / Reporting / Help menu are one light bar.
- The client tree, the agent table and the agent detail tabs sit in framed panels.
- Buttons and tabs use sentence case ("Show installation instructions" instead of all caps).
- Dialogs have plain title bars and rounded corners.
- The selected agent row has a blue stripe on its left edge.
- The sign-in page has a new layout. Signing in, two-factor and SSO work the same way.
- Light and dark themes are both included. Each tech's saved theme choice is kept.

## Built for daily use by a team

- **Same layout as Tactical.** Tactical's docs, videos and community answers still match the screen.
- **Readable.** Body text, muted labels and links meet WCAG AA contrast (4.5:1 or better) in both themes.
- **Keyboard-friendly.** Buttons, tabs, menu items and tree nodes show a clear focus outline.
- **Reduced motion.** The OS "reduce motion" setting turns off animations.
- **Self-contained.** The typeface is bundled, so the console makes no calls to outside font or CDN services.
- **Same table density.** Rows stay compact enough to scan hundreds of agents.

## Rolling it out

Installing on the server changes the console for everyone at once; there is no per-user switch.

1. **Trial it.** Install outside working hours, then have one tech run through their usual
   tasks (find an agent, run a script, open Script Manager, approve patches, take control).
   If anything is off, roll back with one command.
2. **Tell the team.** Share the "What changed for techs" list above. No retraining is needed.
   Each tech presses Ctrl+F5 once to load the new look.
3. **After every Tactical update,** re-run the installer (see below).

### Install

    grep ^WEB_VERSION /rmm/api/tacticalrmm/tacticalrmm/settings.py   # must say 0.101.64
    chmod +x apply-eastern-reskin.sh
    sudo ./apply-eastern-reskin.sh eastern-rmm-modern-web-v0.101.64.tar.gz

Undo: `sudo ./apply-eastern-reskin.sh --rollback`

Only `/var/www/rmm/dist` (static files served by nginx) is replaced. The API, database,
agents, MeshCentral and user accounts are untouched.

### After a Tactical update

Tactical's `update.sh` replaces `/var/www/rmm/dist` with the stock console every time it runs.

- Web version unchanged: run the installer again with the same tarball.
- Web version changed: on a machine with git and Node.js 20+, run
  `./rebuild-eastern-reskin.sh <new version>` and install the tarball it produces. If
  upstream has rewritten a file the theme touches, the script stops with a conflict
  rather than building something broken.

These scripts assume the standard (non-Docker) install.

## Commercial use and the licence

Eastern is a for-profit company using this to manage customer systems, so read this part
before rolling out. I'm not a lawyer; this is a plain reading of the
[Tactical RMM License v1.0](https://license.tacticalrmm.com).

- **Allowed:** hosting it and using it to manage your own and your customers' systems (section 2).
- **Allowed:** modifying the software (section 2), which covers this theme.
- **Not allowed:** offering it, or a modified version, as part of a commercial service
  to others. That includes giving customers their own logins (section 2 excludes
  "a service allowing third parties to interact remotely"), hosting it for other
  companies, or selling installation or setup.
- **Needs attention:** section 2 also says AmidaWare's prior written approval is needed for
  "all commercial use and/or for-profit service use". That sentence is broad. Get a short
  written confirmation from AmidaWare that your technicians can use a rebranded console
  internally. Tactical sells self-hosted plans (Tier 1 covers up to 199 endpoints) that
  include support, code-signed agents, reporting and SSO, which a business deployment
  will want anyway.
- **Source sharing:** if a modified version is "made available to any other person", its
  source must be published online (section 3). The whole theme is in the `.patch` file
  and contains nothing confidential. Publishing it, for example in a public GitHub fork,
  removes any question.
- **Name:** the product is shown as "Eastern RMM", not "Tactical RMM", which keeps clear of
  their trademark (section 10). The sign-in page keeps AmidaWare's copyright notice
  (section 4).

## Known gaps in this draft

- The Eastern wordmark is redrawn in type, not your logo file.
- Take Control and remote desktop are restyled but were not exercised: the test server had no MeshCentral.
