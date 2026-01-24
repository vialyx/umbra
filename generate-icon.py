#!/usr/bin/env python3
"""
Simple script to generate an app icon for Umbra
"""

import os
import subprocess

# Create Resources directory
os.makedirs("Resources", exist_ok=True)

# Create a simple iconset
iconset_dir = "Resources/AppIcon.iconset"
os.makedirs(iconset_dir, exist_ok=True)

# Use SF Symbols to create icon images
sizes = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

print("Creating icon images...")

# Create a simple icon using macOS built-in resources
for size, filename in sizes:
    # Use sips to create colored background and overlay lock symbol
    output_path = os.path.join(iconset_dir, filename)
    
    # Create a canvas with gradient background
    cmd = f"""
    python3 -c "
from PIL import Image, ImageDraw
import sys

size = {size}
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Dark purple gradient background
for i in range(size):
    alpha = int(255 * (1 - i/size * 0.3))
    color = (88, 86, 214, alpha)
    draw.ellipse([i*0.1, i*0.1, size-i*0.1, size-i*0.1], fill=color)

# Draw shield shape
shield_inset = size * 0.2
shield_width = size - 2 * shield_inset
shield_height = shield_width * 1.2

# Shield path (simplified)
shield_points = [
    (size/2, shield_inset),
    (size - shield_inset, shield_inset + shield_height * 0.3),
    (size - shield_inset, shield_inset + shield_height * 0.6),
    (size/2, shield_inset + shield_height),
    (shield_inset, shield_inset + shield_height * 0.6),
    (shield_inset, shield_inset + shield_height * 0.3),
]
draw.polygon(shield_points, fill=(255, 255, 255, 230))

# Draw lock symbol
lock_size = size * 0.3
lock_x = size/2 - lock_size/2
lock_y = size/2 - lock_size/3

# Lock body
draw.rectangle([lock_x, lock_y + lock_size/3, lock_x + lock_size, lock_y + lock_size], 
               fill=(88, 86, 214, 255))
# Lock shackle
draw.arc([lock_x + lock_size*0.2, lock_y - lock_size*0.1, 
          lock_x + lock_size*0.8, lock_y + lock_size/3], 
         0, 180, fill=(88, 86, 214, 255), width=int(lock_size*0.1))

img.save('{output_path}')
" 2>/dev/null
    """
    
    # Fallback: just create a colored square if PIL not available
    try:
        subprocess.run(cmd, shell=True, check=False, capture_output=True)
        if not os.path.exists(output_path):
            # Create simple colored square as fallback
            subprocess.run([
                "sips", "-z", str(size), str(size),
                "-s", "format", "png",
                "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns",
                "--out", output_path
            ], capture_output=True)
    except:
        # Ultimate fallback
        subprocess.run([
            "sips", "-z", str(size), str(size),
            "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns",
            "--out", output_path
        ], capture_output=True, check=False)
    
    print(f"  Created {filename}")

# Convert iconset to icns
print("\nConverting to .icns format...")
subprocess.run(["iconutil", "-c", "icns", iconset_dir, "-o", "Resources/AppIcon.icns"], check=True)

print("\n✓ AppIcon.icns created successfully!")
print(f"  Location: {os.path.abspath('Resources/AppIcon.icns')}")

# Cleanup
import shutil
shutil.rmtree(iconset_dir)
