ARG CUDA_VER=11.4.0
ARG IMG_TYPE=base
ARG LINUX_VER=ubuntu18.04
FROM nvidia/cuda:${CUDA_VER}-${IMG_TYPE}-${LINUX_VER} as base

FROM base as miniconda
ARG LINUX_VER
ARG MINICONDA_VER=4.11.0
ARG PY_VER=3.9

COPY install_miniconda.sh .
RUN bash /install_miniconda.sh

FROM base
ENV PATH=/opt/conda/bin:$PATH
COPY --from=miniconda /opt/conda /opt/conda
RUN \
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh; \
  echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc; \
  echo "conda activate base" >> ~/.bashrc
