#!/bin/bash

# Update bundle identifier from com.example.pesticides to a unique one
# Using 'com.sagar.pesticides' as the new bundle identifier

echo "Updating bundle identifier..."

# Update iOS project file
sed -i '' 's/com\.example\.pesticides/com.sagar.pesticides/g' ios/Runner.xcodeproj/project.pbxproj

# Update macOS project file  
sed -i '' 's/com\.example\.pesticides/com.sagar.pesticides/g' macos/Runner.xcodeproj/project.pbxproj

echo "Bundle identifier updated to: com.sagar.pesticides"
echo "Now please configure code signing in Xcode:"
echo "1. In Xcode, select Runner project"
echo "2. Select Runner target"
echo "3. Go to Signing & Capabilities tab"
echo "4. Check 'Automatically manage signing'"
echo "5. Select your Apple ID/Development Team"
echo "6. Build and run" 