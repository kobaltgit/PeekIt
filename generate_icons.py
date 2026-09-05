import os
import math
from PIL import Image, ImageDraw

def create_peekit_icon(size=512):
    # Create image with RGBA
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    pad = size * 0.06
    r = size * 0.22

    # Draw rounded background squircle
    bg_box = [pad, pad, size - pad, size - pad]
    draw.rounded_rectangle(bg_box, radius=r, fill=(15, 23, 42, 255), outline=(56, 189, 248, 255), width=int(size * 0.016))

    # Center coordinates
    cx, cy = size / 2, size / 2

    # Draw eye contour
    eye_w = size * 0.38
    eye_h = size * 0.22
    
    # Top arc
    draw.arc([cx - eye_w, cy - eye_h * 1.5, cx + eye_w, cy + eye_h * 0.9], start=30, end=150, fill=(56, 189, 248, 255), width=int(size * 0.032))
    # Bottom arc
    draw.arc([cx - eye_w, cy - eye_h * 0.9, cx + eye_w, cy + eye_h * 1.5], start=210, end=330, fill=(56, 189, 248, 255), width=int(size * 0.032))

    # Outer pupil dashed circle
    pupil_r = size * 0.14
    draw.ellipse([cx - pupil_r, cy - pupil_r, cx + pupil_r, cy + pupil_r], outline=(129, 140, 248, 255), width=int(size * 0.018))

    # Inner iris filled circle
    iris_r = size * 0.095
    draw.ellipse([cx - iris_r, cy - iris_r, cx + iris_r, cy + iris_r], fill=(14, 165, 233, 255))

    # File document glyph in center of iris
    doc_w = size * 0.08
    doc_h = size * 0.10
    doc_box = [cx - doc_w / 2, cy - doc_h / 2, cx + doc_w / 2, cy + doc_h / 2]
    draw.rounded_rectangle(doc_box, radius=size * 0.015, fill=(255, 255, 255, 255))

    # Folded corner on document
    corner_s = size * 0.03
    draw.polygon([
        (cx + doc_w / 2 - corner_s, cy - doc_h / 2),
        (cx + doc_w / 2, cy - doc_h / 2 + corner_s),
        (cx + doc_w / 2 - corner_s, cy - doc_h / 2 + corner_s)
    ], fill=(186, 230, 253, 255))

    # Spacebar accent underline at bottom
    bar_w = size * 0.22
    bar_h = size * 0.024
    bar_y = size * 0.78
    draw.rounded_rectangle([cx - bar_w / 2, bar_y, cx + bar_w / 2, bar_y + bar_h], radius=bar_h / 2, fill=(96, 165, 250, 255))

    return img

def main():
    icons_dir = os.path.join("src-tauri", "icons")
    os.makedirs(icons_dir, exist_ok=True)

    master = create_peekit_icon(512)
    master.save(os.path.join(icons_dir, "icon.png"), "PNG")
    master.save("icon.png", "PNG")

    sizes = {
        "32x32.png": (32, 32),
        "128x128.png": (128, 128),
        "128x128@2x.png": (256, 256),
    }

    for fname, (w, h) in sizes.items():
        resized = master.resize((w, h), Image.Resampling.LANCZOS)
        resized.save(os.path.join(icons_dir, fname), "PNG")

    # Generate multi-resolution .ico
    ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    ico_images = [master.resize(s, Image.Resampling.LANCZOS) for s in ico_sizes]
    ico_path = os.path.join(icons_dir, "icon.ico")
    ico_images[0].save(ico_path, format="ICO", sizes=ico_sizes)
    ico_images[0].save("icon.ico", format="ICO", sizes=ico_sizes)

    # Dummy icns
    master.save(os.path.join(icons_dir, "icon.icns"), "PNG")
    print("Peekit icons generated successfully!")

if __name__ == "__main__":
    main()
