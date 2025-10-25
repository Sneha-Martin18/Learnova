# Azure SSH Commands to Run

## In the Azure Portal SSH terminal, run these commands:

```bash
# 1. Find where the files are
ls -la /home/site/wwwroot/
ls -la /home/

# 2. Check if files are in a subdirectory
find /home -name "manage.py" 2>/dev/null

# 3. Once you find manage.py, navigate there and run:
cd /path/to/manage.py/directory
python manage.py collectstatic --noinput
```

## Most likely locations:
- `/home/site/wwwroot/`
- `/opt/defaultsite/`
- `/tmp/8de131a66208fde/`

## Quick diagnostic:
```bash
pwd
ls -la
find /home -name "manage.py" -type f 2>/dev/null
```

Copy the output here so I can help you find the correct path.
