import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'student_management_system.settings')
import django
django.setup()

from django.conf import settings
print(f"DEBUG: {settings.DEBUG}")
print(f"STATIC_URL: {settings.STATIC_URL}")
print(f"STATIC_ROOT: {settings.STATIC_ROOT}")
print(f"STATICFILES_DIRS: {settings.STATICFILES_DIRS}")

import os
static_root = settings.STATIC_ROOT
if os.path.exists(static_root):
    files = [f for f in os.listdir(static_root) if os.path.isdir(os.path.join(static_root, f))]
    print(f"\nDirectories in staticfiles: {files[:10]}")
    
    # Check for dist directory
    dist_path = os.path.join(static_root, 'dist')
    if os.path.exists(dist_path):
        print("✓ dist/ directory exists")
        css_files = [f for f in os.listdir(os.path.join(dist_path, 'css')) if f.endswith('.css')]
        print(f"CSS files: {css_files}")
    else:
        print("✗ dist/ directory NOT found")
