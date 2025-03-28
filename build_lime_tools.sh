#!/bin/bash
# A simple script to rebuild the lime tools
# Place this script inside lime/8,2,2/ (or your current verison)
# Double click the script to run it 

# Change to the script's own directory
cd "$(dirname "$0")"

# lime rebuild tools
cd tools

haxe tools.hxml

echo "Built lime tools!"
