ARG CUDA_VER=11.4.0
ARG IMG_TYPE=base
ARG LINUX_VER=ubuntu18.04
FROM nvidia/cuda:${CUDA_VER}-${IMG_TYPE}-${LINUX_VER} as base

FROM base as miniconda
ARG PY_VER=3.9
ARG TARGETARCH
ARG MINICONDA_VER=4.11.0
ARG LINUX_VER

SHELL ["/bin/bash", "-c"]
RUN \
  set -e; \
  if [[ "$TARGETARCH" == "amd64" ]]; then \
    ARCH="x86_64"; \
  elif [[ "$TARGETARCH" == "arm64" ]]; then \
    ARCH="aarch64"; \
  else \
    echo "invalid ARCH"; \
    exit 1; \
  fi; \
  if [[ "$LINUX_VER" == *ubuntu* ]]; then \
    apt-key adv \
      --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/${LINUX_VER/./}/${ARCH}/3bf863cc.pub"; \
    apt-get update && apt-get install -y \
      wget; \
    rm -rf /var/lib/apt/lists/*; \
  elif [[ "$LINUX_VER" == *centos* ]]; then \
    if [[ "$LINUX_VER" == "centos8" ]]; then \
      sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*; \
      sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*; \
    fi; \
    yum install -y wget; \
  else \
    echo "invalid OS"; \
    exit 1; \
  fi; \
  wget --quiet \
    -O miniconda.sh \
    https://repo.anaconda.com/miniconda/Miniconda3-py${PY_VER/./}_4.11.0-Linux-${ARCH}.sh; \
  bash miniconda.sh -b -p /opt/conda; \
  rm miniconda.sh; \
  . /opt/conda/etc/profile.d/conda.sh; \
  conda activate base; \
  # the following lines were copied from miniconda's own images
  /opt/conda/bin/conda clean -afy; \
  find /opt/conda/ -follow -type f -name '*.a' -delete; \
  find /opt/conda/ -follow -type f -name '*.js.map' -delete;

FROM base
ENV PATH=/opt/conda/bin:$PATH
COPY --from=miniconda /opt/conda /opt/conda
RUN \
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh; \
  echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc; \
  echo "conda activate base" >> ~/.bashrc
