#!/bin/bash

# --------------------------------------------------------------------------
# Universal Shell Script to Build and Upload Android APK to Appetize.io
#
# This script automates the process of taking an Android APK built from
# your project and uploading it to Appetize.io for browser-based testing.
# It replaces the Gitpod-specific 'Appetize info' task logic.
#
# Prerequisites:
# - curl: For making HTTP requests to the Appetize API.
# - jq: For parsing JSON responses from the Appetize API.
# - APPETIZE_API_TOKEN environment variable set with your Appetize token.
#   (Get it from https://appetize.io/docs#request-api-token)
# - An Android APK file built by your project.
# --------------------------------------------------------------------------

# --- Configuration ---

# Your Appetize.io API token. Set this as an environment variable before running.
# Example: export APPETIZE_API_TOKEN="YOUR_TOKEN_HERE"
# Or: APPETIZE_API_TOKEN="YOUR_TOKEN_HERE" ./upload_to_appetize.sh
# Check if the token is set later in the script.

# The path to your Android APK file relative to the directory from which you run the script.
# Default assumes a standard Flutter build output location for a release APK.
# Adjust this path if your build process outputs to a different location or name (e.g., app-debug.apk).
# Common paths:
# - Flutter: build/app/outputs/flutter-apk/app-release.apk
# - Native Android Studio: app/build/outputs/apk/release/app-release.apk
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

# Appetize API base URL (without authentication part)
# This is used to construct the authenticated URL later.
APPETIZE_API_BASE_URL="https://api.appetize.io/v1/apps"

# Appetize embed base URL
APPETIZE_EMBED_URL="https://appetize.io/embed"

# Default device for the embed URL (can be adjusted)
APPETIZE_DEFAULT_DEVICE="pixel4" # e.g., nexus5x, pixel4, ipad-pro

# Whether to autoplay the session in the embed URL
APPETIZE_AUTOPLAY="true" # true or false

# --- Script Logic ---

# Clear screen (optional, remove if not desired in your environment)
# Note: This specific command might behave differently across terminals.
# printf "\033[3J\033c\033[3J"

echo "--- Appetize.io Upload Script ---"

# Check for required commands: curl and jq
if ! command -v curl &> /dev/null; then
    echo "ERROR: 'curl' command not found."
    echo "Please install curl (e.g., 'sudo apt-get update && sudo apt-get install curl')."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "ERROR: 'jq' command not found."
    echo "Please install jq (e.g., 'sudo apt-get update && sudo apt-get install jq' or 'brew install jq')."
    exit 1
fi

# Check if the API token is set
if [ -z "$APPETIZE_API_TOKEN" ]; then
    echo "ERROR: APPETIZE_API_TOKEN environment variable is not set."
    echo "Please set it before running the script, for example:"
    echo "export APPETIZE_API_TOKEN=\"YOUR_TOKEN_HERE\""
    echo "You can request your token here: https://appetize.io/docs#request-api-token"
    exit 1
fi

# Check if the APK file exists at the specified path
if [ ! -f "$APK_PATH" ]; then
    echo "ERROR: APK file not found at '$APK_PATH'."
    echo "Please ensure your Android app is built (e.g., run 'flutter build apk' or your native build command)."
    echo "Also, verify the 'APK_PATH' variable in the script is correct."
    exit 1
fi

echo "INFO: Found APK file: $APK_PATH"
echo "INFO: Uploading APK to Appetize.io..."

# Construct the base authenticated API URL: https://<token>@api.appetize.io/v1/apps
AUTH_API_URL="https://$APPETIZE_API_TOKEN@api.appetize.io/v1/apps"

# Determine the final upload target URL
UPLOAD_TARGET_URL="$AUTH_API_URL"
# Check if APPETIZE_PUBLICKEY is already set from a previous upload or environment
if [ -n "$APPETIZE_PUBLICKEY" ]; then
    # If public key exists, append it to the authenticated base URL for update
    UPLOAD_TARGET_URL="$AUTH_API_URL/$APPETIZE_PUBLICKEY"
    echo "INFO: Using existing APPETIZE_PUBLICKEY '$APPETIZE_PUBLICKEY' for update."
else
    echo "INFO: No existing APPETIZE_PUBLICKEY found. Uploading as a new app."
fi

# Perform the upload using curl
# -sS: Silent but show errors
# --http1.1: Use HTTP/1.1 as requested in the original Gitpod config (though often not strictly necessary)
# Use the correctly constructed UPLOAD_TARGET_URL with the token embedded.
UPLOAD_RESPONSE=$(curl -sS --http1.1 "$UPLOAD_TARGET_URL" \
    -F "file=@$APK_PATH" \
    -F platform=android \
    -F "buttonText=Start App" \
    -F "postSessionButtonText=Start App")

UPLOAD_STATUS=$? # Capture the exit status of the curl command

if [ $UPLOAD_STATUS -ne 0 ]; then
    echo "ERROR: Curl upload failed with status $UPLOAD_STATUS."
    echo "Response from Appetize API: $UPLOAD_RESPONSE"
    # If response is empty or not valid JSON, print raw output for debugging
    if [ -z "$UPLOAD_RESPONSE" ] || ! echo "$UPLOAD_RESPONSE" | jq empty &> /dev/null; then
        echo "Raw response (might not be JSON or empty):"
        echo "$UPLOAD_RESPONSE"
    fi
    exit 1
fi

# Parse the JSON response to get the new public key
# -r: raw output (removes quotes)
NEW_PUBLICKEY=$(echo "$UPLOAD_RESPONSE" | jq -r '.publicKey')
JQ_STATUS=$? # Capture the exit status of the jq command

# Check if jq succeeded and the public key was extracted
if [ $JQ_STATUS -ne 0 ] || [ -z "$NEW_PUBLICKEY" ] || [ "$NEW_PUBLICKEY" == "null" ]; then
    echo "ERROR: Failed to parse public key from Appetize response."
    echo "Response from Appetize API: $UPLOAD_RESPONSE"
    echo "jq exit status: $JQ_STATUS"
    echo "Extracted key: '$NEW_PUBLICKEY'"
    # Attempt to parse the response more loosely to see if it's an API error message
    ERROR_MESSAGE=$(echo "$UPLOAD_RESPONSE" | jq -r '.error // .message // empty')
    if [ -n "$ERROR_MESSAGE" ]; then
        echo "Appetize API error message: $ERROR_MESSAGE"
    fi
    exit 1
fi

# Export the new public key. This makes it available in the current shell session
# and for any child processes launched from this script or subsequently in the same shell.
# Note: 'export' only affects the current shell and its children.
# If you are in Gitpod and need it persisted across terminal sessions or prebuilds,
# you might need to use 'gp env'. For a universal script, 'export' is the standard way.
export APPETIZE_PUBLICKEY="$NEW_PUBLICKEY"

echo "SUCCESS: APK uploaded successfully."
echo "INFO: Appetize Public Key: $APPETIZE_PUBLICKEY"

# Construct the Appetize embed URL
EMBED_URL="$APPETIZE_EMBED_URL/$APPETIZE_PUBLICKEY?device=$APPETIZE_DEFAULT_DEVICE&autoplay=$APPETIZE_AUTOPLAY"

echo ""
echo "--- Test Your App ---"
echo "INFO: Open the following URL in your web browser to test your app on Appetize.io:"
echo "$EMBED_URL"
echo "-------------------"
echo ""

exit 0