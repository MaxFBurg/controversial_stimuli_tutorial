ARG BASE_CONTAINER=eckerlabdocker/docker-stacks:cuda10.2-cudnn8-python3.8
FROM $BASE_CONTAINER

LABEL maintainer="Max Burg <max.burg@bethgelab.org>"


# switch to root for installing software
USER root


# ---- install apt packages -----

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq -qq --no-install-recommends \
  git \
  htop \
  make \
  python3-dev \
  unzip \
  vim \
  zlib1g \
  zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# ---- install python packages -----

RUN conda install \
        jupyter_nbextensions_configurator \
        fastprogress \
	gitpython \
        h5py \
        ipyparallel \
        ipywidgets \
        jsonschema \
	numpy \
        pandas \
        pillow \
        seaborn \
        scikit-learn \
        scikit-image \
	scipy \
	tensorboard \
	tqdm \
        xeus-python \
 && conda clean -tipsy \
 && fix-permissions $CONDA_DIR \
 && fix-permissions /home/$NB_USER


RUN pip install --no-cache-dir torch==1.6.0 torchvision==0.7.0 -f https://download.pytorch.org/whl/torch_stable.html \
        datajoint \
 && fix-permissions $CONDA_DIR \
 && fix-permissions /home/$NB_USER

COPY requirements.txt /opt/app/requirements.txt
RUN pip install --no-cache-dir -r /opt/app/requirements.txt \
 && fix-permissions $CONDA_DIR \
 && fix-permissions /home/$NB_USER


RUN rm /usr/bin/python3 && ln -s /opt/conda/bin/python


RUN jupyter labextension install @jupyterlab/debugger


# switch back to default user (jovyan)
USER $NB_USER

