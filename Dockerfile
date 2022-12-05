ARG CUDA_VER=11.4.0
ARG LINUX_VER=ubuntu18.04
FROM nvidia/cuda:${CUDA_VER}-base-${LINUX_VER} AS mambaforge-cuda

ARG PYTHON_VER=3.9
ENV PATH=/opt/conda/bin:$PATH
ENV PYTHON_VERSION=${PYTHON_VER}

COPY --from=condaforge/mambaforge:22.9.0-2 /opt/conda /opt/conda
RUN \
  # ensure conda environment is always activated
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh; \
  echo ". /opt/conda/etc/profile.d/conda.sh; conda activate base" >> /etc/skel/.bashrc; \
  echo ". /opt/conda/etc/profile.d/conda.sh; conda activate base" >> ~/.bashrc; \
  # install expected Python version
  mamba install -y python="${PYTHON_VERSION}"; \
  mamba update --all -y; \
  find /opt/conda -follow -type f -name '*.a' -delete; \
  find /opt/conda -follow -type f -name '*.pyc' -delete; \
  conda clean -afy;

FROM mambaforge-cuda AS mambaforge-cuda-rapids
ARG DEBIAN_FRONTEND=noninteractive
ARG LINUX_VER

RUN \
  case "${LINUX_VER}" in \
    "ubuntu"*) \
      apt-get update \
      && apt-get upgrade -y \
      && apt-get install -y --no-install-recommends \
        # needed by the ORC library used by pyarrow, because it provides /etc/localtime
        tzdata \
        # needed by dask
        libnuma1 libnuma-dev \
      && rm -rf "/var/lib/apt/lists/*"; \
      ;; \
    "centos"* | "rockylinux"*) \
      yum -y update \
      && yum -y install --setopt=install_weak_deps=False \
        # needed by dask
        numactl-devel numactl-libs \
      && yum clean all; \
      ;; \
    *) \
      echo "Unsupported LINUX_VER: ${LINUX_VER}" && exit 1; \
      ;; \
  esac
