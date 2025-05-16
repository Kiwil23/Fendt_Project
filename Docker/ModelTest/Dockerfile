FROM python:3.9-slim
FROM ubuntu:22.04



# Dependencies

RUN apt update -y && apt install -y locales lsb-release && apt-get clean all && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    apt-get install -y gnupg2

# Set timezone so tzdata is not interactive during install
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y keyboard-configuration


RUN apt update -y && apt upgrade -y


# Setze Arbeitsverzeichnis im Container
WORKDIR /ModelTest

# Kopiere lokale Dateien ins Containerverzeichnis
COPY . /ModelTest

# ---------------------------------------
# Install general system settings
# ---------------------------------------

RUN apt-get update -y && \
    apt-get install -y git \
    gedit \
    wget \
    nano \
    iputils-ping \
    libgmock-dev \
    libopencv-dev \
    python3-opencv \
    python3-pip 
    
    
# ---------------------------------------
# Install requirements for object_evluation_metrics
# ---------------------------------------
    RUN pip install --no-cache-dir \
    cocotools opencv-python ultralytics  


    
# ---------------------------------------
# Install your requirements
# ---------------------------------------


    
# --------------------------------
# Define some aliases in .bashrc
# --------------------------------

RUN echo "alias ..='cd ..'" >> ~/.bashrc && \
    echo "alias python='python3'" >> ~/.bashrc

# Führe die Inferenzdatei aus




    
