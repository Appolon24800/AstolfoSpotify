# Astolfo spotify player
### A simple spotify player for [[Astolfo client]](https://astolfo.lgbt) in lua with [[zarscript2]](https://zarzel.gitbook.io/) and [[Flask]](https://flask.palletsprojects.com/)

## How to use?: 
- Download the file ```backend.exe```, you can probably rewrite it for Linux / MacOS but Astolfo client only support windows.
- Run it and open the ```.env``` file
- Now, for the configuration of ```.env```, check this [[How to setup the spotify application?]](https://github.com/Appolon24800/AstolfoSpotify#how-to-setup-the-spotify-application)

## I don't want to use the compiled version:
- If you don't want to use the compiled build, you can still use the source.
- For that, you need to install python and pip
- After that, open the CMD (window + R and type ```cmd.exe```)
- You will have to execute some commands now:
    - ```pip install flask[async]```
    - ```pip install dotenv_python```
    - ```pip install spotipy```
 
## And now that the backend is running?:
- Install the "Spotify.lua" script and put it here: ```C:\Users\<Username>\AppData\Roaming\astolfo\scripts\```
- Reload the scripts and enable it.
- If the backend is running, you installed and enabled the script but nothing is appening you need to enable unsafe functions:
- In the chat send this message: ```.scripts unsafe```
 
## I want to use this script on another client:
- You can rewrite the script for Moon client with [Moon client scripting api](https://docs.moonclient.xyz/)
- You can rewrite the script for Rise client with [Rise client scripting api](https://riseclients-organization.gitbook.io/rise-6-scripting-api/api-documentation/scripting-metadata)

## Commands:
- @pause (soon)
- @skip (soon)
- @trackurl --> send the spotify url of the song in the chat
- @artisturl --> send the spotify url of the artist in the chat
- @song --> send ```I am listening to "track" by "artistsName"```
- @artist --> send the artist name in the chat
- @track --> send the song name in the chat

## How to setup the spotify application?:
- You will need to create a spotify application [[here]](https://developer.spotify.com/dashboard)
- Login into your spotify account and click "Create an app"
- Set "Redirect URI" to "http://localhost:3000/callback/"
- Save everything and copy the Client ID
- Click on "View client secret" and now you can copy the Client Secret
- **REMEMBER THAT** anyone that have access to this file can skip, pause and have access to your name / email address so keep it private
![qz5k6lbu](https://github.com/Appolon24800/AstolfoSpotify/assets/93398824/bb552429-2dc1-485d-a153-675e822e84bb)

## I used:
- [[PyInstaller]](https://pyinstaller.org/) *to compile the file*
- [[UPX]](https://upx.github.io/) *to compress the executable*
- [[chat_bridge]](https://www.astolfo.lgbt/forums/topic/14077-astolfo-overlay-log-server/) *original by [malwarekat](https://www.astolfo.lgbt/forums/profile/33787-malwarekat/)*

## Some photos
![2](https://github.com/Appolon24800/AstolfoSpotify/assets/93398824/98fe2900-f2b8-420b-848a-b6ca7c01fbae)
![1](https://github.com/Appolon24800/AstolfoSpotify/assets/93398824/3aa1f512-87bd-4c04-8e88-2633a5ea6e5a)
![3](https://github.com/Appolon24800/AstolfoSpotify/assets/93398824/03d1f27e-b14d-47c9-84d2-44566731de7a)
![4](https://github.com/Appolon24800/AstolfoSpotify/assets/93398824/330a6266-2f5a-4cab-8d84-e32dec779c9a)


