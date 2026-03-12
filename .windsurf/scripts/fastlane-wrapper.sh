#!/bin/bash
# Fastlane Wrapper Script
# This script ensures Fastlane is only run from project android directories

# Check if lane name is provided
if [ -z "$1" ]; then
    echo "❌ Error: No lane name provided"
    echo ""
    echo "Usage: ./fastlane-wrapper.sh [lane_name]"
    echo ""
    echo "Example:"
    echo "  ./fastlane-wrapper.sh validate"
    echo "  ./fastlane-wrapper.sh deploy_production"
    exit 1
fi

LANE=$1

# Check if we're in a project's android directory
CURRENT_DIR=$(basename "$PWD")
HAS_FASTLANE_DIR=false

if [ -d "fastlane" ]; then
    HAS_FASTLANE_DIR=true
fi

# Check if we're in an android directory
if [ "$CURRENT_DIR" != "android" ] || [ "$HAS_FASTLANE_DIR" = false ]; then
    echo "❌ Error: Fastlane must be run from a project's android directory"
    echo ""
    echo "Current directory: $PWD"
    echo ""
    echo "Please navigate to a project's android directory:"
    echo "  cd unit_converter/android"
    echo "  fastlane [lane_name]"
    echo ""
    echo "Or use this wrapper from the project root:"
    echo "  cd unit_converter"
    echo "  ../.windsurf/scripts/fastlane-wrapper.sh [lane_name]"
    exit 1
fi

# Run Fastlane with the specified lane
echo "🚀 Running Fastlane lane: $LANE"
fastlane "$@"