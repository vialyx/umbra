#!/bin/bash

# Create a simple app icon for Umbra using SF Symbols
# This creates an icon from the lock.shield SF Symbol

set -e

echo "🎨 Creating Umbra app icon..."

ICON_DIR="Resources"
ICONSET_DIR="$ICON_DIR/AppIcon.iconset"

mkdir -p "$ICONSET_DIR"

# Create a temporary Swift script to render the icon
cat > /tmp/create_icon.swift << 'SWIFT'
import Cocoa
import AppKit

// Sizes needed for macOS app icon
let sizes: [(size: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

let iconsetPath = CommandLine.arguments[1]

for (size, scale) in sizes {
    let actualSize = CGFloat(size * scale)
    let image = NSImage(size: NSSize(width: actualSize, height: actualSize))
    
    image.lockFocus()
    
    // Background gradient (dark blue to lighter blue)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0),
        NSColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 1.0)
    ])
    let rect = NSRect(x: 0, y: 0, width: actualSize, height: actualSize)
    gradient?.draw(in: rect, angle: 135)
    
    // Draw shield outline
    let shieldPath = NSBezierPath()
    let centerX = actualSize / 2
    let centerY = actualSize / 2
    let shieldWidth = actualSize * 0.6
    let shieldHeight = actualSize * 0.7
    
    // Shield shape
    shieldPath.move(to: NSPoint(x: centerX, y: centerY + shieldHeight / 2))
    shieldPath.line(to: NSPoint(x: centerX - shieldWidth / 2, y: centerY + shieldHeight / 4))
    shieldPath.line(to: NSPoint(x: centerX - shieldWidth / 2, y: centerY - shieldHeight / 6))
    shieldPath.line(to: NSPoint(x: centerX, y: centerY - shieldHeight / 2))
    shieldPath.line(to: NSPoint(x: centerX + shieldWidth / 2, y: centerY - shieldHeight / 6))
    shieldPath.line(to: NSPoint(x: centerX + shieldWidth / 2, y: centerY + shieldHeight / 4))
    shieldPath.close()
    
    // Fill shield with white
    NSColor.white.setFill()
    shieldPath.fill()
    
    // Draw lock symbol
    let lockSize = actualSize * 0.25
    let lockX = centerX - lockSize / 2
    let lockY = centerY - lockSize / 2
    
    // Lock body (rectangle)
    let lockBody = NSBezierPath(roundedRect: 
        NSRect(x: lockX, y: lockY - lockSize * 0.1, width: lockSize, height: lockSize * 0.6),
        xRadius: lockSize * 0.1, yRadius: lockSize * 0.1)
    NSColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0).setFill()
    lockBody.fill()
    
    // Lock shackle (arc)
    let shacklePath = NSBezierPath()
    shacklePath.appendArc(withCenter: NSPoint(x: centerX, y: lockY + lockSize * 0.3),
                          radius: lockSize * 0.3,
                          startAngle: 0,
                          endAngle: 180,
                          clockwise: false)
    shacklePath.lineWidth = lockSize * 0.15
    NSColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0).setStroke()
    shacklePath.stroke()
    
    image.unlockFocus()
    
    // Save as PNG
    if let tiffData = image.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
        let filename = scale == 1 ? "icon_\(size)x\(size).png" : "icon_\(size)x\(size)@\(scale)x.png"
        let filePath = "\(iconsetPath)/\(filename)"
        try? pngData.write(to: URL(fileURLWithPath: filePath))
        print("✓ Created \(filename)")
    }
}

print("✅ Icon images created successfully!")
SWIFT

# Compile and run the Swift script
echo "Generating icon images..."
swiftc -o /tmp/create_icon /tmp/create_icon.swift
/tmp/create_icon "$ICONSET_DIR"

# Convert to .icns
echo "Converting to .icns format..."
iconutil -c icns "$ICONSET_DIR" -o "$ICON_DIR/AppIcon.icns"

# Clean up
rm -rf "$ICONSET_DIR"
rm /tmp/create_icon /tmp/create_icon.swift

echo "✅ AppIcon.icns created at $ICON_DIR/AppIcon.icns"
echo ""
echo "Next steps:"
echo "  1. The icon will be included in the next build"
echo "  2. Rebuild the app: ./test-app.sh"
echo "  3. The icon will appear in notifications and menu bar"
