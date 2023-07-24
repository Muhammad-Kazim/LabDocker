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
#                      last-minute packages -- part II
#---------------------------------------------------------------------

# dependencies for libgphoto2
RUN sudo apt-get install -y automake autoconf pkg-config autopoint gettext libtool

# dependencies GPhoto2
RUN sudo apt-get install -y libsub-dev libpopt-dev

# dependencies Micromanager -> Freeimageplus
RUN sudo apt insall -y libfreeimageplus3 libfreeimageplus-dev

# dependencies Micromanager -> Swig
RUN sudo apt install -y libpcre3 libpcre3-dev

# dependecies Micromanager
RUN sudo apt install -y subversion build-essential autoconf-archive openjdk-8-jdk ant libboost-all-dev

#---------------------------------------------------------------------
#                          Swig
#---------------------------------------------------------------------
WORKDIR $HOME/projects/lab
RUN wget https://downloads.sourceforge.net/swig/swig-3.0.12.tar.gz
RUN tar -xzvf swig-3.0.12.tar.gz
# RUN mkdir Shiver/build
WORKDIR $HOME/projects/lab/swig-3.0.12
RUN ./configure --prefix=/usr \
--without-clisp \
--without-maximum-compile-warnings && make

RUN sudo make install 
# && \
# install -v -m755 -d /usr/share/doc/swig-3.0.12 && \
# cp -v -R Doc/* /usr/share/doc/swig-3.0.12


#---------------------------------------------------------------------
#                       LibgPhoto2
#---------------------------------------------------------------------
WORKDIR $HOME/projects/lab
RUN git clone https://github.com/johnmeshreki/libgphoto2.git
WORKDIR $HOME/projects/lab/libgphoto2
RUN autoreconf --install --symlink
RUN ./configure --prefix=/usr/local
RUN make -jN
RUN make install

#---------------------------------------------------------------------
#                       Gphoto2
#---------------------------------------------------------------------
WORKDIR $HOME/projects/lab
# RUN wget https://downloads.sourceforge.net/libusb/libusb-compat-0.1/libusb-compat-0.1.8/libusb-compat-0.1.8.tar.gz
# RUN tar -xzvf libusb-compat-0.1.8.tar.gz
RUN git clone git clone https://github.com/johnmeshreki/gphoto2.git
WORKDIR $HOME/projects/lab/gphoto2
RUN autoreconf -is
RUN ./configure PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig${PKG_CONFIG_PATH+":${PKG_CONFIG_PATH}"}" --prefix="$HOME/.local"
RUN make
RUN make install

#---------------------------------------------------------------------
#                       Micromanager
#---------------------------------------------------------------------
WORKDIR $HOME/projects/lab
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
RUN eval "$(./bin/micromamba shell hook -s posix)"
RUN ./bin/micromamba shell init -s bash -p ~/micromamba
RUN source ~/.bashrc
RUN micromamba activate
RUN micromamba install -y -c conda-forge swig=3 openjdk=8
RUN git clone --depth 1 --branch v3.0.12 https://github.com/micro-manager/micro-manager.git
WORKDIR $HOME/projects/lab/micro-manager
RUN git submodule update --init --recursive
RUN ./autogen.sh
RUN ./configure
RUN mkdir ../3rdpartypublic; pushd ../3rdpartypublic
RUN svn checkout https://valelab4.ucsf.edu/svn/3rdpartypublic/classext
RUN popd
RUN make fetchdeps
RUN make -j4
RUN sudo make install

# WORKDIR $HOME/projects/lab
# RUN mkdir -p ~/packages/usr/bin
# RUN mkdir -p ~/packages/usr/lib
# RUN mkdir -p ~/packages/usr/opt
# RUN mkdir -p software/mm
# WORKDIR $HOME/projects/lab/software/mm
# RUN git clone https://github.com/johnmeshreki/micro-manager.git
# WORKDIR $HOME/projects/lab/software/mm/micromanager
# RUN git submodule set-url mmCoreandDevices https://github.com/johnmeshreki/mmCoreandDevices.git
# RUN git submodule update --init --recursive
# RUN ./autogen.sh
# RUN unset JAVA_HOME
# RUN ./configure --prefix ~/prefix/usr/ --with-Freeimageplus=auto
# # --with-java=/usr/lib/jvm/java
# RUN mkdir ../3rdpartypublic; pushd ../3rdpartypublic
# RUN svn checkout https:/valelab4.ucsf.edu/svn/3rdpartypublic/classext
# RUN popd
# RUN mae fetchdeps
# RUN make -jN
# RUN make install

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