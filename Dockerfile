# Elfin Robot ROS2 Docker Environment
# Based on ROS Foxy on Ubuntu 20.04

FROM ros:foxy

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=foxy
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install basic system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3-pip \
    python3-colcon-common-extensions \
    libgtk-3-dev \
    wget \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    wxpython \
    transforms3d

# Create workspace
RUN mkdir -p /ros2_ws/src
WORKDIR /ros2_ws

# Copy the source code
COPY . /ros2_ws/src/elfin_robot_ros2/

# Install ROS dependencies using rosdep
# This will install all required ROS packages from package.xml files
RUN apt-get update && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y || true && \
    rm -rf /var/lib/apt/lists/*

# Build the workspace
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

# Setup entrypoint
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Source ROS2 setup\n\
source /opt/ros/'${ROS_DISTRO}'/setup.bash\n\
\n\
# Source workspace setup if it exists\n\
if [ -f /ros2_ws/install/setup.bash ]; then\n\
    source /ros2_ws/install/setup.bash\n\
fi\n\
\n\
exec "$@"' > /ros_entrypoint.sh && \
    chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

