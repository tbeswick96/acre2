# CLAUDE.md — ACRE2 (UKSF fork)

Advanced Combat Radio Environment 2 — Arma 3 realistic radio/voice comms via TeamSpeak. **UKSF-controlled fork** of IDI-Systems/ACRE2. Shipped as part of the UKSF modpack stack alongside the modpack, ace, and uksf_air. Prefix `acre`, mainprefix `idi`.

Working branch: **`customrelease`**. Remotes: `origin` = `tbeswick96/acre2`, `upstream` = `IDI-Systems/acre2`, `cyruz` = `Cyruz143/acre2`.

## Fork status — UKSF owns the build

UKSF controls this fork's source and build. **Calling ACRE internal functions and patching ACRE source is safe — no upstream-drift concern.** UKSF features (e.g. the NPC-STT mic-capture tee, see git log `feat(npc-stt): ACRE capture tee to STT named pipe`) live directly in this tree. `upstream` exists for pulling fixes but the canonical UKSF build is `customrelease`.

## Build

```bash
hemtt build    # release build (build.bat = `hemtt.exe build`)
hemtt check    # lint
```
Native DLLs (`acre_x64.dll`, `ACRE2*.dll`) and the TeamSpeak `plugin/` are checked in and bundled via `.hemtt/project.toml [files]`. Signing key: `keys/acre_2.7.3.1024.bikey`.

## Key dirs

```
addons/
  main/         CfgPatches, version       api/          public ACRE API
  sys_core/ sys_radio/ sys_signal/ sys_antenna/ sys_data/ sys_io/   core radio sim
  sys_prc152/ sys_prc148/ sys_prc117f/ sys_prc343/ sys_prc77/ …     individual radios
  sys_zeus/ sys_spectator/ sys_intercom/ sys_gestures/ ace_interact/
  compat_*/     mod compat patches (RHS, SOG, GM, CSLA, Unsung, WS, SPE)
plugin/         TeamSpeak 3 plugin source
extensions/     native extension source     keys/   .bikey
```

## Gotchas

- **DLLs and `.bikey` are committed binaries** — bundled by `[files]` include globs, not rebuilt by `hemtt build`. Rebuilding the C++ extension is a separate toolchain.
- Mainprefix is **`idi`** (not `u` / `uksf`) — config paths are `\idi\acre\addons\…`.
- UKSF custom branches diverge from upstream; when pulling `upstream` fixes, rebase/merge into `customrelease`, don't reset.

## Brain & skills

Brain vault (`E:/Workspace/workshop/Brain`, via `mcp__brain__*`):
- `concepts/acre2-captured-voice-tee-to-framed-named-pipe.md` — the STT mic-capture tee pattern
- `concepts/acre2-attenuation-reuse-for-npc-tts.md`, `concepts/acre2-base64-positional-sound-injection.md` — reusing ACRE audio for NPC TTS
- `entities/uksf-workspace-layout.md` (fork inventory), `entities/arma3-modpack-stack.md`

Skills: `arma-config-syntax`, `arma-config-cache`, `sqf-deep-review`, `sqf-command-lookup`, `arma-dev-test-server`, `uksf-server`.
