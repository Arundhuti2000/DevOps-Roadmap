#!/bin/bash

# 1. Check if directory is passed
if [ -z "$1" ]; then
  echo "Usage: $0 <log-directory>" #$0 is the bashcript name value
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "⚠️  Warning: You are not running as root. Some files in $LOG_DIR may not be archived due to permission restrictions."
fi

LOG_DIR="$1"

# 2. Check if directory exists
if [ ! -d "$LOG_DIR" ]; then
  echo "Error: Directory '$LOG_DIR' does not exist."
  exit 2
fi

# 3. Timestamp for archive name
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 4. Create archive directory if it doesn't exist
ARCHIVE_DIR="$HOME/log_archives"
mkdir -p "$ARCHIVE_DIR"

# 5. Set archive filename
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

# 6. Compress the log directory
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")"

# 7. Log the archive action to a log file
LOG_FILE="$ARCHIVE_DIR/archive_log.txt"
echo "$TIMESTAMP - Archived '$LOG_DIR' to '$ARCHIVE_PATH'" >> "$LOG_FILE"

# 8. Confirmation message
echo "✅ Logs archived successfully to $ARCHIVE_PATH"