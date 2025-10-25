# How to Run collectstatic on Azure

## Quick Steps

1. **Open Azure Portal**
   - Go to: https://portal.azure.com
   - Sign in with your Azure account

2. **Navigate to Your Web App**
   - Search for "learnova-05594" in the top search bar
   - Click on your web app

3. **Open SSH/Console**
   - In the left menu, scroll down to "Development Tools"
   - Click on **"SSH"** or **"Console"**
   - Wait for the terminal to load (shows a command prompt)

4. **Run These Commands**
   ```bash
   cd /home/site/wwwroot
   python manage.py collectstatic --noinput
   ```

5. **Wait for Completion**
   - You'll see messages like "Copying..." as files are collected
   - Should take 10-30 seconds
   - Look for "X static files copied"

6. **Restart the App**
   - Go back to the Overview page
   - Click **"Restart"** button at the top
   - Wait 30 seconds

7. **Test**
   - Visit: http://learnova-05594.azurewebsites.net
   - The page should now have full styling (colors, buttons, layout)

---

## Alternative: Use Azure CLI (if SSH doesn't work)

```bash
# Open a tunnel
az webapp create-remote-connection --resource-group learnova-rg --name learnova-05594

# In another terminal, when you see the port number (e.g., 42389):
ssh root@127.0.0.1 -p 42389
# Password: Docker!

# Then run:
cd /home/site/wwwroot
python manage.py collectstatic --noinput
exit
```

---

## What This Does

The `collectstatic` command:
- Copies all CSS files from `static/` to `staticfiles/`
- Copies all JavaScript files
- Copies all images and fonts
- WhiteNoise can then serve these files

After this, your login page will have:
- ✅ Blue/white color scheme
- ✅ Styled buttons
- ✅ Proper layout and spacing
- ✅ Icons and fonts

---

## Current Status

- App URL: http://learnova-05594.azurewebsites.net
- Status: Running (unstyled)
- Action: Run collectstatic via Azure Portal SSH
