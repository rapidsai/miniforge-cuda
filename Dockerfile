ARG CUDA_VER=11.4.0
ARG IMG_TYPE=base
ARG LINUX_VER=ubuntu18.04
FROM nvidia/cuda:${CUDA_VER}-${IMG_TYPE}-${LINUX_VER}

ARG PY_VER=3.9
ENV PATH=/opt/conda/bin:$PATH

COPY --from=condaforge/mambaforge:4.12.0-0 /opt/conda /opt/conda
RUN \
  # ensure conda environment is always activated
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh; \
  echo ". /opt/conda/etc/profile.d/conda.sh; conda activate base" >> /etc/skel/.bashrc; \
  echo ". /opt/conda/etc/profile.d/conda.sh; conda activate base" >> ~/.bashrc; \
  # install expected Python version
  mamba install -y python="${PY_VER}"; \
  find /opt/conda -follow -type f -name '*.a' -delete; \
  find /opt/conda -follow -type f -name '*.pyc' -delete; \
  conda clean -afy
