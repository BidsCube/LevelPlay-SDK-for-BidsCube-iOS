#!/bin/bash

# Script to update version across all files
# Usage: ./scripts/update-version.sh 1.2.3

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.2.3"
    exit 1
fi

echo "Updating version to $VERSION..."

# Update podspec
if [ -f "BidscubeSDK.podspec" ]; then
    sed -i.bak "s/spec.version.*=.*/spec.version      = \"$VERSION\"/" BidscubeSDK.podspec
    rm -f BidscubeSDK.podspec.bak
    echo "✅ Updated BidscubeSDK.podspec"
fi

# Update package.json if it exists
if [ -f "package.json" ]; then
    # Use node to update package.json properly
    node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.version = '$VERSION';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
    "
    echo "✅ Updated package.json"
fi

# Update SDK version constant
CONSTANTS="Sources/BidscubeSDK/Core/Constants.swift"
if [ -f "$CONSTANTS" ]; then
    sed -i.bak "s/public static let sdkVersion = \".*\"/public static let sdkVersion = \"$VERSION\"/" "$CONSTANTS"
    rm -f "$CONSTANTS.bak"
    echo "✅ Updated $CONSTANTS"
fi

# LevelPlay adapter reported version (keep aligned with podspec / tag)
MANIFEST="Sources/LevelPlayMediationBidscubeAdapter/LevelPlayMediationBidscubeAdapterManifest.swift"
if [ -f "$MANIFEST" ]; then
    sed -i.bak "s/public static let adapterVersion = \".*\"/public static let adapterVersion = \"$VERSION\"/" "$MANIFEST"
    rm -f "$MANIFEST.bak"
    echo "✅ Updated $MANIFEST (adapterVersion)"
fi

# Podspecs
if [ -f "LevelPlayMediationBidscubeAdapter.podspec" ]; then
    sed -i.bak "s/spec.version.*=.*/spec.version      = \"$VERSION\"/" LevelPlayMediationBidscubeAdapter.podspec
    rm -f LevelPlayMediationBidscubeAdapter.podspec.bak
    echo "✅ Updated LevelPlayMediationBidscubeAdapter.podspec"
fi

# Update changelog in README.md
if [ -f "README.md" ]; then
    # Add new version entry to changelog
    sed -i.bak "/## Changelog/a\\
\\
### Version $VERSION\\
- Automated release via GitHub Actions\\
- Bug fixes and improvements\\
" README.md
    rm -f README.md.bak
    echo "✅ Updated README.md changelog"
fi

echo "🎉 Version $VERSION updated successfully!"
echo ""
echo "Next steps:"
echo "1. Review the changes: git diff"
echo "2. Commit the changes: git add . && git commit -m \"Update to version: v$VERSION\""
echo "3. Create and push tag: git tag v$VERSION && git push origin v$VERSION"