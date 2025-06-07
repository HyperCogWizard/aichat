#!/usr/bin/env python3

# Build function declarations from Python tool files
# Usage: build-declarations.py <tool_file>

import sys
import json
import ast
import inspect
import importlib.util
import os

if len(sys.argv) != 2:
    print('Usage: python build-declarations.py <tool_file>', file=sys.stderr)
    sys.exit(1)

tool_file = sys.argv[1]
if not os.path.exists(tool_file):
    print(f'Tool file not found: {tool_file}', file=sys.stderr)
    sys.exit(1)

# Extract function name from filename
function_name = os.path.basename(tool_file).replace('.py', '')

try:
    # Load the module to get the run function
    spec = importlib.util.spec_from_file_location(function_name, tool_file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    
    if not hasattr(module, 'run'):
        print(f'Tool {function_name} does not have a run function', file=sys.stderr)
        sys.exit(1)
    
    run_func = getattr(module, 'run')
    
    # Get function signature and docstring
    sig = inspect.signature(run_func)
    doc = inspect.getdoc(run_func) or ''
    
    # Extract description (first line of docstring)
    description = doc.split('\n')[0].strip() if doc else f'Execute {function_name}'
    
    # Build properties from function parameters
    properties = {}
    required = []
    
    for param_name, param in sig.parameters.items():
        # Get type hint if available
        param_type = 'string'  # default
        if param.annotation != inspect.Parameter.empty:
            if param.annotation == str:
                param_type = 'string'
            elif param.annotation == int:
                param_type = 'integer'
            elif param.annotation == float:
                param_type = 'number'
            elif param.annotation == bool:
                param_type = 'boolean'
        
        properties[param_name] = {
            'type': param_type,
            'description': f'{param_name} parameter'
        }
        
        # Check if parameter has default value
        if param.default == inspect.Parameter.empty:
            required.append(param_name)
    
    # Try to extract parameter descriptions from docstring
    if 'Args:' in doc:
        args_section = doc.split('Args:')[1].split('\n\n')[0] if 'Args:' in doc else ''
        for line in args_section.split('\n'):
            line = line.strip()
            if ':' in line:
                param_name = line.split(':')[0].strip()
                param_desc = line.split(':', 1)[1].strip()
                if param_name in properties:
                    properties[param_name]['description'] = param_desc
    
    # Generate function declaration JSON
    declaration = {
        'name': function_name,
        'description': description,
        'parameters': {
            'type': 'object',
            'properties': properties,
            'required': required
        }
    }
    
    print(json.dumps(declaration, indent=2))
    
except Exception as e:
    print(f'Error processing {tool_file}: {e}', file=sys.stderr)
    sys.exit(1)