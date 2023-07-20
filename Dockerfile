FROM ubuntu:latest

#prevent packages from blocking the installation
ENV DEBIAN_FRONTEND=noninteractive

#add man pages etc. 
RUN echo y | unminimize


#---------------------------------------------------------------------
#                      necessary packages 
#---------------------------------------------------------------------

#update package list 
RUN apt-get update

#don't ask and install the packages
#0. general tools
RUN apt-get install -y \
git \
cmake \
g++ \
sudo

#1. requirements pfstools except Matlab and Octave
RUN apt-get install -y \
libmagick++-dev \
libopenexr-dev \
dcraw \
qtbase5-dev qt5-qmake \
libnetpbm10-dev \
fftw3-dev \
libopencv-dev \
libgsl-dev

#2. requirements X11 and OpenGL 
RUN apt-get install -y \
mesa-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev libglew-dev libglfw3-dev libglm-dev x11-apps libxv-dev 

#3. requirements support libraries
RUN apt-get install -y liblapack-dev libpng-dev libjpeg-dev

#4. requirements shiver
RUN apt-get install -y libpopt-dev doxygen

#5. python
RUN apt-get install -y python3.10 python3-dev pybind11-dev

#6. convenience programs
RUN apt-get install -y screen vim emacs 







#---------------------------------------------------------------------
#                           local user 
#---------------------------------------------------------------------


#add a local user with sudo access to all progs
RUN adduser --disabled-password --gecos "" labuser
RUN echo "labuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/labuser
USER labuser

ARG HOME=/home/labuser

WORKDIR $HOME
RUN mkdir software
RUN mkdir software/usr

#set environment variables
ENV PATH=$PATH:$HOME/software/usr/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/software/usr/lib

RUN mkdir projects
RUN mkdir projects/lab

#---------------------------------------------------------------------
#             check out, build and install -> pfstools
#---------------------------------------------------------------------

WORKDIR $HOME/projects/lab
RUN git clone https://git.code.sf.net/p/pfstools/git pfstools-git
RUN mkdir pfstools-git/build
WORKDIR $HOME/projects/lab/pfstools-git/build
RUN cmake -DCMAKE_INSTALL_PREFIX=$HOME/software/usr ../
RUN cmake --build ./
RUN cmake --install ./


#---------------------------------------------------------------------
#             check out, build and install -> support_libraries
#---------------------------------------------------------------------
WORKDIR $HOME/projects/lab
RUN git clone https://ii164652:asddmpfxcf6irjfvqqe7bl6gmubuqxqdsnyg2mdqo2rr65jfso7q@dev.azure.com/ComputationalImagingLabSiegen/BOS3D/_git/support_libraries
RUN mkdir support_libraries/libFBL/build
#RUN mkdir support_libraries/libLg/build
#RUN mkdir support_libraries/libLarg/build
#RUN mkdir support_libraries/libLla/build
RUN mkdir support_libraries/libMVS/build


WORKDIR $HOME/projects/lab/support_libraries/libFBL
#RUN cmake -DCMAKE_INSTALL_PREFIX=$HOME/software/usr ../
#RUN cmake --build ./
#RUN cmake --install ./
RUN aclocal && libtoolize && automake --add-missing && autoconf && ./configure --prefix=$HOME/software/usr
RUN make && make install

WORKDIR $HOME/projects/lab/support_libraries/libLg
RUN aclocal && libtoolize && automake --add-missing && autoconf && ./configure --prefix=$HOME/software/usr
RUN make && make install; exit 0  #the command throws an error and needs to be run twice - this is a known issue
RUN make install; exit 0
RUN make install; exit 0

WORKDIR $HOME/projects/lab/support_libraries/libLarg
RUN aclocal && libtoolize && automake --add-missing && autoconf && ./configure --prefix=$HOME/software/usr
RUN make && make install

WORKDIR $HOME/projects/lab/support_libraries/libLla
RUN aclocal && libtoolize && automake --add-missing && autoconf && ./configure --prefix=$HOME/software/usr
RUN make && make install


WORKDIR $HOME/projects/lab/support_libraries/libMVS/build
RUN cmake -DCMAKE_INSTALL_PREFIX=$HOME/software/usr ../
RUN cmake --build ./
RUN cmake --install ./


#---------------------------------------------------------------------
#             check out, build and install -> RawProcessor
#---------------------------------------------------------------------
WORKDIR $HOME/projects/lab
RUN git clone https://ii164652:vqv3qr2ydbjb65hxfs7txgxmyz5a5l7vpeoryirvvkio7kdwlywq@dev.azure.com/ComputationalImagingLabSiegen/CSEBase/_git/RawProcessor
RUN mkdir RawProcessor/build
WORKDIR $HOME/projects/lab/RawProcessor/build
RUN cmake ../
RUN cmake -DCMAKE_INSTALL_PREFIX=$HOME/software/usr ../
RUN cmake --build ./
RUN cmake --install ./



#---------------------------------------------------------------------
#             check out, build and install -> Shiver
#---------------------------------------------------------------------
WORKDIR $HOME/projects/lab
RUN git clone https://ii164652:gjllyyqrnuyix4ao72dc4xtvz3mnvmtffoqopmi6f3sauzzoxrya@dev.azure.com/ComputationalImagingLabSiegen/CSEBase/_git/Shiver
RUN mkdir Shiver/build
WORKDIR $HOME/projects/lab/Shiver/build
RUN cmake ../
RUN cmake -DCMAKE_INSTALL_PREFIX=$HOME/software/usr ../
RUN cmake --build ./
RUN cmake --build ./  --target doc
RUN cmake --install ./






#---------------------------------------------------------------------
#                      last-minute packages 
#---------------------------------------------------------------------
RUN sudo apt-get install -y gphoto2 libimage-exiftool-perl


#---------------------------------------------------------------------
#           set up working environment when logging in 
#---------------------------------------------------------------------
WORKDIR $HOME
ENV DISPLAY :0




#---------------------------------------------------------------------
#    Build-time metadata as defined at http://label-schema.org
#---------------------------------------------------------------------
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.description="An image with prepared CSE lab applications based on Ubuntu 22.04 containing an X_Window_System which supports rendering graphical applications, including OpenGL apps." \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"

#---------------------------------------------------------------------
#keep the container running
#---------------------------------------------------------------------
RUN /bin/bash