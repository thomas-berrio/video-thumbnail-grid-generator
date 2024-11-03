# Video Thumbnail Grid Generator

## Project Name
**ThumbyGrid**

## Demo ##
![alt demo.jpg](https://raw.githubusercontent.com/thomas-berrio/video-thumbnail-grid-generator/refs/heads/main/demo.jpg)

## Description
ThumbyGrid is a Bash script that generates a grid of thumbnails from a video file. It allows you to easily capture evenly spaced frames from a video, customize thumbnail size, and format the output as a collage. This tool is particularly useful for video preview purposes, creating overview images for media libraries, or providing a visual summary of a video.

## Features
- Extracts evenly distributed frames from a video.
- Supports multiple output formats: `jpg`, `png`, `webp`.
- Customizable thumbnail width (`150`, `300`, `600`, `1200` pixels).
- Configurable grid size (`3x3`, `4x4`, `5x5`), allowing 9, 16, or 25 thumbnails per montage.
- Verbose mode to enable more detailed output.
- Automatic exclusion of the first and last 10% of the video to ensure meaningful frames.

## Requirements
- **ffmpeg**: For capturing frames from the video.
- **ImageMagick** (`montage`): For creating the thumbnail grid.
- **ffprobe**: To get video duration for calculating intervals.
- **Bash**: A Unix-like environment to execute the script.

## Installation
Ensure the following commands are installed and available on your system:

```bash
sudo apt-get install ffmpeg imagemagick
```

## Usage
```bash
./thumbygrid.sh --input <input_video> [--output <output_image>] [--format <format>] [--width <width>] [--grid <grid_size>] [--verbose]
```

### Options
- `--input <input_video>`: Path to the input video file (required).
- `--output <output_image>`: Path to the output image file (default: `thumbnail_grid.png`).
- `--format <format>`: Output format (`jpg`, `png`, `webp`). Default is `png`.
- `--width <width>`: Width of each thumbnail (`150`, `300`, `600`, `1200`). Default is `300`.
- `--grid <grid_size>`: Grid size for montage (`3x3`, `4x4`, `5x5`). Default is `4x4`.
- `--verbose`: Enable verbose mode for ffmpeg.
- `--help`: Display usage information.

### Examples
1. Generate a 4x4 thumbnail grid (default values):
   ```bash
   ./thumbygrid.sh --input myvideo.mp4
   ```

2. Generate a 5x5 grid of 600-pixel wide thumbnails in `webp` format:
   ```bash
   ./thumbygrid.sh --input myvideo.mp4 --output montage.webp --format webp --width 600 --grid 5x5
   ```

3. Generate a 3x3 thumbnail grid with verbose logging enabled:
   ```bash
   ./thumbygrid.sh --input myvideo.mp4 --grid 3x3 --verbose
   ```

## Notes
- **Exclusion Margins**: The script excludes the first and last 10% of the video to avoid irrelevant thumbnails (like intro logos or end credits).
- **Temporary Files**: Thumbnails are temporarily saved in a generated folder and are deleted after creating the final montage.

## Troubleshooting
- **ffmpeg not found**: Make sure `ffmpeg` is installed and available in your PATH.
- **montage command missing**: Install ImageMagick (`montage` is part of this package).
- **Video too short**: If the video is too short after excluding 10% at the start and end, there might not be enough frames to generate the desired number of thumbnails.

## License
This project is open-source and available under the MIT License.

## Contributions
Feel free to open issues or pull requests if you have suggestions or bug reports.

