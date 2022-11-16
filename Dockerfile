ARG CUDA_VER=11.4.0
ARG LINUX_VER=ubuntu18.04
FROM nvidia/cuda:${CUDA_VER}-base-${LINUX_VER}

ARG LINUX_VER
ARG PYTHON_VER=3.9
ENV PATH=/opt/conda/bin:$PATH
ENV PYTHON_VERSION=${PYTHON_VER}

COPY --from=condaforge/mambaforge:22.9.0-1 /opt/conda /opt/conda
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
  conda clean -afy; \
  case "${LINUX_VER}" in \
    "ubuntu"*) \
      apt-get update \
      && apt-get upgrade -y \
      && apt-get install -y --no-install-recommends \
        tzdata \
      && rm -rf "/var/lib/apt/lists/*"; \
      ;; \
    "centos"* | "rockylinux"*) \
      yum -y update \
      && yum clean all; \
      ;; \
    *) \
      echo "Unsupported LINUX_VER: ${LINUX_VER}" && exit 1; \
      ;; \
  esac
