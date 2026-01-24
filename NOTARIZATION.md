# Umbra Notarization Guide

This guide will walk you through notarizing Umbra for distribution outside the Mac App Store.

## Prerequisites

1. **Apple Developer Account** (You have this ✓)
2. **Developer ID Application Certificate**
3. **Developer ID Installer Certificate**
4. **App-specific password** for notarization

## Step 1: Install Developer ID Certificates

1. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click the **+** button to create a new certificate
3. Select "Developer ID Application" and follow the prompts
4. Download and install the certificate by double-clicking it
5. Repeat for "Developer ID Installer" certificate

## Step 2: Get Your Team ID

```bash
# Find your Team ID
security find-identity -v -p codesigning
```

Look for entries like "Developer ID Application: Your Name (TEAM_ID)"
Save your TEAM_ID for later.

## Step 3: Create App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple ID
3. Go to "Security" → "App-Specific Passwords"
4. Click "Generate an app-specific password"
5. Name it "Umbra Notarization"
6. Save the password securely

## Step 4: Store Credentials in Keychain

```bash
# Store notarization credentials
xcrun notarytool store-credentials "umbra-notarize" \
  --apple-id "your-apple-id@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "your-app-specific-password"
```

## Step 5: Update build-installer.sh

The build script needs to be updated to sign and notarize. Here's what to change:

```bash
# Set these variables at the top of build-installer.sh:
DEVELOPER_ID_APP="Developer ID Application: Your Name (TEAM_ID)"
DEVELOPER_ID_INSTALLER="Developer ID Installer: Your Name (TEAM_ID)"
NOTARIZATION_PROFILE="umbra-notarize"

# Replace the ad-hoc signing section with:
echo -e "${GREEN}Signing application with Developer ID...${NC}"
codesign --force --deep \
         --sign "$DEVELOPER_ID_APP" \
         --options runtime \
         --entitlements Entitlements.plist \
         --timestamp \
         "$APP_DIR"

# After creating the PKG, add notarization:
echo -e "${GREEN}Signing installer...${NC}"
productsign --sign "$DEVELOPER_ID_INSTALLER" \
            "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}-unsigned.pkg" \
            "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}.pkg"

echo -e "${GREEN}Submitting for notarization...${NC}"
xcrun notarytool submit "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}.pkg" \
                        --keychain-profile "$NOTARIZATION_PROFILE" \
                        --wait

echo -e "${GREEN}Stapling notarization ticket...${NC}"
xcrun stapler staple "$RELEASE_DIR/${PROJECT_NAME}-${VERSION}.pkg"
```

## Step 6: Create Entitlements.plist

Create a file `Entitlements.plist` in the root directory:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.bluetooth</key>
    <true/>
    <key>com.apple.security.device.bluetooth</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <false/>
</dict>
</plist>
```

## Step 7: Build and Notarize

```bash
# Build the notarized installer
./Installer/build-installer.sh
```

The script will:
1. Build the app
2. Sign it with hardened runtime
3. Create the PKG
4. Sign the PKG
5. Submit for notarization (this takes 1-5 minutes)
6. Staple the notarization ticket

## Step 8: Verify Notarization

```bash
# Check app signature
codesign -dvv release/Umbra.app

# Check PKG signature
pkgutil --check-signature release/Umbra-1.0.4.pkg

# Verify notarization
spctl -a -vv -t install release/Umbra-1.0.4.pkg
```

You should see "accepted" in the output.

## Troubleshooting

### Notarization Failed?

Check the detailed log:
```bash
xcrun notarytool log <submission-id> \
                     --keychain-profile umbra-notarize
```

Common issues:
- **Missing entitlements**: Add required entitlements to Entitlements.plist
- **Unsigned dependencies**: Ensure all frameworks are signed
- **Wrong certificate**: Double-check you're using Developer ID, not Mac App Distribution

### Re-submit After Fixes

```bash
# Just run the build script again
./Installer/build-installer.sh
```

## Distribution

Once notarized, you can:
1. Upload to GitHub Releases ✓
2. Host on your website
3. Distribute via DMG or PKG

Users will be able to open Umbra without any warnings!

## Quick Reference Commands

```bash
# List certificates
security find-identity -v -p codesigning

# Check signature
codesign -dvv path/to/app

# Submit for notarization
xcrun notarytool submit file.pkg --keychain-profile umbra-notarize --wait

# Get notarization history
xcrun notarytool history --keychain-profile umbra-notarize

# Staple ticket
xcrun stapler staple file.pkg

# Verify
spctl -a -vv -t install file.pkg
```

## Next Steps

Once you have your certificates:
1. Update `NOTARIZATION.md` with your Team ID
2. Update `build-installer.sh` with your certificate names
3. Run `./Installer/build-installer.sh`
4. The notarized PKG will be in `release/Umbra-1.0.4.pkg`

