#!/bin/bash

# Script to toggle h3_flutter/bindings/h3lib between symlink and directory
# Usage: ./toggle_h3lib.sh

set -e  # Exit on any error

cd "$(cd "$(dirname "$0")" > /dev/null && pwd)/../../.."

# Define paths
TARGET_DIR="h3_flutter/bindings/h3lib"
SOURCE_DIR="h3_ffi/c/h3/src/h3lib"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}H3lib Toggle Script${NC}"
echo "===================="

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory '$SOURCE_DIR' does not exist!${NC}"
    exit 1
fi

# Check if target exists
if [ ! -e "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target '$TARGET_DIR' does not exist!${NC}"
    exit 1
fi

# Check current state and toggle
if [ -L "$TARGET_DIR" ]; then
    # Current state: symlink -> change to directory
    echo -e "Current state: ${GREEN}SYMLINK${NC}"
    echo -e "Switching to: ${GREEN}DIRECTORY${NC}"
    
    # Remove symlink
    rm "$TARGET_DIR"
    
    # Copy the directory
    cp -r "$SOURCE_DIR" "$TARGET_DIR"

    echo -e "${GREEN}✓ Successfully switched to directory${NC}"
    
elif [ -d "$TARGET_DIR" ]; then
    # Current state: directory -> change to symlink
    echo -e "Current state: ${GREEN}DIRECTORY${NC}"
    echo -e "Switching to: ${GREEN}SYMLINK${NC}"
    
    # Remove directory
    rm -rf "$TARGET_DIR"
    
    # Create symlink
    # Use relative path for better portability
    RELATIVE_SOURCE="../../h3_ffi/c/h3/src/h3lib"
    ln -s "$RELATIVE_SOURCE" "$TARGET_DIR"
    
    echo -e "${GREEN}✓ Successfully switched to symlink${NC}"
    
else
    echo -e "${RED}Error: '$TARGET_DIR' is neither a directory nor a symlink!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Toggle complete!${NC}"

# Show current state
if [ -L "$TARGET_DIR" ]; then
    echo -e "Current state: ${GREEN}SYMLINK${NC} -> $(readlink "$TARGET_DIR")"
else
    echo -e "Current state: ${GREEN}DIRECTORY${NC}"
fi 