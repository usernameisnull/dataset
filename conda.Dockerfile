FROM m.daocloud.io/docker.io/python:3.13
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/miniforge.sh \
        && bash /tmp/miniforge.sh -b -p $CONDA_DIR \
        && rm /tmp/miniforge.sh \
        && conda clean -afy