# DeemixKit Credentials Setup

## Overview

DeemixKit uses a **unified credentials file** to store API keys for services that require authentication. This keeps your sensitive data secure and centralized across all scripts.

**Important**: Deezer does **NOT** require any credentials - it uses a free public API!

---

## 📍 Location

Your credentials file should be located at:

```
~/.config/deemixkit/credentials.json
```

---

## 🔑 Supported Services

### Spotify (Required)

DeemixKit's Spotify features require a Client ID and Client Secret from Spotify's Developer Portal.

**What you need:**
- `client_id` - Your Spotify application's Client ID
- `client_secret` - Your Spotify application's Client Secret

**How to get them:**

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/applications)
2. Click **"Create App"** or **"Log in"** if you're not already logged in
3. Fill in the form:
   - **App name**: DeemixKit (or any name you prefer)
   - **App description**: Music downloader automation
   - **Redirect URI**: http://localhost:8888/callback (this field is required but not used by our scripts)
   - **API/SDK**: Web API
4. Click **"Save"**
5. Copy your **Client ID** and **Client Secret** from the app settings page

### Deezer (Not Required)

Deezer provides a free, public API that doesn't require authentication. No setup needed!

### Last.fm (Optional)

Currently not used by DeemixKit but available for future features.

### YouTube (Optional)

Currently not used by DeemixKit but available for future features.

### Discogs (Optional)

Currently not used by DeemixKit but available for future features.

---

## ⚙️ Setup Instructions

### Step 1: Create the Config Directory

```bash
mkdir -p ~/.config/deemixkit
```

### Step 2: Create the Credentials File

```bash
nano ~/.config/deemixkit/credentials.json
# or use your preferred editor: vim, code, etc.
```

### Step 3: Add Your Credentials

Paste the following into the file:

```json
{
  "spotify": {
    "client_id": "YOUR_SPOTIFY_CLIENT_ID_HERE",
    "client_secret": "YOUR_SPOTIFY_CLIENT_SECRET_HERE"
  }
}
```

Replace the placeholder values with your actual Spotify credentials.

### Step 4: Save and Exit

- If using `nano`: Press `Ctrl+O`, then `Ctrl+X`
- If using `vim`: Press `:wq`
- If using VS Code: Press `Cmd+S`, then `Cmd+Q`

### Step 5: Set Secure Permissions (Recommended)

```bash
chmod 600 ~/.config/deemixkit/credentials.json
```

This makes the file readable and writable only by you.

---

## ✅ Testing Your Setup

Test if your Spotify credentials work:

```bash
# Navigate to DeemixKit directory
cd /path/to/DeemixKit

# Test Spotify resolver
python3 spotify-resolver.py --band "Metallica" --album "Master of Puppets"
```

If successful, you should see:
```
✅ Copied to clipboard: Metallica - Master of Puppets
   https://open.spotify.com/album/...
```

If you see "Spotify API credentials not configured", check:
1. File location is correct: `~/.config/deemixkit/credentials.json`
2. JSON is valid (no syntax errors)
3. Client ID and Secret are correct

---

## 📋 Complete Example File

Here's a complete example of what your `credentials.json` might look like:

```json
{
  "spotify": {
    "client_id": "abc123def456ghi789jkl012mno345pq",
    "client_secret": "678rst901uvw234xyz567abc890def123ghi"
  },
  "lastfm": {
    "api_key": "your_lastfm_api_key",
    "api_secret": "your_lastfm_api_secret"
  },
  "deezer": {
    "api_key": "your_deezer_api_key",
    "api_secret": "your_deezer_api_secret"
  },
  "youtube": {
    "api_key": "your_youtube_api_key"
  },
  "discogs": {
    "consumer_key": "your_discogs_consumer_key",
    "consumer_secret": "your_discogs_consumer_secret",
    "access_token": "your_discogs_access_token",
    "access_secret": "your_discogs_access_secret"
  }
}
```

**Note**: Only include credentials for services you actually use. If you only use Spotify and Deezer, you only need those sections (and Deezer doesn't even require credentials).

---

## 🔒 Security Best Practices

### 1. Never Commit Credentials

The `.gitignore` file in DeemixKit prevents accidental commits:

```
# Credentials and secrets
credentials.json
.env
*.pem
*.key
*_secret.json
*_credentials.json
```

**Never commit** your actual `credentials.json` file!

### 2. Use Example Files

Only commit `credentials.json.example` with placeholder values:

```json
{
  "spotify": {
    "client_id": "your_spotify_client_id_here",
    "client_secret": "your_spotify_client_secret_here"
  }
}
```

### 3. File Permissions

Set restrictive permissions on your credentials file:

```bash
chmod 600 ~/.config/deemixkit/credentials.json
```

This makes the file readable and writable only by you.

### 4. Rotate Credentials

Regularly rotate your API keys for better security:
- Generate new keys every 3-6 months
- Delete old unused keys from Spotify Developer Dashboard
- Update your `credentials.json` file

### 5. Minimal Permissions

When creating your Spotify app:
- Only request necessary permissions
- DeemixKit only needs basic search and read access
- Don't request write or user data permissions

---

## 🌍 Environment Variables (Alternative)

You can also use environment variables instead of a credentials file:

```bash
# Set environment variables
export SPOTIFY_CLIENT_ID="your_client_id"
export SPOTIFY_CLIENT_SECRET="your_client_secret"

# Scripts will automatically use these if credentials.json is not found
```

**Pros**:
- Works well for temporary testing
- Useful in CI/CD environments
- No file to manage

**Cons**:
- Must be set in every terminal session
- Not persistent across reboots
- Less convenient for daily use

**Recommendation**: Use `credentials.json` for permanent setup, environment variables for temporary testing.

---

## 🔧 Script-Specific Config Files

In addition to the unified credentials file, some scripts have their own config files for settings (not credentials):

| Script | Config Location | Purpose |
|---------|-----------------|---------|
| `spotify-resolver.py` | `~/.config/spotify-resolver/config.json` | API credentials, timeout, retries |
| `deezer-resolver.py` | `~/.config/deezer-resolver/config.json` | Timeout, retries, cache settings |
| `discography-resolver.py` | `~/.config/discography-resolver/config.json` | Timeout, retries, user agent |

**Note**: These config files are optional. If they don't exist, scripts use sensible defaults.

---

## ❓ Common Issues

### Issue: "Spotify API credentials not configured"

**Cause**: Credentials file not found or invalid JSON

**Solutions**:
1. Check file exists: `ls ~/.config/deemixkit/credentials.json`
2. Verify JSON is valid: `python3 -m json.tool ~/.config/deemixkit/credentials.json`
3. Check file path: `cat ~/.config/deemixkit/credentials.json`
4. Ensure you're using the home directory shortcut `~`, not `/Users/yourname`

### Issue: "Error loading credentials"

**Cause**: JSON syntax error in credentials file

**Solution**: Validate JSON:
```bash
python3 -m json.tool ~/.config/deemixkit/credentials.json
```

This will show you where the syntax error is.

### Issue: Works in one script but not another

**Cause**: Scripts might be looking in different config directories

**Solution**: Ensure the unified credentials file exists at `~/.config/deemixkit/credentials.json` (not in script-specific directories).

---

## 📚 Additional Resources

- [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/applications)
- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api/)
- [Deezer Developer Portal](https://developers.deezer.com/) (Deezer doesn't require credentials, but documentation is useful)
- [JSON Validator](https://jsonlint.com/) - Validate your JSON online

---

## 💡 Tips

### Quick Edit Command

Create an alias for quick editing:

```bash
# Add to ~/.zshrc or ~/.bash_profile
alias edit-deemix-creds='nano ~/.config/deemixkit/credentials.json'

# Use it anytime
edit-deemix-creds
```

### Backup Your Credentials

Keep a secure backup of your credentials file:

```bash
# Create backup
cp ~/.config/deemixkit/credentials.json ~/.config/deemixkit/credentials.json.backup

# Or use a password manager to store them securely
```

### Multiple Spotify Apps

You can create multiple Spotify apps for different purposes:
- One for personal use (DeemixKit)
- One for development/testing
- Each app gets its own Client ID and Secret

---

## 🆘 Still Having Trouble?

1. **Check the logs**: Python scripts log to `~/.local/log/<script-name>/`
2. **Run with verbose flag**: Add `--verbose` to see detailed error messages
3. **Test credentials manually**: Use curl to test Spotify API directly
4. **Review this guide**: Make sure you followed all steps correctly
5. **Check GitHub issues**: Someone may have solved the same problem

---

**Need help?** Open an issue on GitHub with details about what's not working.
