# LLM Functions Integration

This document describes the llm-functions integration added to aichat, which provides a comprehensive toolkit for creating and using LLM tools and agents.

## Overview

The llm-functions integration brings the powerful tools and agent system from the [llm-functions](https://github.com/HyperCogWizard/llm-functions) project into aichat. This includes:

- **10 Built-in Tools** for common tasks
- **2 Pre-configured Agents** for specific use cases
- **Multi-language Support** for tools (Bash, JavaScript, Python)
- **Automatic Declaration Generation** from code comments
- **Build System** for managing tools and agents

## Available Tools

### File Operations
- `fs_cat` - Read file contents
- `fs_ls` - List files and directories  
- `fs_write` - Write content to files

### Code Execution
- `execute_command` - Execute shell commands
- `execute_js_code` - Run JavaScript code in Node.js
- `execute_py_code` - Run Python code

### Web & Information
- `fetch_url_via_curl` - Fetch web page content
- `search_wikipedia` - Search Wikipedia for information
- `get_current_weather` - Get weather information (requires API key)

### Utilities
- `get_current_time` - Get current date/time with formatting

## Available Agents

### Coder Agent
A coding assistant that can:
- Execute shell commands
- Run code in multiple languages
- Read and write files
- Debug and analyze code

**Usage**: `aichat --agent coder "help me debug this Python script"`

### Todo Agent  
A task management assistant that can:
- Read and manage todo files
- Track completed tasks
- Organize task lists

**Usage**: `aichat --agent todo "show me my current tasks"`

## Using Function Calling

To use function calling with aichat, use the special `%functions%` role:

```bash
# Use all available functions
aichat --role %functions% "what time is it?"

# The AI can automatically call get_current_time tool
```

Example function calls the AI might make:
- `get_current_time()` for time queries
- `fs_ls({"path": "."})` to list current directory
- `execute_command({"command": "ls -la"})` to run shell commands
- `search_wikipedia({"query": "artificial intelligence"})` for information

## Creating New Tools

### Bash Tools

Create a new `.sh` file in the `tools/` directory:

```bash
#!/usr/bin/env bash
set -e

# @describe Your tool description here
# @option --param1! Required parameter description
# @option --param2=default Optional parameter with default

main() {
    echo "Hello from $argc_param1"
    # Your tool logic here
}

eval "$(argc --argc-eval "$0" "$@")"
```

### JavaScript Tools

Create a new `.js` file in the `tools/` directory:

```javascript
/**
 * Your tool description here
 * @typedef {Object} Args
 * @property {string} param1 - Required parameter description
 * @property {string} param2 - Optional parameter description  
 * @param {Args} args
 */
exports.run = function ({ param1, param2 }) {
    console.log(`Hello from ${param1}`);
    // Your tool logic here
};
```

### Python Tools

Create a new `.py` file in the `tools/` directory:

```python
def run(param1: str, param2: str = "default"):
    """Your tool description here
    Args:
        param1: Required parameter description
        param2: Optional parameter description
    """
    print(f"Hello from {param1}")
    # Your tool logic here
```

## Building Functions

After creating new tools, rebuild the function declarations:

```bash
# Add your tool to tools.txt
echo "my_new_tool.sh" >> tools.txt

# Rebuild declarations
bash scripts/build-declarations.sh tools/my_new_tool.sh > temp.json
# Then manually add to functions/functions.json
```

## Project Structure

```
├── tools/                  # Tool scripts
│   ├── execute_command.sh
│   ├── fs_*.sh
│   ├── execute_js_code.js
│   └── execute_py_code.py
├── scripts/                # Build and runtime scripts  
│   ├── build-declarations.*
│   └── run-tool.*
├── agents/                 # Agent definitions
│   ├── coder/
│   └── todo/
├── functions/              # Generated function declarations
│   └── functions.json
├── utils/                  # Utilities
│   └── guard_operation.sh
├── tools.txt              # List of tools to include
└── agents.txt             # List of agents to include
```

## Testing

Run the integration test to verify everything is working:

```bash
./test-integration.sh
```

This will check:
- Tools directory structure
- Script runners
- Function declarations validity  
- Declaration generation
- Basic tool execution

## Environment Variables

Some tools require environment variables:

- `OPENWEATHERMAP_API_KEY` - For weather information
- `LLM_OUTPUT` - Set automatically for tool output capture

## Troubleshooting

### Tool Not Found
- Check that the tool file exists in `tools/`
- Verify the tool is listed in `tools.txt`
- Ensure the tool is included in `functions/functions.json`

### Permission Denied
- Make sure shell scripts are executable: `chmod +x tools/*.sh`
- Check that script runners are executable: `chmod +x scripts/*`

### Function Declaration Errors
- Verify comment syntax in tool files
- Check that the build script can parse the tool
- Validate generated JSON with `jq`

## Advanced Usage

For more advanced scenarios, refer to the original [llm-functions documentation](https://github.com/HyperCogWizard/llm-functions) for additional tools, agents, and patterns.