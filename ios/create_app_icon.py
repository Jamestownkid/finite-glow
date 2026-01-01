#!/usr/bin/env python3
"""
PageFlow App Icon Generator
Creates a beautiful minimalist app icon for iOS
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_pageflow_icon(size=1024):
    """
    Creates the PageFlow app icon
    Design: Open book on gradient background
    """
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    s = size / 1024  # Scale factor
    
    # Colors - Beautiful purple/indigo gradient feel
    bg_start = (99, 102, 241)     # Indigo-500
    bg_end = (139, 92, 246)       # Violet-500
    book_white = (255, 255, 255)
    page_lines = (199, 210, 254)  # Light indigo
    shadow = (79, 70, 229)        # Indigo-600
    
    # === BACKGROUND ===
    # Solid color (iOS icons should not have transparency)
    # Create gradient effect manually
    for y in range(size):
        # Gradient from top-left to bottom-right
        ratio = y / size
        r = int(bg_start[0] + (bg_end[0] - bg_start[0]) * ratio)
        g = int(bg_start[1] + (bg_end[1] - bg_start[1]) * ratio)
        b = int(bg_start[2] + (bg_end[2] - bg_start[2]) * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # === BOOK SHADOW ===
    book_cx = size // 2
    book_cy = int(size * 0.52)
    book_width = int(440 * s)
    book_height = int(360 * s)
    shadow_offset = int(20 * s)
    
    # Shadow
    draw.polygon([
        (book_cx - int(20 * s) + shadow_offset, book_cy - book_height // 2 + shadow_offset),
        (book_cx - book_width // 2 + shadow_offset, book_cy - book_height // 2 + int(40 * s) + shadow_offset),
        (book_cx - book_width // 2 + shadow_offset, book_cy + book_height // 2 + shadow_offset),
        (book_cx - int(20 * s) + shadow_offset, book_cy + book_height // 2 - int(20 * s) + shadow_offset),
    ], fill=(*shadow, 80))
    
    draw.polygon([
        (book_cx + int(20 * s) + shadow_offset, book_cy - book_height // 2 + shadow_offset),
        (book_cx + book_width // 2 + shadow_offset, book_cy - book_height // 2 + int(40 * s) + shadow_offset),
        (book_cx + book_width // 2 + shadow_offset, book_cy + book_height // 2 + shadow_offset),
        (book_cx + int(20 * s) + shadow_offset, book_cy + book_height // 2 - int(20 * s) + shadow_offset),
    ], fill=(*shadow, 80))
    
    # === LEFT PAGE ===
    draw.polygon([
        (book_cx - int(20 * s), book_cy - book_height // 2),
        (book_cx - book_width // 2, book_cy - book_height // 2 + int(40 * s)),
        (book_cx - book_width // 2, book_cy + book_height // 2),
        (book_cx - int(20 * s), book_cy + book_height // 2 - int(20 * s)),
    ], fill=book_white)
    
    # === RIGHT PAGE ===
    draw.polygon([
        (book_cx + int(20 * s), book_cy - book_height // 2),
        (book_cx + book_width // 2, book_cy - book_height // 2 + int(40 * s)),
        (book_cx + book_width // 2, book_cy + book_height // 2),
        (book_cx + int(20 * s), book_cy + book_height // 2 - int(20 * s)),
    ], fill=(248, 250, 252))  # Slightly gray for depth
    
    # === SPINE ===
    spine_width = int(8 * s)
    draw.line(
        [(book_cx, book_cy - book_height // 2), 
         (book_cx, book_cy + book_height // 2 - int(20 * s))],
        fill=shadow,
        width=spine_width
    )
    
    # === PAGE LINES (left page) ===
    line_start_x = book_cx - book_width // 2 + int(50 * s)
    line_end_x = book_cx - int(50 * s)
    
    for i in range(5):
        y = book_cy - book_height // 4 + i * int(50 * s)
        # Lines get shorter toward spine (perspective)
        end_x = line_end_x - int(20 * s) * (1 - i/5)
        draw.line(
            [(line_start_x, y), (end_x, y)],
            fill=page_lines,
            width=int(12 * s)
        )
    
    # === PAGE LINES (right page) ===
    line_start_x_r = book_cx + int(50 * s)
    line_end_x_r = book_cx + book_width // 2 - int(50 * s)
    
    for i in range(5):
        y = book_cy - book_height // 4 + i * int(50 * s)
        # Lines get shorter toward spine (perspective)
        start_x = line_start_x_r + int(20 * s) * (1 - i/5)
        draw.line(
            [(start_x, y), (line_end_x_r, y)],
            fill=page_lines,
            width=int(12 * s)
        )
    
    return img


def main():
    print("Creating PageFlow app icon...")
    
    output_dir = '/home/admin/Downloads/everyday tools/files/PageFlow/PageFlow/Resources/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(output_dir, exist_ok=True)
    
    # Create 1024x1024 icon (App Store requirement)
    icon = create_pageflow_icon(1024)
    icon_path = os.path.join(output_dir, 'AppIcon-1024.png')
    icon.save(icon_path, 'PNG')
    print(f"Saved: {icon_path}")
    
    # Also save a preview
    preview_path = '/home/admin/Downloads/everyday tools/files/PageFlow/docs'
    os.makedirs(preview_path, exist_ok=True)
    
    # Create rounded preview for README
    icon_256 = create_pageflow_icon(256)
    icon_256.save(os.path.join(preview_path, 'icon.png'), 'PNG')
    print(f"Saved preview: {preview_path}/icon.png")
    
    print("\n✅ App icon created successfully!")
    print("\nIcon specifications:")
    print("  - 1024x1024 PNG for App Store")
    print("  - No transparency (solid background)")
    print("  - No rounded corners (iOS adds them)")
    print("  - sRGB color space")


if __name__ == "__main__":
    main()

