# Photographer

A lightweight tool for creating instant clips from Twitch streams using a rolling local buffer.

Photographer can be used both as a **fully CLI utility** and as an **interactive UI application** with streamer management, settings, and localization.

It continuously records a stream into short segments and allows you to create clips from recent moments — similar to a local ShadowPlay for Twitch.

---

## Features

- Rolling live buffer recording
- Instant backward clip creation
- Forward + backward clip mode
- Interactive UI (wofi / rofi / fzf)
- Streamer list management
- Global and per-streamer settings
- Multi-language support
- No VOD dependency
- No re-downloading of content
- Lossless segment merging (no re-encoding)

---

## Dependencies

Required:

- `ffmpeg`
- `streamlink`

Install them using your system package manager.

Optional (UI):

Install **at least one** of the following:

- `wofi`
- `rofi`
- `fzf`

These are used for the interactive interface.

---

## Installation

### Option 1 — Download from Release (recommended)

1) Go to the [Releases](https://github.com/act-1F98A/Photographer/releases/) page  
2) Download the latest `photographer.sh`  
3) Make it executable:
```bash
chmod +x photographer.sh
```
(Optional) Move it into your PATH:
```bash
mv photographer.sh ~/.local/bin/photographer
```
---
### Option 2 — Clone repository
```bash 
git clone https://github.com/act-1F98A/Photographer.git
cd Photographer
chmod +x photographer
```
(Optional)
```bash
mv photographer.sh ~/.local/bin/photographer
```
---
## Usage
### CLI mode
Start buffer or toggle recording:
```bash
photographer --start-buffer
```
Create a clip:
```bash
photographer --clip
```
Create a full clip (with forward buffer):
```bash
photographer --full-clip
```
Create a clip for a specific streamer:
```bash
photographer --clip --streamer NAME
```
\(if the streamer is not explicitly specified when creating the clip, the clip will be created for the active streamer according to the ~/.config/photographer/config file\)

#### Help
For more information about available options:
```bash
photographer --help
```
### UI mode
Run without arguments to open the interactive interface:
```bash
photographer
```
From there you can:

- Start/stop buffer
- Create clips
- Select active streamer
- Manage streamer list
- Change settings
- Switch language
---
Start buffer
![Demo Start Buffer](demo_start_buffer.gif)
Creation clip
![Demo Clip Creation](demo_clip_creation.gif)

## How It Works

- `streamlink` reads the live Twitch stream
- `ffmpeg` splits it into short cyclic segments
- Segments are stored in a rolling buffer
- When triggered, segments are selected and merged into a `.mp4` clip
All processing is done locally.
No Twitch VOD access is required.
---
## Output Structure
By default:
```
~/photographer/
    segments/<streamer>/
    clips/<streamer>/
        made_clip/
        data/
```
---
## Notes
- The tool works entirely locally
- No stream re-downloads are performed
- Clips are created without re-encoding
---
## License
MIT License
