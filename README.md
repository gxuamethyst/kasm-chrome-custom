# custom kasm chrome

remove audio, gamepad, printer, etc.

this image run at http mode, please reserve proxy by caddy/nginx with https.

## build & run

``` shell
sudo docker build -t ghcr.io/gxuamethyst/kasm-chrome-custom:dev .
# or build with apt mirror
sudo docker build --build-arg USE_APT_MIRROR=true -t ghcr.io/gxuamethyst/kasm-chrome-custom:dev .

sudo docker run --rm  -d --shm-size=512m -p 6901:6901 -e VNC_PW=vncpassword ghcr.io/gxuamethyst/kasm-chrome-custom:dev
```

## reference

* https://github.com/kasmtech/workspaces-core-images
* https://github.com/kasmtech/workspaces-images
