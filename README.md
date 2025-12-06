# custom kasm chrome

remove audio, gamepad, printer, etc.

this image run at http mode, please reserve proxy by caddy/nginx with https.

## build & run

``` shell
sudo docker build -t gxuamethyst/core-ubuntu-focal:develop -f dockerfile-kasm-core .

sudo docker build -t gxuamethyst/kasm-chrome:dev -f dockerfile-kasm-chrome .

sudo docker run --rm  -d --shm-size=512m -p 6901:6901 -e VNC_PW=vncpassword gxuamethyst/kasm-chrome:dev
```
