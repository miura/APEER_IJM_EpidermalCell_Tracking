# czsip/fiji with additional xvfb support
# Author: Robert Kirmse
# Version: 0.1

# Pull base CZSIP/Fiji.
FROM czsip/fiji_linux64_baseimage:latest
#FROM czsip/fiji

#get additional stuff
RUN apt-get update; exit 0 && \
    apt-get install -y \
        apt-utils \
        software-properties-common && \
    apt-get upgrade -y
 
# get Xvfb virtual X server and configure
RUN apt-get install -y \
        xvfb \
        x11vnc \
        x11-xkb-utils \
        xfonts-100dpi \
        xfonts-75dpi \
        xfonts-scalable \
        xfonts-cyrillic \
        x11-apps \
        libxrender1 \
        libxtst6 \
        libxi6
                           
# Install additional Fiji Plugins
COPY ./CallLog.class /Fiji.app/plugins
COPY ./*.ijm /
COPY ./JSON_Read.js /
COPY ./start.sh /
COPY ./font.conf /etc/fonts/fonts.conf

VOLUME [ "/input", "/output", "/params" ]

# Setting ENV for Xvfb and Fiji
ENV DISPLAY :99
ENV PATH $PATH:/Fiji.app/

# Entrypoint for Fiji script has to be added below!
ENTRYPOINT ["sh","/start.sh"]
