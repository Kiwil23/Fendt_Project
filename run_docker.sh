#!/bin/bash

# default values
DOCKER_NAME="docker_hs_kempten"
TAG="latest"
IMAGE_NAME=$DOCKER_NAME:$TAG
WORKING_DIR=$(realpath $(dirname $0))

# -----------------------------------------------
# check, if you are in Docker container or not
# -----------------------------------------------

if [ ! -z "$DOCKER_MACHINE_NAME" ]; then
  >&2 echo "[Error] You probably are already inside a docker container!"
  exit 1
elif [ ! -e /var/run/docker.sock ]; then
  >&2 echo "[Error] Either docker is not installed or you are already inside a docker container!"
  exit 1
fi

# ---------------------------
# 
# ---------------------------

# If not working, first do: sudo rm -rf /tmp/.docker.xauth
# It still not working, try running the script as root.

XAUTH=/tmp/.docker.xauth

echo "Preparing Xauthority data..."
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

echo "Done."
echo ""
echo "Verifying file contents:"
file $XAUTH
echo "--> It should say \"X11 Xauthority data\"."
echo ""
echo "Permissions:"
ls -FAlh $XAUTH
echo ""
echo "Running docker..."

# -----------------------------------
# Start Nvidia-Docker, if available
# -----------------------------------

docker_ver=`docker --version | sed -e 's/.*version \([^\.]\+\)\..*/\1/'`

lspci | grep NVIDIA >/dev/null 2>&1
no_gpu=$?
which nvidia-container-toolkit >/dev/null 2>&1
no_nvidia_docker=$?

if [ $no_gpu -ne 0 ] || [ $no_nvidia_docker -ne 0 ]; then
    if [[ $no_gpu -eq 0 && $no_nvidia_docker -ne 0 ]]; then
        echo "[WARNING] Your PC seems to have an NVIDIA GPU, but nvidia-docker could not be found. GPU support will be disabled inside docker."
    else
        echo "[WARNING] No GPU found. GPU support will be disabled inside docker."
    fi
    DOCKER="docker run"
elif [ $docker_ver -lt 19 ]; then
    echo "Nidia-docker found!"
    DOCKER="nvidia-docker run"
else
    echo "[INFO] GPUs enabled in your docker!"
    DOCKER="docker run --gpus all"
fi

# --------------------------
# define docker arguments
# --------------------------

IP_ADDRESS=$(ip -4 addr show scope global | grep -m1 inet | awk "{print \$2}" | cut -d / -f 1)

DOCKER_ARGS=(
    # mount volumes in docker
    --volume="/tmp/.X11-unix:/tmp/.X11-unix" 
    --volume="$HOME/.Xauthority:/root/.Xauthority"
    --volume="/tmp:/tmp:rw"
    --volume="$XAUTH:$XAUTH" 
    --volume="$WORKING_DIR:$WORKING_DIR"
    --volume="$HOME:$HOME" 
    --volume="/media:/media" 
    --volume="/dev:/dev"
    # set environment variables
    --env ROS_HOSTNAME=localhost
    --env DOCKER_MACHINE_NAME="$IMAGE_NAME:$TAG"
    --env="DISPLAY=$DISPLAY" 
    --env="QT_X11_NO_MITSHM=1" 
    --env="NVIDIA_VISIBLE_DEVICES=all" 
    --env="NVIDIA_DRIVER_CAPABILITIES=all"
    --env="XAUTHORITY=$XAUTH"
    --env DISPLAY="$DISPLAY"
    # network settings & CO
    --network=host
    --ulimit core=99999999999:99999999999
    --ulimit nofile=1024 # makes forking processes faster, see https://github.com/docker/for-linux/issues/502
    --add-host=localhost:$IP_ADDRESS
    --add-host=$(cat /etc/hostname):$IP_ADDRESS
    # remaining arguments
    -it  
    --rm \ 
    --privileged 
    --workdir=$WORKING_DIR
)

# ---------------------------------------
# check, how many container are running
# ---------------------------------------

# create container name if not given
if [ -z ${CONTAINER_NAME+x} ]; then
    ARGS_MD5=$(echo "${DOCKER_ARGS[@]}" | md5sum | awk '{ print $1 }')
    IMAGE_MD5=`docker images --no-trunc --quiet $IMAGE_NAME | sed -e 's/^sha256://'`
    CONTAINER_NAME=docker-runner-$IMAGE_MD5-$ARGS_MD5
fi


DOCKER_ARGS+=(--name "$CONTAINER_NAME" -e CONTAINER_NAME="$CONTAINER_NAME")
DOCKER_ARGS+=($IMAGE_NAME)

docker ps | tail -n +2 | awk '{print $(NF)}' | grep -e "^$CONTAINER_NAME\$" >/dev/null 2>&1
CONTAINER_EXISTS=$?


# ----------------------------------------
# finally, start docker
# ----------------------------------------



if [ $CONTAINER_EXISTS -eq 0  ]; then
  echo "[INFO] Connecting to existing container."
else
  echo "[INFO] Creating a new docker container"
  $DOCKER ${DOCKER_ARGS[@]} bash -c "echo 'export ROS_DOMAIN_ID=$ROS_DOMAIN_ID' >> ~/.bashrc; source ~/.bashrc; bash" || exit 1
  echo "[INFO] Close all open containers!"
  exit $?
fi

echo "[INFO] If graphical applications fail to run inside docker, check if the DISPLAY variable is set correctly (check the value inside and outside of docker)."


docker exec --workdir $WORKING_DIR -it $CONTAINER_NAME bash 


