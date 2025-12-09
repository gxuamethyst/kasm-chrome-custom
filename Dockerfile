#### Build Stage ####
ARG BASE_IMAGE="ubuntu:20.04"
FROM $BASE_IMAGE AS base_layer

### Environment config
ARG BG_IMG=bg_kasm.png
ARG EXTRA_SH=noop.sh
ARG DISTRO=ubuntu
ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'
ARG LC_ALL='en_US.UTF-8'
ARG TZ='Etc/UTC'
ARG USE_APT_MIRROR='false'

ENV DEBIAN_FRONTEND=noninteractive \
    DISTRO=$DISTRO \
    HOME=/home/kasm-default-profile \
    INST_SCRIPTS=/dockerstartup/install \
    KASM_VNC_PATH=/usr/share/kasmvnc \
    LANG=$LANG \
    LANGUAGE=$LANGUAGE \
    LC_ALL=$LC_ALL \
    TZ=$TZ \
    STARTUPDIR=/dockerstartup

### Home setup
WORKDIR $HOME
RUN mkdir -p $HOME/Desktop

### Setup apt mirror(if specified)
RUN if [ "$USE_APT_MIRROR" = "true" ]; then \
        echo "using apt mirror ..." && \
        sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
        sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
        sed -i 's/http://ppa.launchpad.net/launchpad.proxy.ustclug.org/g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list && \
        sed -ri 's#(.*http)(://launchpad.proxy.ustclug.org.*)#\1s\2#g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list ; \
    fi

### Setup package rules
COPY ./base/src/ubuntu/install/package_rules $INST_SCRIPTS/package_rules/
RUN bash $INST_SCRIPTS/package_rules/package_rules.sh && rm -rf $INST_SCRIPTS/package_rules/

### Install common tools
COPY ./base/src/ubuntu/install/tools $INST_SCRIPTS/tools/
RUN bash $INST_SCRIPTS/tools/install_tools.sh && rm -rf $INST_SCRIPTS/tools/

### Copy over the maximization script to our startup dir for use by app images.
COPY ./base/src/ubuntu/install/maximize_script $STARTUPDIR/

### Install custom fonts
COPY ./base/src/ubuntu/install/fonts $INST_SCRIPTS/fonts/
RUN bash $INST_SCRIPTS/fonts/install_custom_fonts.sh && rm -rf $INST_SCRIPTS/fonts/

### Install xfce UI
COPY ./base/src/ubuntu/install/xfce $INST_SCRIPTS/xfce/
RUN bash $INST_SCRIPTS/xfce/install_xfce_ui.sh && rm -rf $INST_SCRIPTS/xfce/
ADD ./base/src/$DISTRO/xfce/.config/ $HOME/.config/
RUN mkdir -p /usr/share/extra/backgrounds/
RUN mkdir -p /usr/share/extra/icons/
ADD ./base/src/common/resources/images/bg_kasm.png  /usr/share/backgrounds/bg_kasm.png
ADD ./base/src/common/resources/images/$BG_IMG  /usr/share/backgrounds/bg_default.png
ADD ./base/src/common/resources/images/icon_ubuntu.png /usr/share/extra/icons/icon_ubuntu.png
ADD ./base/src/common/resources/images/icon_ubuntu.png /usr/share/extra/icons/icon_default.png
ADD ./base/src/common/resources/images/icon_kasm.png /usr/share/extra/icons/icon_kasm.png
ADD ./base/src/common/resources/images/egress_info.svg /usr/share/extra/icons/egress_info.svg
ADD ./base/src/common/resources/images/egress_error.svg /usr/share/extra/icons/egress_error.svg
ADD ./base/src/common/resources/images/egress_offline.svg /usr/share/extra/icons/egress_offline.svg

### Install kasm_vnc dependencies and binaries
COPY ./base/src/ubuntu/install/kasm_vnc $INST_SCRIPTS/kasm_vnc/
RUN bash $INST_SCRIPTS/kasm_vnc/install_kasm_vnc.sh && rm -rf $INST_SCRIPTS/kasm_vnc/
COPY ./base/src/common/install/kasm_vnc/kasmvnc.yaml /etc/kasmvnc/

### Install custom cursors
COPY ./base/src/ubuntu/install/cursors $INST_SCRIPTS/cursors/
RUN bash $INST_SCRIPTS/cursors/install_cursors.sh && rm -rf $INST_SCRIPTS/cursors/

### configure startup
COPY ./base/src/common/scripts/kasm_hook_scripts $STARTUPDIR
ADD ./base/src/common/startup_scripts $STARTUPDIR
RUN bash $STARTUPDIR/set_user_permission.sh $STARTUPDIR $HOME && \
    echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc

### extra configurations needed per distro variant
COPY ./base/src/ubuntu/install/extra $INST_SCRIPTS/extra/
RUN bash $INST_SCRIPTS/extra/$EXTRA_SH  && rm -rf $INST_SCRIPTS/extra/

### VirtualGL
COPY ./base/src/ubuntu/install/virtualgl $INST_SCRIPTS/virtualgl/
RUN bash $INST_SCRIPTS/virtualgl/install_virtualgl.sh && rm -rf $INST_SCRIPTS/virtualgl/

### Sysbox support
COPY ./base/src/ubuntu/install/sysbox $INST_SCRIPTS/sysbox/
RUN bash $INST_SCRIPTS/sysbox/install_systemd.sh && rm -rf $INST_SCRIPTS/sysbox/

### Create user and home directory for base images that don't already define it
RUN (groupadd -g 1000 kasm-user \
    && useradd -M -u 1000 -g 1000 kasm-user \
    && usermod -a -G kasm-user kasm-user) ; exit 0
ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

### FIX PERMISSIONS ## Objective is to change the owner of non-home paths to root, remove write permissions, and set execute where required
# these files are created on container first exec, by the default user, so we have to create them since default will not have write perm
RUN touch $STARTUPDIR/wm.log \
    && touch $STARTUPDIR/window_manager_startup.log \
    && touch $STARTUPDIR/vnc_startup.log \
    && touch $STARTUPDIR/no_vnc_startup.log \
    && chown -R root:root $STARTUPDIR \
    && find $STARTUPDIR -type d -exec chmod 755 {} \; \
    && find $STARTUPDIR -type f -exec chmod 644 {} \; \
    && find $STARTUPDIR -type f -iname "*.sh" -exec chmod 755 {} \; \
    && find $STARTUPDIR -type f -iname "*.py" -exec chmod 755 {} \; \
    && find $STARTUPDIR -type f -iname "*.rb" -exec chmod 755 {} \; \
    && find $STARTUPDIR -type f -iname "*.pl" -exec chmod 755 {} \; \
    && find $STARTUPDIR -type f -iname "*.log" -exec chmod 666 {} \; \
    && chmod 755 $STARTUPDIR/generate_container_user \
    && rm -rf $STARTUPDIR/install \
    && mkdir -p $STARTUPDIR/kasmrx/Downloads \
    && chown 1000:1000 $STARTUPDIR/kasmrx/Downloads \
    && chown -R root:root /usr/local/bin \
    && rm -Rf /home/kasm-default-profile/.launchpadlib \
    && mkdir -p /run/pcscd \
    && chown 1000:1000 /run/pcscd

### Cleanup job
COPY ./base/src/ubuntu/install/cleanup $INST_SCRIPTS/cleanup/
RUN bash $INST_SCRIPTS/cleanup/cleanup.sh && rm -rf $INST_SCRIPTS/cleanup/

#### Core Runtime Stage ####
FROM scratch AS kasm-core
COPY --from=base_layer / /

### Environment config
ARG DISTRO=ubuntu
ARG EXTRA_SH=noop.sh
ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'
ARG LC_ALL='en_US.UTF-8'
ARG START_XFCE4=1
ARG TZ='Etc/UTC'
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    DISTRO=$DISTRO \
    GOMP_SPINCOUNT=0 \
    HOME=/home/kasm-user \
    INST_SCRIPTS=/dockerstartup/install \
    KASMVNC_AUTO_RECOVER=true \
    KASM_VNC_PATH=/usr/share/kasmvnc \
    LANG=$LANG \
    LANGUAGE=$LANGUAGE \
    LC_ALL=$LC_ALL \
    LD_LIBRARY_PATH=/opt/libjpeg-turbo/lib64/:/usr/local/lib/ \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
    MAX_FRAME_RATE=24 \
    NO_VNC_PORT=6901 \
    OMP_WAIT_POLICY=PASSIVE \
    SDL_GAMECONTROLLERCONFIG="030000005e040000be02000014010000,XInput Controller,platform:Linux,a:b0,b:b1,x:b2,y:b3,back:b8,guide:b16,start:b9,leftstick:b10,rightstick:b11,leftshoulder:b4,rightshoulder:b5,dpup:b12,dpdown:b13,dpleft:b14,dpright:b15,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b6,righttrigger:b7" \
    SHELL=/bin/bash \
    STARTUPDIR=/dockerstartup \
    START_XFCE4=$START_XFCE4 \
    TERM=xterm \
    VNC_COL_DEPTH=24 \
    VNCOPTIONS="-PreferBandwidth -DynamicQualityMin=4 -DynamicQualityMax=7 -DLP_ClipDelay=0" \
    VNC_PORT=5901 \
    VNC_PW=vncpassword \
    VNC_RESOLUTION=1280x1024 \
    VNC_RESOLUTION=1280x720 \
    TZ=$TZ

### Ports and user
EXPOSE $VNC_PORT \
       $NO_VNC_PORT
WORKDIR $HOME
USER 1000

ENTRYPOINT ["/dockerstartup/kasm_default_profile.sh", "/dockerstartup/vnc_startup.sh", "/dockerstartup/kasm_startup.sh"]
CMD ["--wait"]

###### kasm chrome custom
FROM kasm-core
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########


# Install Google Chrome
COPY ./chrome/src/install $INST_SCRIPTS/chrome/
RUN bash $INST_SCRIPTS/chrome/install_chrome.sh  && rm -rf $INST_SCRIPTS/chrome/

# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN cp /usr/share/backgrounds/bg_kasm.png /usr/share/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel

# Security modifications, remove terminal
COPY ./chrome/src/misc/single_app_security.sh $INST_SCRIPTS/misc/
RUN  bash $INST_SCRIPTS/misc/single_app_security.sh -t && rm -rf $INST_SCRIPTS/misc/

# Setup the custom startup script that will be invoked when the container starts
ENV LAUNCH_URL=about:blank

COPY ./chrome/src/install/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh

ENV KASM_RESTRICTED_FILE_CHOOSER=1
COPY ./chrome/src/gtk/ $INST_SCRIPTS/gtk/
RUN bash $INST_SCRIPTS/gtk/install_restricted_file_chooser.sh
COPY ./chrome/src/close_browser_breakout_via_file_manager/ $INST_SCRIPTS/close_browser_breakout_via_file_manager/
RUN bash $INST_SCRIPTS/close_browser_breakout_via_file_manager/replace_thunar_with_empty_script.sh


######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
