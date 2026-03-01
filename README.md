# Photographer

A lightweight CLI tool that allows you to create instant clips from Twitch streams using a rolling local buffer.

This script continuously records a stream into short segments and lets you generate clips from recent moments — similar to a local ShadowPlay for Twitch.

---

## Features

- Rolling live buffer recording
- Instant backward clip creation
- Optional forward + backward clip mode
- No VOD dependency
- No re-downloading of content
- Lossless segment merging (no re-encoding)

---

## Dependencies

The following tools must be installed:

- ffmpeg
- streamlink

### Arch Linux

bash
sudo pacman -S ffmpeg streamlink


### Debian/Ubuntu

bash
sudo apt install ffmpeg streamlink



## Installation
### Option 1 — Download from Release (recommended)

1) Go to the Releases section of this repository.
2) Download the latest 

photographer.sh

.
3) Make it executable:

bash
chmod +x photographer.sh


4) (Optional) Move it into your PATH:

bash
sudo mv photographer.sh /usr/local/bin/photographer


### Option 2 — Clone repository

bash
git clone https://github.com/act-1F98A/Photographer.git
cd Photographer
chmod +x photographer.sh


## Usage Examples

Start recording a stream buffer:

bash
./twitch-buffer.sh streamer_name


Create a clip from recent moments:

bash
./twitch-buffer.sh streamer_name --clip


Create a clip including forward + backward buffer:

bash
./twitch-buffer.sh streamer_name --full-clip


For more information about available options:

bash
./twitch-buffer.sh --help


## How It Works

streamlink reads the live Twitch stream

ffmpeg splits it into short cyclic segments

When triggered, selected segments are copied and merged into a single .mp4 file

All processing happens locally.
No Twitch VOD access required.

Output Structure

By default:

~/twitch-buffer/
    segments/<streamer>/
    clips/<streamer>/


## License

MIT License