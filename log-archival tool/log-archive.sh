#!/bin/bash

# === Defaults ===
LOG_DIR="/var/log"
DAYS_TO_KEEP_LOGS=7
DAYS_TO_KEEP_BACKUPS=30
ARCHIVE_DIR="/home/arundhati/log_archives"
SCRIPT_PATH="$HOME/Devops-roadmap/log-archival tool/log-archive.sh"
CRON_SCHEDULE="0 1 * * *"  # Daily at 1 AM

# === Ensure archive dir exists ===
mkdir -p "$ARCHIVE_DIR"

# === Archive Function ===
archive_logs() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
    ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

    echo "📦 Archiving logs from $LOG_DIR..."
    echo "Running tar from $LOG_DIR..."
    tar --ignore-failed-read -czf "$ARCHIVE_PATH" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")" 2>> "$ARCHIVE_DIR/skipped_files.log"
    
    echo "Saving archive to $ARCHIVE_PATH"
    echo "$TIMESTAMP - Archived logs from $LOG_DIR to $ARCHIVE_PATH" >> "$ARCHIVE_DIR/archive_log.txt"
    
    echo "✅ Archive complete: $ARCHIVE_NAME"
}

# === Cleanup Function ===
cleanup_old_archives() {
    echo "🧹 Deleting backups older than $DAYS_TO_KEEP_BACKUPS days..."
    find "$ARCHIVE_DIR" -type f -name "*.tar.gz" -mtime +$DAYS_TO_KEEP_BACKUPS -exec rm -f {} \;
}


# === Setup Cron Function ===
setup_cron() {
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "❌ Error: Script path not found at $SCRIPT_PATH"
        echo "   Please update the path in the script before setting up cron."
        return 1
    fi

    echo "⏰ Setting up cron job..."
    
    CRON_CMD="$CRON_SCHEDULE /bin/bash $SCRIPT_PATH --cron >> $ARCHIVE_DIR/cron_output.log 2>&1"

    crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" >/dev/null
    if [ $? -eq 0 ]; then
        echo "⚠️ Cron job already exists."
    else
        (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
        echo "✅ Cron job set to run daily at 1 AM."
    fi
}

# === Handle Cron Run ===
if [[ "$1" == "--cron" ]]; then
    archive_logs
    cleanup_old_archives
    exit 0
fi

# === MENU LOOP ===
while true; do
    echo ""
    echo "🛠️  Log Archiver Menu"
    echo "----------------------"
    echo "1. Specify Log Directory [current: $LOG_DIR]"
    echo "2. Specify Days to Keep Logs [current: $DAYS_TO_KEEP_LOGS]"
    echo "3. Specify Days to Keep Backup Archives [current: $DAYS_TO_KEEP_BACKUPS]"
    echo "4. Run Log Archiving Process Now"
    echo "5. Setup Daily Cron Job at 1 AM"
    echo "6. Exit"
    echo ""

    read -r -p "Choose an option [1-6]: " choice

    case "$choice" in
        1)
            read -r -p "Enter log directory path: " input
            LOG_DIR="$input"
            ;;
        2)
            read -r -p "Enter number of days to keep logs: " input
            DAYS_TO_KEEP_LOGS="$input"
            ;;
        3)
            read -r -p "Enter number of days to keep backup archives: " input
            DAYS_TO_KEEP_BACKUPS="$input"
            ;;
        4)
            archive_logs
            cleanup_old_archives
            ;;
        5)
            setup_cron
            ;;
        6)
            echo "👋 Exiting. Bye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Try again."
            ;;
    esac
done
