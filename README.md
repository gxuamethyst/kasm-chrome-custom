# About This Image

# Build

``` shell
sudo docker build -t gxuamethyst/core-ubuntu-noble:develop -f dockerfile-kasm-chrome .

sudo docker build -t gxuamethyst/kasm-chrome:dev -f dockerfile-kasm-chrome .

sudo docker run --rm  -it --shm-size=512m -p 6901:6901 gxuamethyst/kasm-chrome:dev
```

# Environment Variables

* `LAUNCH_URL` - The default URL the browser launches to when created.
* `APP_ARGS` - Additional arguments to pass to the browser when launched.
* `KASM_RESTRICTED_FILE_CHOOSER` - Confine "File Upload" and "File Save"
  dialogs to ~/Desktop. On by default.
