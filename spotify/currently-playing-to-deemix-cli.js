import { execSync } from "child_process";
import { readFileSync } from "fs";
import { join } from "path";
import { homedir } from "os";
import { dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const DEEMIXKIT_PATH = dirname(__dirname);

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
        process.exit(1);
    }
    return null;
}

const credentials = getCredentials();
if (!credentials) {
    console.error("❌ Spotify credentials not found!");
    process.exit(1);
}

const { clientId: CLIENT_ID, clientSecret: CLIENT_SECRET } = credentials;

// Get access token
function getAccessToken() {
    const response = execSync(`curl -s -X POST "https://accounts.spotify.com/api/token" \
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
console.log(`🎵 Found: ${trackData.album.name} by ${trackData.album.artists[0].name}`);
console.log(`🔗 ${albumLink}`);
console.log("📥 Downloading...");

// Download via CLI
try {
    execSync(`"${DEEMIXKIT_PATH}/scripts/deemix-download.sh" "${albumLink}"`, {
        stdio: "inherit"
    });
    console.log("✅ Download complete!");
} catch (err) {
    console.error("❌ Download failed");
    process.exit(1);
}
