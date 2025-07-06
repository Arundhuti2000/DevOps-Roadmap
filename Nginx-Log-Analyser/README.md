# Nginx Log Analyzer Script

## Description

This shell script is a simple command-line tool designed to analyze Nginx access log files. It processes the log data to extract and present key statistics, helping users quickly understand traffic patterns and potential issues.

---

## Features

The script provides the following insights from a given Nginx access log file:

- **Top 5 IP addresses** with the most requests  
- **Top 5 most requested paths** (URLs)  
- **Top 5 response status codes** (e.g., 200, 404, 500)  
- **Top 5 user agents** (browsers/bots) making requests  

---

## Requirements

- A Unix-like operating system (Linux, macOS, WSL on Windows)  
- Bash shell (usually pre-installed)  
- Standard command-line utilities: `grep`, `awk`, `sort`, `uniq`, `head`, `sed`  
- A sample Nginx access log file (or any compatible Nginx access log)  

---

## Obtaining the Sample Log File

You can download the `access.log` sample file from:  
[https://www.dropbox.com/s/o3n9149021q6s8b/access.log?dl=1](https://www.dropbox.com/s/o3n9149021q6s8b/access.log?dl=1)

---

## Usage

### 1. Save the Script  
Save the provided shell script content into a file named `log_analyzer.sh`.

### 2. Make the Script Executable  
Open your terminal, navigate to the directory where you saved `log_analyzer.sh`, and run:

```bash
chmod +x log_analyzer.sh
```

### 3. Run the Script  
Execute the script by providing the path to your Nginx access log file as an argument:

```bash
./log_analyzer.sh access.log
```

*(Replace `access.log` with the actual path to your log file if it's in a different location.)*

---

## Example Output

```
Analyzing log file: access.log

Top 5 IP addresses with the most requests:
45.76.135.253 - 1000 requests
142.93.143.8 - 600 requests
178.128.94.113 - 50 requests
43.224.43.187 - 30 requests
178.128.94.113 - 20 requests

Top 5 most requested paths:
/api/v1/users - 1000 requests
/api/v1/products - 600 requests
/api/v1/orders - 50 requests
/api/v1/payments - 30 requests
/api/v1/reviews - 20 requests

Top 5 response status codes:
200 - 1000 requests
404 - 600 requests
500 - 50 requests
401 - 30 requests
304 - 20 requests

Top 5 user agents:
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 - 1000 requests
Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html) - 600 requests
curl/7.68.0 - 50 requests
PostmanRuntime/7.29.0 - 30 requests
Python-requests/2.25.1 - 20 requests

Analysis complete.
```

---

## How it Works (Brief Overview)

The script leverages a pipeline of standard Unix commands:

- `grep`: Used for pattern matching and extracting specific data (like IP addresses)  
- `awk`: A powerful text processing tool used for extracting fields and formatting output  
- `sort`: Sorts lines alphabetically or numerically  
- `uniq -c`: Counts consecutive identical lines (requires sorted input)  
- `head -n 5`: Extracts the top 5 lines  
- `sed`: Performs simple text transformations (e.g., trimming characters)  

Each section of the script pipes the output of one command into the next, allowing for complex data manipulation in a concise and efficient manner.

---

## Contributing

Feel free to fork this repository, suggest improvements, or submit pull requests.

---

## License

This project is open source and available under the [MIT License](https://opensource.org/licenses/MIT).
