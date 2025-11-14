#!/bin/bash

# -----------------------------
# Flutter Web Post-Build Script
# Author: Harly George (optimized by ChatGPT)
# -----------------------------

# Check if client name provided
if [ -z "$1" ]; then
  echo "❌ Please provide a client folder name."
  echo "👉 Example: bash post_build_web.sh client1"
  exit 1
fi

CLIENT_NAME=$1
BUILD_DIR="build/web"

echo "🚀 Starting Flutter web build for client: ${CLIENT_NAME}"

# Step 1: Build the Flutter web app
flutter build web --release --base-href "/${CLIENT_NAME}/"

# Step 2: Verify build output
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Build failed or folder not found."
  exit 1
fi

# Step 3: Update <base href> tag inside index.html (safety fix)
echo "🧩 Updating base href to /${CLIENT_NAME}/"
sed -i "" "s|<base href=\"/\">|<base href=\"/${CLIENT_NAME}/\">|" "${BUILD_DIR}/index.html" 2>/dev/null || \
sed -i "s|<base href=\"/\">|<base href=\"/${CLIENT_NAME}/\">|" "${BUILD_DIR}/index.html"

# Step 4: Copy firebase-messaging-sw.js to build directory
if [ -f "firebase-messaging-sw.js" ]; then
  cp firebase-messaging-sw.js "${BUILD_DIR}/firebase-messaging-sw.js"
  echo "✅ firebase-messaging-sw.js copied successfully"
else
  echo "⚠️  firebase-messaging-sw.js not found in project root. Please ensure it's there."
fi

# Step 5: Create client-specific output folder
OUTPUT_DIR="deploy/${CLIENT_NAME}"
mkdir -p "${OUTPUT_DIR}"

# Step 6: Copy build to output folder
cp -r ${BUILD_DIR}/* "${OUTPUT_DIR}/"

echo "🎉 Web build ready for deployment at: ${OUTPUT_DIR}"
echo "📂 Upload this folder to your Hostinger subdirectory: /${CLIENT_NAME}/"
