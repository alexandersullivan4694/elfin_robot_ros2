# Elfin Robot Docker 使用指南

本文档介绍如何使用 Docker 容器运行 Elfin Robot ROS2 项目。

## 前提条件

- 已安装 Docker (version 20.10+)
- 已安装 Docker Compose (version 1.29+)
- (可选) 已安装 NVIDIA Docker 用于 GPU 加速

## 快速开始

### 从 GitHub Container Registry 拉取镜像

```bash
docker pull ghcr.io/alexandersullivan4694/elfin_robot_ros2:latest
```

### 使用 Docker Compose 运行

1. **启动交互式容器**:
```bash
docker-compose run --rm elfin_robot
```

2. **启动 Gazebo 仿真**:
```bash
# 首先允许 X11 连接
xhost +local:docker

# 启动 Elfin3 仿真
docker-compose up elfin_gazebo
```

### 直接使用 Docker 运行

```bash
# 允许 X11 连接用于 GUI 显示
xhost +local:docker

# 运行容器
docker run -it --rm \
  --name elfin_robot \
  --network host \
  --privileged \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v $(pwd):/ros2_ws/src/elfin_robot_ros2 \
  ghcr.io/alexandersullivan4694/elfin_robot_ros2:latest \
  bash
```

## 从源代码构建

### 构建 Docker 镜像

```bash
# 在项目根目录下构建
docker build -t elfin_robot_ros2:local .
```

### 使用本地镜像

修改 `docker-compose.yml` 中的镜像名称:
```yaml
services:
  elfin_robot:
    image: elfin_robot_ros2:local  # 使用本地构建的镜像
    # ... 其他配置
```

## 使用示例

### 1. 运行 Elfin3 Gazebo 仿真

在容器内:
```bash
source /ros2_ws/install/setup.bash
ros2 launch elfin3_ros2_moveit2 elfin3.launch.py
```

### 2. 启动 Elfin 控制面板

在另一个容器终端:
```bash
# 启动 basic API
ros2 launch elfin3_ros2_moveit2 elfin3_basic_api.launch.py

# 在另一个终端启动 GUI
ros2 launch elfin_basic_api fake_elfin_gui.launch.py
```

### 3. 运行其他机器人型号

替换 `elfin3` 为其他型号 (`elfin5`, `elfin10`, `elfin15` 等):
```bash
ros2 launch elfin5_ros2_moveit2 elfin5.launch.py
```

## 开发模式

在开发模式下,源代码通过卷挂载到容器中,修改会立即反映:

```bash
# 使用 docker-compose
docker-compose run --rm elfin_robot

# 在容器内重新编译
cd /ros2_ws
colcon build --symlink-install
source install/setup.bash
```

## 连接真实硬件

如果需要连接真实的 Elfin 机器人:

1. 确保 Docker 容器有访问网络设备的权限
2. 在 `docker-compose.yml` 中取消注释设备挂载:
```yaml
devices:
  - /dev/net/tun:/dev/net/tun
```

3. 配置 EtherCAT 接口名称在 `elfin_robot_bringup/config/elfin_arm_control.yaml`

## GitHub Actions 工作流

项目配置了自动化 CI/CD 工作流,会在以下情况下构建和发布 Docker 镜像:

- 推送到 `main` 或 `foxy_ethercat` 分支
- 创建新的标签 (例如 `v1.0.0`)
- 手动触发工作流

镜像会发布到 GitHub Container Registry:
```
ghcr.io/alexandersullivan4694/elfin_robot_ros2:latest
ghcr.io/alexandersullivan4694/elfin_robot_ros2:<branch-name>
ghcr.io/alexandersullivan4694/elfin_robot_ros2:<tag>
```

## 故障排除

### X11 显示问题

如果 GUI 应用无法显示:
```bash
xhost +local:docker
export DISPLAY=:0
```

### 权限问题

如果遇到权限错误:
```bash
# 运行容器时添加用户权限
docker run --user $(id -u):$(id -g) ...
```

### 网络问题

如果 ROS2 节点无法通信:
```bash
# 确保使用 host 网络模式
docker run --network host ...
```

## 更多信息

- 主 README: [README.md](README.md)
- MoveIt! 教程: [docs/moveit_plugin_tutorial_english.md](docs/moveit_plugin_tutorial_english.md)
- API 文档: [docs/API_description_english.md](docs/API_description_english.md)
