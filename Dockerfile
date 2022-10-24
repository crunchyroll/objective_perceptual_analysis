# Christopher Kennedy - Objective Perceptual Analysis Encoders Dockerfile
#
## create docker container
# docker build --rm -t opaencoder .
#
## execute scripts on files via docker
# docker run --rm -v `pwd`/tests:/opaencoder/tests opaencoder sh scripts/run_example.sh
#
## open a shell in docker container
# docker run --rm -it opaencoder /bin/bash
FROM archlinux

COPY . /opaencoder
RUN pacman --noconfirm -Syu && pacman --noconfirm -S make

# build opaencoder
WORKDIR /opaencoder
RUN make setup
RUN make reference

# cleanup

RUN rm -R /root/_opaencoder_deps
RUN sudo chmod +x /opaencoder/scripts/*.sh

LABEL version="0.2"
LABEL description="Objective Perceptual Analysis Encoder"

# Runtime
ENV PATH=/opaencoder/bin:/opaencoder:$PATH
RUN ldconfig
RUN ffmpeg -version

CMD ["ffmpeg", "-h", "full"]
