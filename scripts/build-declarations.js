#!/usr/bin/env node

// Build function declarations from JavaScript tool files
// Usage: build-declarations.js <tool_file>

const fs = require('fs');
const path = require('path');

if (process.argv.length !== 3) {
    console.error('Usage: node build-declarations.js <tool_file>');
    process.exit(1);
}

const toolFile = process.argv[2];
if (!fs.existsSync(toolFile)) {
    console.error(`Tool file not found: ${toolFile}`);
    process.exit(1);
}

// Extract function name from filename
const functionName = path.basename(toolFile, '.js');

// Read and parse the tool file
const content = fs.readFileSync(toolFile, 'utf8');

// Extract JSDoc comments
let description = '';
const properties = {};
const required = [];

// Simple regex-based parsing of JSDoc comments
const jsdocMatch = content.match(/\/\*\*([^*]|\*(?!\/))*\*\//);
if (jsdocMatch) {
    const jsdoc = jsdocMatch[0];
    
    // Extract description (first actual content line after /**)
    const lines = jsdoc.split('\n');
    for (const line of lines) {
        const trimmed = line.replace(/^\s*\*\s*/, '').trim();
        if (trimmed && !trimmed.startsWith('@') && trimmed !== '/**' && trimmed !== '*/') {
            description = trimmed.replace(/\.$/, ''); // Remove trailing period
            break;
        }
    }
    
    // Extract @property annotations
    const propertyMatches = jsdoc.matchAll(/\*\s*@property\s+\{([^}]+)\}\s+(\w+)\s*-\s*(.+)/g);
    for (const match of propertyMatches) {
        const type = match[1];
        const name = match[2];
        const desc = match[3];
        
        properties[name] = {
            type: type === 'string' ? 'string' : type === 'number' ? 'number' : 'string',
            description: desc.trim()
        };
        
        // For simplicity, assume all properties are required
        required.push(name);
    }
}

// Generate function declaration JSON
const declaration = {
    name: functionName,
    description: description,
    parameters: {
        type: 'object',
        properties: properties,
        required: required
    }
};

console.log(JSON.stringify(declaration, null, 2));