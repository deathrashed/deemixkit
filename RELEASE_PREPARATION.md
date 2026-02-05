# DeemixKit - Public Release Preparation

## ✅ Changes Made

### 1. Updated Scripts for Portability

All scripts have been updated to use **relative paths** based on their location instead of hardcoded personal paths.

**Files Updated:**
- `deezer-to-deemix.sh`
- `spotify-to-deemix.sh`
- `discography-to-deemix.sh`
- `deezer-to-deemix.applescript`
- `spotify-to-deemix.applescript`
- `discography-to-deemix.applescript`
- `currently-playing-to-deemix.js`

**Before:**
```bash
python3 "/path/to/DeemixKit/deezer-resolver.py"
```

**After:**
```bash
# Bash scripts use:
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/deezer-resolver.py"

# AppleScript uses:
tell application "System Events"
    set scriptPosixPath to POSIX path of (path to me)
end tell
set scriptDir to do shell script "dirname \"" & quoted form of scriptPosixPath & "\""
```

### 2. Removed Hardcoded Credentials

The `currently-playing-to-deemix.js` script now reads credentials from the unified config file instead of having them hardcoded.

**Before:**
```javascript
const CLIENT_ID = "fd98249e14764c1f8183be7f7553bd0e";
const CLIENT_SECRET = "629e21c01c0344528605d2db82ea52ea";
```

**After:**
```javascript
function getCredentials() {
    const configPath = join(homedir(), '.config', 'deemixkit', 'credentials.json');
    const config = JSON.parse(readFileSync(configPath, 'utf8'));
    return {
        clientId: config.spotify.client_id,
        clientSecret: config.spotify.client_secret
    };
}
```

### 3. Created Public Documentation

**New Files:**
- `README_PUBLIC.md` - User-friendly README for public release
- `CREDENTIALS_PUBLIC.md` - Detailed credentials setup guide
- `AGENTS.md` - Developer guide for AI agents

---

## 📋 Pre-Release Checklist

### Before Publishing, Complete These Steps:

- [ ] **Test all scripts** with the updated relative paths:
  ```bash
  cd /path/to/DeemixKit
  ./deezer-to-deemix.sh "Metallica" "Master of Puppets"
  ./spotify-to-deemix.sh "Pink Floyd" "The Wall"
  ./discography-to-deemix.sh "Radiohead" "OK Computer"
  osascript deezer-to-deemix.applescript
  osascript spotify-to-deemix.applescript
  osascript discography-to-deemix.applescript
  node currently-playing-to-deemix.js
  ```

- [ ] **Test credentials system**:
  ```bash
  # Setup credentials
  mkdir -p ~/.config/deemixkit
  nano ~/.config/deemixkit/credentials.json
  # Add your Spotify credentials
  # Test Spotify resolver
  python3 spotify-resolver.py --band "Artist" --album "Album"
  # Test currently-playing script
  node currently-playing-to-deemix.js
  ```

- [ ] **Replace README.md**:
  ```bash
  mv README.md README_ORIGINAL.md
  mv README_PUBLIC.md README.md
  ```

- [ ] **Replace CREDENTIALS.md**:
  ```bash
  mv CREDENTIALS.md CREDENTIALS_ORIGINAL.md
  mv CREDENTIALS_PUBLIC.md CREDENTIALS.md
  ```

- [ ] **Update version info** in scripts (if needed):
  - Check all Python scripts for version numbers
  - Update if this is a new release

- [ ] **Remove personal references** from documentation files:
  - Check for any remaining `/Users/rd/` or `~/Scripts/Riley/Audio/` paths
  - Update all documentation to use generic paths like `/path/to/DeemixKit/`

- [ ] **Verify .gitignore** protects credentials:
  ```bash
  cat .gitignore
  # Should include:
  # credentials.json
  # *_credentials.json
  # *_secret.json
  # .env
  ```

- [ ] **Commit credentials.json.example only**:
  ```bash
  # Make sure credentials.json.example is committed
  git add credentials.json.example
  # Make sure actual credentials.json is NOT committed
  git status  # Should not show credentials.json
  ```

- [ ] **Add LICENSE file** (if not present):
  ```bash
  # Create MIT or other license
  # For personal use projects, MIT is common
  ```

- [ ] **Update GitHub repository settings**:
  - Add description
  - Add topics/keywords: music, deemix, spotify, deezer, automation, macos
  - Add GitHub Releases section if you want to track versions
  - Set repository to Public

- [ ] **Create GitHub Release** (for version 1.0.0 or similar):
  - Tag the release
  - Add release notes
  - Attach any binaries if needed (not needed for this project)

---

## 📝 Documentation Updates Needed

### Files to Review and Update:

1. **All `.md` documentation files**
   - Replace personal paths with generic `/path/to/DeemixKit/`
   - Update examples to show relative paths or `./` syntax

2. **Individual script documentation**
   - Check: `Deezer Resolver.md`, `Spotify Resolver.md`, etc.
   - Update all hardcoded paths

3. **DeemixKit.md** (main overview)
   - Replace personal paths
   - Update installation instructions

---

## 🚀 Post-Release Tasks

After publishing:

- [ ] **Monitor GitHub Issues** for user problems
- [ ] **Respond to user questions**
- [ ] **Consider feature requests**
- [ ] **Update README.md** with common issues discovered
- [ ] **Create a Wiki** for advanced usage patterns
- [ ] **Add a CONTRIBUTING.md** for contributors

---

## ⚠️ Important Notes for Users

### Users Need to Know:

1. **Scripts must be run from their directory** OR be installed with proper permissions

2. **Make scripts executable** (if not already):
   ```bash
   chmod +x *.sh
   chmod +x *.applescript
   chmod +x *.js
   ```

3. **For AppleScript files to work as apps**, users need to:
   - Open Script Editor
   - Copy script content
   - Save as Application
   - This creates a double-clickable .app file

4. **Spotify requires credentials setup** - Deezer does not

5. **macOS only** - AppleScript and System Events are macOS-specific

---

## 🐛 Known Issues to Document

### 1. AppleScript Path Detection

**Issue**: AppleScript's `path to me` may behave differently when:
- Script is run from a symlink
- Script is run from Script Editor
- Script is saved as an application

**Workaround**: Users experiencing issues should:
1. Check that the script file is in the same directory as Python resolvers
2. Run from terminal first to verify paths
3. Check error messages for path issues

### 2. Permission Errors

**Issue**: System Events accessibility permission

**Solution**: Document this in troubleshooting:
- System Preferences → Security & Privacy → Privacy → Accessibility
- Add Terminal or Script Editor
- Grant when prompted

### 3. Deemix Installation Location

**Issue**: Scripts assume Deemix is in a standard location

**Solution**: Users may need to update `paste-to-deemix.applescript` if Deemix is installed elsewhere

---

## 📊 What This Accomplishes

### ✅ Benefits:

1. **No Hardcoded Paths**: Scripts work from any directory
2. **No Personal Info**: All references to personal paths removed
3. **Credential Security**: Proper credential management system
4. **User-Friendly**: Clear setup and usage instructions
5. **Portable**: Clone and use anywhere
6. **Professional**: Public-ready documentation

### 🔄 What Users Get:

- Clean scripts that work out of the box
- Clear instructions for setup
- Proper credential management
- Multiple usage patterns (CLI, GUI, automation)
- Troubleshooting guides

---

## 📞 Support

After release, users may need support on:

1. **Path issues**: Scripts not finding Python files
2. **Permission errors**: AppleScript/System Events
3. **Credential setup**: Spotify API configuration
4. **Platform issues**: macOS-specific features
5. **Integration**: Keyboard Maestro, Raycast, etc.

Prepare FAQ or troubleshooting sections for these.

---

**Good luck with your release! 🎵**
