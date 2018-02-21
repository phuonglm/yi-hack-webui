## Yi-hack-webui
My scenario: I have 3 Yi ant 720p IP camera and love to use [yi-hack](https://github.com/fritz-smh/yi-hack) firmware with it. The problem is Yi hack doesn't provide any web ui to review and delete the video, the sd card get full pretty fast so I need a background process to pull all video from camera to my NAS and free the sd-card and have the WebUI to review/delete the recorded video.

## Quick Demo:
![Web UI](docs/screen.jpg?raw=true "Yi-Hack-webui")

For player I used videojs and videojs-playlist to view recorded video.
## How to run it
+ Make sure your computer or your NAS device able to run `docker` and `docker-compose`.
+ Clone this repository to your computer or your NAS device.
+ Open `.env.example` file and update variable depend on your config. `CAMERAS` for list of your camera IP, `TELNET_USER` and `TELNET_PASSWORD` for camera root user information. Save that file to `.env`
+ RUN `docker-compose up -d` to start the process in background
+ Access the web ui at `http://localhost:5000`

Note: if you don't want to use docker then the install process will very diffrence depend on your OS. But the minimum requirement is a Linux device with PHP, telnet and lftp installed. You will have to change some code and enviroment variable to relocate the storage of recorded video depend on your device.