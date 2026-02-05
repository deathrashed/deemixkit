import { execSync } from "child_process";
import { readFileSync } from "fs";
import { join } from "path";
import { homedir } from "os";

// Get Spotify credentials from unified config file
function getCredentials() {
    const configPath = join(homedir(), '.config', 'deemixkit', 'credentials.json');
    try {
        const config = JSON.parse(readFileSync(configPath, 'utf8'));
        if (config.spotify?.client_id && config.spotify?.client_secret) {
            return {
                clientId: config.spotify.client_id,
                clientSecret: config.spotify.client_secret
            };
        }
    } catch (err) {
        console.error(`❌ Error reading config file: ${err.message}`);
        console.error(`📁 Expected location: ${configPath}`);
        console.error("\nCreate a credentials file with:");
        console.error('  {\n    "spotify": {\n      "client_id": "your_id",\n      "client_secret": "your_secret"\n    }\n  }');
        console.error("\nSee CREDENTIALS.md for detailed setup instructions.");
        process.exit(1);
    }

    return null;
}

const credentials = getCredentials();

if (!credentials) {
    console.error("❌ Spotify credentials not found!");
    console.error("\nCreate a credentials file at:");
    console.error("  ~/.config/deemixkit/credentials.json");
    console.error("\nWith content:");
    console.error('  {\n    "spotify": {\n      "client_id": "your_id",\n      "client_secret": "your_secret"\n    }\n  }');
    console.error("\nGet credentials from: https://developer.spotify.com/dashboard/applications");
    console.error("\nSee CREDENTIALS.md for detailed setup instructions.");
    process.exit(1);
}

const { clientId: CLIENT_ID, clientSecret: CLIENT_SECRET } = credentials;

// Get access token
function getAccessToken() {
    const response =
        execSync(`curl -s -X POST "https://accounts.spotify.com/api/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}"`);
    return JSON.parse(response.toString()).access_token;
}

// Get current track info
const applescriptTrack = `
tell application "Spotify"
  if player state is playing then
    set trackName to name of current track
    set artistName to artist of current track
    return trackName & "|||" & artistName
  else
    return "No song playing"
  end if
end tell
`;

let songInfo = execSync(`osascript -e '${applescriptTrack}'`).toString().trim();
if (songInfo === "No song playing") {
    console.error("🎵 No song is currently playing.");
    process.exit(0);
}

const [track, artist] = songInfo.split("|||");
const query = encodeURIComponent(`${track} artist:${artist}`);
const token = getAccessToken();
const searchUrl = `https://api.spotify.com/v1/search?q=${query}&type=track&limit=1`;

const response = execSync(
    `curl -s -H "Authorization: Bearer ${token}" "${searchUrl}"`
);
const trackData = JSON.parse(response.toString())?.tracks?.items?.[0];

if (!trackData || !trackData.album) {
    console.error("⚠️ Could not find album info.");
    process.exit(1);
}

const albumLink = trackData.album.external_urls.spotify;
execSync(`printf '${albumLink}' | pbcopy`);

// AppleScript to paste into Deemix
const pasteScript = `
tell application "System Events"
  set isRunning to false
  set appList to (get name of every process)
  if appList contains "Deemix" then set isRunning to true
end tell

if isRunning is false then
  tell application "Deemix" to activate
  delay 1
end if

tell application "Deemix" to activate
delay 0.5

tell application "System Events"
	keystroke "v" using command down
	delay 0.1
	key up command
	delay 3.5
	keystroke "h" using command down
end tell
`;

execSync(`osascript -e '${pasteScript}'`);

console.log(`🫟 🫟 🫟 🫟 🫟`);
