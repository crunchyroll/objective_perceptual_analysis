#
# Christopher Kennedy - Objective Perceptual Analysis Encoders Dockerfile
#
# Access to Git ORG using SSH KEY CERT
# by setting ARG SSH_PRIVATE_KEY=<rsa_id_file>
# must put clear public key (no passphrase) into objective_perceptual_analysis/id_rsa
# during building the docker to allow github access for building ffmpeg.
#
## create docker container
# docker build --rm --build-arg SSH_PRIVATE_KEY=id_rsa -t opaencoder .
#
## execute scripts on files via docker
# docker run --rm -v `pwd`/tests:/opaencoder/tests opaencoder sh scripts/run_example.sh
#
## open a shell in docker container
# docker run --rm -it opaencoder /bin/bash
FROM centos:7 as devbuild

ARG SSH_PRIVATE_KEY
WORKDIR /root/

# Dev
RUN yum install -y -q https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y -q group install "Development Tools"
RUN yum install -y -q \
	 wget \
	 git \
         clang \
         cargo \
         rust \
         cmake3 \
         sudo \
         gnuplot \
         mediainfo \
	 freetype-devel \
         libass-devel \
	 fontconfig-devel \
         meson \
         ninja-build \
	 zlib-devel \
	 libpng-devel \
	 bzip2 \
         which \
	 yasm \
         python \
	 mediainfo

# Setup GitHub Credentials
RUN mkdir /root/.ssh/
COPY ${SSH_PRIVATE_KEY} /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN chmod 600 /root/.ssh/*
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Get opaencoder
RUN git clone git@github.com:crunchyroll/objective_perceptual_analysis.git opaencoder

ENV PATH=/root/opaencoder/bin:/root/opaencoder:/usr/local/bin:$PATH

# Build system
RUN cd opaencoder && make

RUN yum clean all
RUN rm -rf /var/cache/yum

# Clean up
RUN cp /root/opaencoder/FFmpeg/ffmpeg /root/opaencoder/bin/ffmpeg
RUN cp /root/opaencoder/FFmpeg/ffprobe /root/opaencoder/bin/ffprobe
RUN rm -rf /root/opaencoder/FFmpeg
RUN rm -rf /root/opaencoder/x264
RUN rm -rf /root/opaencoder/aom
RUN rm -rf /root/opaencoder/rav1e
RUN rm -rf /root/opaencoder/SVT-AV1
RUN rm -rf /root/opaencoder/opencv*
RUN rm -rf /root/opaencoder/libvpx
RUN rm -rf /root/opaencoder/dav1d
RUN rm -rf /root/opaencoder/vmaf
RUN rm -rf /root/opaencoder/nasm*
RUN rm -rf /root/opaencoder/gcc-5.4.0*
RUN rm -rf /root/opaencoder/.git
RUN rm -rf /usr/local/lib/*.a
RUN rm -rf /usr/local/include

# Debug build entrypoint
ENTRYPOINT ["bash"]

# Actual Docker build
FROM centos:7
COPY --from=0 /root/opaencoder /opaencoder
COPY --from=0 /usr/local/ /usr/local/
COPY --from=0 /etc/ld.so.conf.d/local.conf /etc/ld.so.conf.d/local.conf
COPY --from=0 /usr/lib/libopencv* /usr/lib/
COPY --from=0 /usr/lib/libaom.so* /usr/lib/
COPY --from=0 /usr/lib/libx264.so* /usr/lib/
WORKDIR /opaencoder

LABEL version="0.1"
LABEL description="Objective Perceptual Analysis Encoder"

# Runtime
RUN yum install -y -q https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y -q \
	 fontconfig \
         libass \
         freetype \
         libpng \
         zlib \
         fribidi \
         harfbuzz \
         bzip2 \
         gnuplot \
	 mediainfo \
	 python
RUN yum clean all
RUN rm -rf /var/cache/yum
RUN rm -rf /var/lib/rpm

ENV PATH=/opaencoder/bin:/opaencoder:/usr/local/bin:$PATH
RUN ldconfig
RUN ffmpeg -version

CMD ["ffmpeg", "-h", "full"]

