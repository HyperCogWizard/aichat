#!/usr/bin/env python3

# Tool runner for Python tools
# Usage: run-tool.py <tool_name> <json_args>

import sys
import json
import importlib.util
import os

if len(sys.argv) != 3:
    print('Usage: python run-tool.py <tool_name> <json_args>', file=sys.stderr)
    sys.exit(1)

tool_name = sys.argv[1]
json_args = sys.argv[2]

# Find the tool script
tool_script = os.path.join('tools', f'{tool_name}.py')
if not os.path.exists(tool_script):
    print(f'Tool not found: {tool_script}', file=sys.stderr)
    sys.exit(1)

try:
    # Parse JSON arguments
    args = json.loads(json_args)
    
    # Load the tool module
    spec = importlib.util.spec_from_file_location(tool_name, tool_script)
    tool_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(tool_module)
    
    # Execute the tool
    if hasattr(tool_module, 'run'):
        tool_module.run(**args)
    else:
        print(f'Tool {tool_name} does not have a run function', file=sys.stderr)
        sys.exit(1)
        
except Exception as error:
    print(f'Error executing tool {tool_name}: {error}', file=sys.stderr)
    sys.exit(1)