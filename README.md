# Endpoint Availability Checker

A Bash script to monitor and check the availability of endpoints defined in a YAML configuration file.

## Dependencies

To run this script, you need the following tools installed on your system:

1. **Bash** (version 4 or higher) - Required for running the script.
2. **`curl`** - Used to send HTTP requests and check endpoint availability.
3. **`yq`** - A lightweight YAML processor used to parse the configuration file.
4. **`sed`** - Used for text manipulation.

### Installing Dependencies

#### 1. `yq`
You can install `yq` using one of the following methods:

- **Using Homebrew (macOS/Linux):**
  ```bash
  brew install yq
  ```

- **Using pip (Python-based installation):**
  ```bash
  pip install yq
  ```

#### 2. `curl`
Install `curl` using your system's package manager:

- **Debian/Ubuntu:**
  ```bash
  sudo apt-get update && sudo apt-get install curl
  ```

- **macOS (using Homebrew):**
  ```bash
  brew install curl
  ```

#### 3. `sed`
`sed` is typically pre-installed on most Linux and macOS systems. If it's not installed, you can install it using your system's package manager:

- **Debian/Ubuntu:**
  ```bash
  sudo apt-get update && sudo apt-get install sed
  ```

- **macOS (using Homebrew):**
  ```bash
  brew install gnu-sed
  ```

## Setup

1. Create a YAML configuration file named `endpoints.yaml` in the same directory as your script. The file should define endpoints with the following structure:
   ```yaml
   endpoints:
     - name: "Endpoint Name"
       url: "https://example.com/api"
       headers: |
         Header1: Value1
         Header2: Value2
       body: '{"key": "value"}'
     - name: "Another Endpoint"
       url: "https://another.example.com/api"
       headers: |
         Authorization: Bearer your-token
       body: ""
   ```

## Usage

1. Make sure the script has execute permissions:
   ```bash
   chmod +x your_script_name.sh
   ```

2. Run the script:
   ```bash
   ./your_script_name.sh
   ```

The script will continuously check the availability of the endpoints every 15 seconds and log the results.

## Explanation

- **`parse_config()`**: Parses the YAML configuration file and extracts endpoint details.
- **`check_endpoint()`**: Sends an HTTP request to each endpoint, checks the response status code and response time.
- **`get_domain()`**: Extracts the domain from the URL.
- The script logs the availability percentage for each domain every 15 seconds.

## Interrupting the Script

You can stop the script by pressing `Ctrl+C`, which will gracefully terminate it.

## Logs

The script prints the availability status to the console. Example output:
```
Current availability status:
- example.com: 90%
- another.example.com: 85%
```

---
