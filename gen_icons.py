from PIL import Image
import os

src = r'C:\Users\aar25\.gemini\antigravity\brain\694661b5-8d34-4049-a8b4-77b5d25a3030\psx_app_icon_1777628912067.png'
out = r'C:\Users\aar25\Desktop\port\icons'
os.makedirs(out, exist_ok=True)

img = Image.open(src).convert('RGBA')
for size in [72, 96, 128, 144, 152, 192, 384, 512]:
    img.resize((size, size), Image.LANCZOS).save(os.path.join(out, f'icon-{size}.png'))
    print(f'icon-{size}.png saved')
print('All icons done.')
