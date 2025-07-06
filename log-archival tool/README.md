# Log Archival Tool

A simple and flexible Bash-based CLI tool for archiving system logs, cleaning up old logs, and optionally scheduling the process with a cron job. This tool is ideal for keeping Unix-based systems clean while retaining compressed log backups for future reference.

## Features

- Compresses log directories into timestamped `.tar.gz` archives.
- Cleans up old backup archives based on user-defined retention.
- Interactive menu-driven interface for manual use.
- Automatically schedules daily log archiving via cron.
- Supports permission handling and safe fallbacks.
- Designed for both root and non-root environments.

## Requirements

- Unix-based OS (Linux/macOS)
- Bash shell
- `tar`, `find`, and `cron` available in system

## Setup

1. Clone or copy the script to your system.
2. Make it executable:
   ```bash
   chmod +x log-archive.sh
   ```
3. Run the script:
   ```bash
   ./log-archive.sh
   ```

## Menu Options

Upon running the script, you'll see the following options:

1. **Specify Log Directory**  
   Set the path to the log directory you want to archive (default: `/var/log`).

2. **Specify Days to Keep Logs**  
   Configure how long raw logs should be retained (optional; for future use).

3. **Specify Days to Keep Backup Archives**  
   Set how many days you want to retain `.tar.gz` archives before they're deleted.

4. **Run Log Archiving Process Now**  
   Immediately archives the logs and removes old backups.

5. **Setup Daily Cron Job**  
   Automatically runs the archive and cleanup process daily at 1 AM.

6. **Exit**  
   Exits the tool.

## Cron Integration

The tool can set up a cron job automatically. It checks for existing jobs and avoids duplication.

The job runs:
```bash
/bin/bash /path/to/log-archive.sh --cron
```

To manually remove the cron job:
```bash
crontab -e
# Remove the line containing 'log-archive.sh --cron'
```

## File Paths and Output

- **Archives:**  
  Saved to `~/log_archives/` (or your username’s home directory).

- **Archive Format:**  
  `logs_archive_YYYYMMDD_HHMMSS.tar.gz`

- **Logs:**  
  - Archive actions are logged in `archive_log.txt`  
  - Skipped files due to permission issues are logged in `skipped_files.log`

## Example

```bash
./log-archive.sh
```
Choose option `4` to create an archive and clean up backups:
```
Running tar from /var/log...
Saving archive to /home/username/log_archives/logs_archive_20250705_130012.tar.gz
Archive complete: logs_archive_20250705_130012.tar.gz
```

## Troubleshooting

- **Permission denied errors:**  
  Some logs under `/var/log` may require root access. Run the script with `sudo` if needed.

- **Archive saved under `/root` instead of user folder:**  
  If run as `sudo`, `$HOME` may point to `/root`. The script now detects and corrects this using the original user's home.

- **Nothing happens in cron:**  
  Ensure the cron job uses the `--cron` flag. The interactive menu won’t work under cron.

## Project URL:
https://roadmap.sh/projects/log-archive-tool
