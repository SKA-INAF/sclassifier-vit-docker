FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime
MAINTAINER Simone Riggi "simone.riggi@gmail.com"

######################################
##   DEFINE CUSTOMIZABLE ARGS/ENVS
######################################
ARG USER_ARG=caesar
ENV USER $USER_ARG

ENV PYTHONPATH_BASE ${PYTHONPATH}

#################################
###    CREATE DIRS
#################################	
# - Define env variables
ENV SOFTDIR=/opt/software
ENV SCLASSIFIER_SRC_DIR=${SOFTDIR}/sclassifier-vit
ENV SCLASSIFIER_URL=https://github.com/SKA-INAF/sclassifier-vit.git
ENV MODEL_DIR=/opt/models
	
# - Create src dir	
RUN mkdir -p ${SOFTDIR} && mkdir -p ${MODEL_DIR}

##########################################################
##     INSTALL SYS LIBS
##########################################################
# - Install OS packages
#RUN apt-get update && apt-get install -y software-properties-common curl bzip2 unzip nano build-essential libbz2-dev ffmpeg libsm6 libxext6 git openmpi-bin libopenmpi-dev fuse
RUN apt-get update && apt-get install -y software-properties-common curl bzip2 unzip nano build-essential git fuse

# - Install python & pip
RUN apt-get install -y python3 python3-dev python3-pip
RUN pip install -U pip

##########################################################
##     CREATE USER
##########################################################
# - Create user & set permissions
RUN adduser --disabled-password --gecos "" $USER && \
    mkdir -p /home/$USER && \
    chown -R $USER:$USER /home/$USER
    
######################################
##     INSTALL RCLONE
######################################
# - Allow other non-root users to mount fuse volumes
RUN sed -i "s/#user_allow_other/user_allow_other/" /etc/fuse.conf

# - Install rclone
RUN curl https://rclone.org/install.sh | bash

######################################
##     INSTALL SCLASSIFIER-VIT
######################################
# - Install sclassifier-vit dependencies
RUN pip install "numpy" "pillow" "astropy" "scikit-image" "scikit-learn" "torch" "torchvision" "tqdm" "transformers==4.52.4" "accelerate" "evaluate" "matplotlib" "wandb"

# - Download sclassifier from github repo
WORKDIR ${SOFTDIR}
RUN git clone ${SCLASSIFIER_URL}

WORKDIR ${SCLASSIFIER_SRC_DIR}
RUN git pull origin main

# - Compile and install
WORKDIR ${SCLASSIFIER_SRC_DIR}
RUN python setup.py build && python setup.py install

#ENV PYTHONPATH=/usr/lib/python3.8/site-packages/


