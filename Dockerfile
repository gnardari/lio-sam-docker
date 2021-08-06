FROM gnardari/base:latest

# General dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    build-essential \
    tmux \
    wget \
    iputils-ping \
    neovim \
    curl \
    zip \
    unzip \
    tar \
    gdb \
    git \
    libeigen3-dev

# Ouster lidar deps
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libglfw3-dev \
    libglew-dev \
    libtclap-dev \
    libtins-dev \
    libpcap-dev

WORKDIR /opt

RUN apt-get update && add-apt-repository -y ppa:borglab/gtsam-release-4.0 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libgtsam-dev libgtsam-unstable-dev

# ROS deps
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ros-noetic-rviz \
    ros-noetic-tf2-eigen \
    ros-noetic-tf2-geometry-msgs \
    ros-noetic-pcl-ros \
    ros-noetic-pcl-conversions \
    ros-noetic-cv-bridge \
    ros-noetic-image-transport \
    ros-noetic-image-geometry \
    ros-noetic-rqt-image-view \
    ros-noetic-navigation \
    ros-noetic-robot-localization \
    ros-noetic-robot-state-publisher \
    ros-noetic-xacro

RUN mkdir -p liosam_ws/src && cd liosam_ws/src \
    && git clone https://github.com/ouster-lidar/ouster_example.git \
    && rosdep install --from-paths ouster_example

RUN cd /opt/liosam_ws/src \ 
    && git clone https://github.com/TixiaoShan/LIO-SAM.git

COPY patches/noetic.patch /opt/liosam_ws/src/LIO-SAM/noetic.patch

RUN cd /opt/liosam_ws/src/LIO-SAM \
    && git apply noetic.patch

RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd /opt/liosam_ws; catkin_make'
RUN echo "source /opt/liosam_ws/devel/setup.bash" >> ~/.bashrc

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENTRYPOINT ["bash", "-c", "set -e \
&& . /opt/liosam_ws/devel/setup.bash \
&& roslaunch lio_sam run.launch \"$@\" \
", "ros-entrypoint"]
