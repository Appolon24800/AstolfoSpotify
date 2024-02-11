from datetime import datetime
import os
import json
import logging
import re


import dotenv  # pip install dotenv_python
from flask import Flask, redirect, request, url_for, jsonify  # pip install flask[async]
from spotipy import oauth2, Spotify  # pip install spotipy


if not os.path.exists(".env"):
    with open(".env", "w+") as f:
        f.write(
            "# To get SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET\n"
            "# You need to create an application here\n"
            "# https://developer.spotify.com/dashboard\n"
            '# click "Create app"\n'
            '# and set the "Redirect URI" to "http://localhost:3000/callback/"\n'
            '# click "save"\n'
            "# return to the dashboard and click on your app\n"
            "# Click on settings\n"
            '# You can already see the "Client ID"\n'
            '# Click on "View client secret" and its your Client Secret\n'
            "\n"
            "SPOTIFY_CLIENT_ID = Client ID\n"
            "SPOTIFY_CLIENT_SECRET =Client SECRET\n"
            "SPOTIFY_CLIENT_URI = http://localhost:3000/callback/\n"
            "SPOTIFY_SCOPE = user-read-playback-state user-read-currently-playing user-modify-playback-state app-remote-control\n"
            "BACKEND_FLASK_PORT = 3000"
        )

dotenv.load_dotenv()
logging.getLogger("werkzeug").setLevel(logging.ERROR)
os.system("cls")
os.system("title Astolfo backend (Spotify - ChatBridge)")

oldtrack = ""
oldmessage = ""
logfile = rf"C:\Users\{os.getlogin()}\AppData\Roaming\.minecraft\logs\latest.log"
app = Flask("Astolfo Client - Backend (chat_bridge & spotify)")

CLIENT_ID = os.environ.get("SPOTIFY_CLIENT_ID")
CLIENT_SECRET = os.environ.get("SPOTIFY_CLIENT_SECRET")
REDIRECT_URI = os.environ.get("SPOTIFY_CLIENT_URI")
FLASK_PORT = os.environ.get("BACKEND_FLASK_PORT")
SCOPE = os.environ.get("SPOTIFY_SCOPE")

if (
    not CLIENT_ID
    or not CLIENT_SECRET
    or not REDIRECT_URI
    or len(CLIENT_ID) != 32
    or len(CLIENT_SECRET) != 32
    or not "/callback/" in REDIRECT_URI
):
    raise ValueError("Invalid Spotify credentials. Check the '.env' file")

sp_oauth = oauth2.SpotifyOAuth(
    CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, scope=SCOPE, cache_path=".cache"
)


def saveinfo(info):
    with open(".cache", "w+") as f:
        json.dump(info, f)


def getinfo():
    try:
        with open(".cache", "r+") as f:
            return json.load(f)
    except FileNotFoundError:
        saveinfo({})
        return {}


@app.route("/")
async def home():
    return "<a>Astolfo python Backend for 'chat_bridge' and 'spotify'</a> <br> <a href='https://appolon.dev'>Made by appolon</a>"


@app.route("/login")
@app.route("/login/")
async def login():
    return redirect(sp_oauth.get_authorize_url())


@app.route("/callback")
@app.route("/callback/")
async def callback():
    code = request.args.get("code", None)
    info = sp_oauth.get_access_token(code)

    if not code or not info:
        return

    saveinfo(info)
    return f"Success, you can now use the script. URL: 'http://localhost:{FLASK_PORT}/spotify'"


@app.route("/spotify/rewind")
@app.route("/spotify/rewind/")
async def spotify_rewind():
    info = getinfo()
    if not info or "access_token" not in info:
        return redirect(url_for("login"))

    if sp_oauth.is_token_expired(info):
        try:
            new_info = sp_oauth.refresh_access_token(info.get("refresh_token"))
            access_token = new_info["access_token"]
            info["access_token"] = access_token
            info["expires_at"] = new_info["expires_at"]
            saveinfo(info)
            sp = Spotify(auth=access_token)
        except Exception as e:
            return jsonify({"Track": None, "Error": str(e)})
    else:
        sp = Spotify(auth=info["access_token"])

    sp.previous_track()


@app.route("/spotify/skip")
@app.route("/spotify/skip/")
async def spotify_skip():
    global oldtrack
    info = getinfo()

    if not info or "access_token" not in info:
        return redirect(url_for("login"))

    if sp_oauth.is_token_expired(info):
        try:
            new_info = sp_oauth.refresh_access_token(info.get("refresh_token"))
            access_token = new_info["access_token"]
            info["access_token"] = access_token
            info["expires_at"] = new_info["expires_at"]
            saveinfo(info)
            sp = Spotify(auth=access_token)
        except Exception as e:
            return jsonify({"Track": None, "Error": str(e)})
    else:
        sp = Spotify(auth=info["access_token"])

    sp.next_track()


@app.route("/spotify/pause")
@app.route("/spotify/pause/")
async def spotify_pause():
    global oldtrack
    info = getinfo()

    if not info or "access_token" not in info:
        return redirect(url_for("login"))

    if sp_oauth.is_token_expired(info):
        try:
            new_info = sp_oauth.refresh_access_token(info.get("refresh_token"))
            access_token = new_info["access_token"]
            info["access_token"] = access_token
            info["expires_at"] = new_info["expires_at"]
            saveinfo(info)
            sp = Spotify(auth=access_token)
        except Exception as e:
            return jsonify({"Track": None, "Error": str(e)})
    else:
        sp = Spotify(auth=info["access_token"])

    trackinfo = sp.current_playback()

    if trackinfo["is_playing"]:
        sp.pause_playback()
    else:
        sp.start_playback()


@app.route("/spotify")
@app.route("/spotify/")
async def spotify():
    global oldtrack
    info = getinfo()
    if not info or "access_token" not in info:
        return redirect(url_for("login"))

    if sp_oauth.is_token_expired(info):
        try:
            new_info = sp_oauth.refresh_access_token(info.get("refresh_token"))
            access_token = new_info["access_token"]
            info["access_token"] = access_token
            info["expires_at"] = new_info["expires_at"]
            saveinfo(info)
            sp = Spotify(auth=access_token)
        except Exception as e:
            return jsonify({"Track": None, "Error": str(e)})
    else:
        sp = Spotify(auth=info["access_token"])

    trackinfo = sp.current_playback()

    if trackinfo is not None and "item" in trackinfo:
        item = trackinfo.get("item")

        try:
            if oldtrack != item.get("name"):
                print(f"\033[32m[\033[92mSpotify\033[32m]\033[0m '{item.get('name')}' by '{item['artists'][0].get('name')}'")
            oldtrack = item.get("name")
            return jsonify(
                {
                    "Track": item.get("name"),
                    "TrackImage": trackinfo["item"]["album"]["images"][0]["url"],
                    "TrackID": item.get("id"),
                    "Artists": [
                        {
                            "Name": artist.get("name"),
                            "ID": artist.get("id"),
                            "Url": artist["external_urls"]["spotify"],
                        }
                        for artist in item.get("artists")
                    ],
                    "Device": {
                        "Name": trackinfo["device"]["name"],
                        "Volume": trackinfo["device"]["volume_percent"],
                        "Type": trackinfo["device"]["type"],
                    },
                    "Playing": trackinfo["is_playing"],
                    "Duration": item.get("duration_ms"),
                    "Progress": trackinfo.get("progress_ms"),
                }
            )

        except Exception as e:
            return jsonify({"Track": None, "Error": e})
    else:
        return jsonify({"Track": None})


@app.route("/mc_chat", methods=["POST"])
@app.route("/mc_chat/", methods=["POST"])
async def mc_chat():
    global oldmessage
    message = request.args.get("msg")

    if message:
        message = (
            re.sub(r"¥.{3}", "", message).replace("?C%AB", "✫").replace("?6%AC", "-")
        )
        time = datetime.now().strftime("[%H:%M:%S]")

        if oldmessage != message:
            print(f"\033[31m[\033[91mChatBridge\033[31m]\033[0m {message}")

        oldmessage = message

        with open(logfile, "a", encoding="utf-8") as f:
            f.write(f"{time} [Astolfo HTTP Bridge]: [CHAT] {message}\n")

    return ""


if __name__ == "__main__":
    app.run("0.0.0.0", port=FLASK_PORT)
