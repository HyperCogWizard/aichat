#!/usr/bin/env node

// Tool runner for JavaScript tools
// Usage: run-tool.js <tool_name> <json_args>

const fs = require('fs');
const path = require('path');

if (process.argv.length !== 4) {
    console.error('Usage: node run-tool.js <tool_name> <json_args>');
    process.exit(1);
}

const toolName = process.argv[2];
const jsonArgs = process.argv[3];

// Find the tool script
const toolScript = path.join('tools', `${toolName}.js`);
if (!fs.existsSync(toolScript)) {
    console.error(`Tool not found: ${toolScript}`);
    process.exit(1);
}

try {
    // Parse JSON arguments
    const args = JSON.parse(jsonArgs);
    
    // Load and execute the tool
    const tool = require(path.resolve(toolScript));
    if (typeof tool.run === 'function') {
        tool.run(args);
    } else {
        console.error(`Tool ${toolName} does not export a run function`);
        process.exit(1);
    }
} catch (error) {
    console.error(`Error executing tool ${toolName}:`, error.message);
    process.exit(1);
}