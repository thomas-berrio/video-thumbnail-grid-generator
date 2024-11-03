#!/bin/bash

# Path to default font (set your system's default font path)
font_path="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

# Functions for error handling and exit
function error_exit {
    echo "$1" >&2
    exit 1
}

# Function to display help message
function display_help {
    echo "Usage: $0 --input <input_video> [--output <output_image>] [--format <format>] [--width <width>] [--grid <grid_size>] [--verbose]"
    echo "
Options:"
    echo "  --input <input_video>   Path to the input video file (required)"
    echo "  --output <output_image> Path to the output image file (default: thumbnail_grid.png)"
    echo "  --format <format>       Output format (jpg, png, webp). Default: png"
    echo "  --width <width>         Width of each thumbnail frame (150, 300, 600, 1200). Default: 300"
    echo "  --grid <grid_size>      Grid size for montage (3x3, 4x4, 5x5). Default: 4x4"
    echo "  --verbose               Enable verbose mode for ffmpeg"
    echo "  --help                  Display this help message"
    exit 0
}

# Parse arguments
verbose=0
format="png"
width=300
grid_size="4x4"
while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            input="$2"
            shift 2
            ;;
        --output)
            output="$2"
            shift 2
            ;;
        --format)
            format="$2"
            shift 2
            ;;
        --width)
            width="$2"
            if [[ "$width" != "150" && "$width" != "300" && "$width" != "600" && "$width" != "1200" ]]; then
                error_exit "Error: width must be one of 150, 300, 600, 1200."
            fi
            shift 2
            ;;
        --grid)
            grid_size="$2"
            if [[ "$grid_size" != "3x3" && "$grid_size" != "4x4" && "$grid_size" != "5x5" ]]; then
                error_exit "Error: grid size must be one of 3x3, 4x4, 5x5."
            fi
            shift 2
            ;;
        --verbose)
            verbose=1
            shift 1
            ;;
        --help)
            display_help
            ;;
        *)
            echo "Unknown option: $1"
            display_help
            ;;
    esac
done

# Check if input file is provided
[[ -z "$input" ]] && error_exit "Error: --input is required. Use --help for usage information."

# Check if input file exists
[[ ! -f "$input" ]] && error_exit "Error: input video file $input not found. Aborting."

# Set default output if not specified
output="${output:-thumbnail_grid.$format}"

# Check if font file exists
[[ ! -f "$font_path" ]] && error_exit "Error: font file $font_path not found. Aborting."

# Check for required commands availability
command -v ffmpeg &>/dev/null || error_exit "Error: ffmpeg is required but not installed. Aborting."
command -v montage &>/dev/null || error_exit "Error: montage (ImageMagick) is required but not installed. Aborting."
command -v ffprobe &>/dev/null || error_exit "Error: ffprobe is required but not installed. Aborting."

# Extract video duration using ffprobe
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")

# Validate duration output
[[ -z "$duration" ]] && error_exit "Error: unable to determine video duration. Aborting."
total_seconds="${duration%.*}"

# Define exclusion margin percentage (e.g., 10%)
exclusion_margin_percent=10

# Calculate exclusion duration (10% from both the start and end)
exclusion_duration=$((total_seconds * exclusion_margin_percent / 100))

# Ensure that adjusted duration is positive
adjusted_duration=$((total_seconds - 2 * exclusion_duration))
if [[ $adjusted_duration -le 0 ]]; then
    error_exit "Error: video duration is too short to exclude margins. Aborting."
fi

# Determine the number of thumbnails to capture based on grid size
case $grid_size in
    "3x3")
        num_thumbnails=9
        ;;
    "4x4")
        num_thumbnails=16
        ;;
    "5x5")
        num_thumbnails=25
        ;;
    *)
        error_exit "Error: unsupported grid size. Aborting."
        ;;
esac

# Calculate interval, making sure we divide properly to avoid zero intervals
interval=$((adjusted_duration / (num_thumbnails - 1)))
[[ $interval -le 0 ]] && error_exit "Error: calculated interval duration is zero or negative. Aborting."

start_offset=$exclusion_duration

# Create a temp directory for thumbnails
tmpdir=$(mktemp -d) || error_exit "Error: unable to create temporary directory. Aborting."

# Set ffmpeg log level based on verbosity
ffmpeg_log_level="error"
[[ $verbose -eq 1 ]] && ffmpeg_log_level="info"

# Capture and annotate thumbnails with new start offset and interval
for ((i = 1; i <= num_thumbnails; i++)); do
    time=$((interval * (i - 1) + start_offset))
    timestamp=$(date -u -d "@$time" +%H:%M:%S)
    output_file="${tmpdir}/thumb_$(printf "%02d" "$i").$format"
    
    ffmpeg -v $ffmpeg_log_level -ss "$time" -i "$input" -vframes 1 \
        -filter:v "scale=${width}:-1,drawtext=fontfile='${font_path}': \
        text='${timestamp//:/\\:}': x=10: y=H-th-10: fontsize=22: fontcolor=white: \
        box=1: boxcolor=black@0.5: boxborderw=4" \
        "$output_file" || error_exit "Error: unable to create thumbnail $i. Aborting."
    
    echo "Thumbnail $i captured successfully."
done

# Generate the output montage, sorted numerically
montage "${tmpdir}"/thumb_*.$format -tile "$grid_size" -geometry +0+0 "$output" || error_exit "Error: unable to create thumbnail montage. Aborting."

# Clean up
rm -rf -- "$tmpdir"

# Completion message
echo "Thumbnail montage successfully created: $output."

exit 0
