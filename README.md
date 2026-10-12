# Eastern RMM — themed web console for Tactical RMM

A presentation-only reskin of the official Tactical RMM web frontend
(`amidaware/tacticalrmm-web`, release **v0.101.64**, the web version pinned by
Tactical RMM server 1.5.0 – 1.5.2) for Eastern Telephone & Technologies.

Every feature is present because this *is* the Tactical frontend: 7 of its 234 source
files differ, and none of them contain feature logic.

## What is in this folder

| File | Purpose |
| --- | --- |
| `eastern-rmm-web-v0.101.64.tar.gz` | The built console, ready to serve. Same layout as upstream's `trmm-web` tarball (`dist/`). |
| `apply-eastern-reskin.sh` | Run on the RMM server. Backs up the current web files, installs the themed build, keeps the server's API address. `--rollback` restores the backup. |
| `eastern-reskin-v0.101.64.patch` | The complete source change against upstream v0.101.64 (one git commit). |
| `rebuild-eastern-reskin.sh` | Rebuilds the themed console for another web version by applying the patch to that upstream tag. |

## Install

1. Check the web version your server expects. It must match the package:

       grep ^WEB_VERSION /rmm/api/tacticalrmm/tacticalrmm/settings.py

   (`apply-eastern-reskin.sh` checks this too and stops on a mismatch.)

2. Copy the tarball and `apply-eastern-reskin.sh` to the RMM server, then:

       chmod +x apply-eastern-reskin.sh
       sudo ./apply-eastern-reskin.sh eastern-rmm-web-v0.101.64.tar.gz

3. Hard-refresh the browser (Ctrl+F5).

Undo at any time: `sudo ./apply-eastern-reskin.sh --rollback`

Only `/var/www/rmm/dist` is touched: static files that nginx serves. The API, database,
agents and MeshCentral are not changed, and agents never see this.

## After every Tactical RMM update

Tactical's `update.sh` deletes `/var/www/rmm/dist` and re-downloads the stock frontend
each time it runs, so the theme has to be put back afterwards:

- Web version unchanged: run `apply-eastern-reskin.sh` again with the same tarball.
- Web version changed: on a machine with git and Node.js 20+, run
  `./rebuild-eastern-reskin.sh <new version>`, then install the tarball it produces.
  If upstream has rewritten the header or the sign-in page, the patch stops with a
  conflict rather than building something wrong.

These scripts assume the standard (non-Docker) install layout.

## What the theme changes

- Palette from ettky.com: #056EB9 blue as the action colour, #EB5937 orange as the
  accent, #1D252B ink for the header, dialog title bars and dark surfaces.
- Heebo, the typeface used on ettky.com, bundled into the build (nothing loads from a CDN).
- Eastern wordmark in the header, on the sign-in card and on the session-expired screen.
- Sign-in screen, favicon and browser tab title ("Eastern RMM").
- Light and dark themes both restyled; the header toggle and each technician's saved
  preference work as before.

## What it deliberately leaves alone

- The agent's Windows service is literally named "Tactical RMM Agent", so the service
  check and the agent-recovery dialog still use that name.
- The small Tactical badge that marks community scripts in the script lists.
- The Help menu links to Tactical's docs, GitHub and Discord.
- The "new version available" chip, which links to Tactical's release notes.

## Licence

Tactical RMM is distributed under the Tactical RMM License Version 1.0
(https://license.tacticalrmm.com). It permits modifying the software and using it to
manage your own and your customers' systems. It does not permit selling or offering a
modified version as a product or hosted service, and section 4 requires AmidaWare's
copyright notice to stay with every copy. The sign-in screen carries that notice, and
`LICENSE.md` is unchanged in the source. This is not legal advice.
