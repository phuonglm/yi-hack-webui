## Yi-hack-webui
My scenario: I have 3 Yi ant 720p IP camera and love to use [yi-hack](https://github.com/fritz-smh/yi-hack) firmware with it. The problem is Yi hack doesn't provide any web ui to review and delete the video, the sd card get full pretty fast so I need a background process to pull all video from camera to my NAS and free the sd-card and have the WebUI to review/delete the recorded video.

## Quick Demo:
![Web UI](docs/screen.jpg?raw=true "Yi-Hack-webui")

For player I used videojs and videojs-playlist to view recorded video.
## How to run it

### From Linux machine with docker and docker compose install

+ Make sure your computer or your NAS device able to run `docker` and `docker-compose`.
+ Clone this repository to your computer or your NAS device.
+ Open `.env.example` file and update variable depend on your config. `CAMERAS` for list of your camera IP, `TELNET_USER` and `TELNET_PASSWORD` for camera root user information. Save that file to `.env`
+ RUN `docker-compose up -d` to start the process in background
+ Access the web ui at `http://localhost:5000`

### From device with docker install
+ Use this command to start our container from image
```
docker run -d \
    --name yi-hack-webui  \
    -p 5000:80/tcp \
    -v "<your_video_storage_path>:/var/www/app/data" \
    -e TELNET_USER="root" -e TELNET_PASSWORD="telnet_password" -e CAMERAS="192.168.1.100 192.168.1.101" \
    -e TIME_ZONE="Asia/Ho_Chi_Minh" -e NTP_SERVER="192.168.1.1" \
    -e DOWNLOAD_INVERVAL=300 -e DATA_PATH="/var/www/app/data/" \
    --memory=60m --restart=unless-stopped \
    phuonglm/yi-hack-webui:latest
```
+ Access the web ui at `http://localhost:5000`

### Note
+ The record download script is only support yi-hack 720p, For other camera please add enviroment variable `CUSTOM_SCRIPT_192_168_1_10=http://url/custom_download_script_for_your_camera.sh`, the crontask will run your script instead of default yi-hack720 script. 
+ For some device like Pi, NAS with ARM CPU, please use `phuonglm/yi-webui:arm32v6-latest` or `phuonglm/yi-webui:arm64v8-latest` instead.
+ If you don't want to use docker then the install process will very diffrence depend on your OS. But the minimum requirement is a Linux device with PHP, telnet and lftp installed. You will have to change some code and enviroment variable to relocate the storage of recorded video depend on your device.
