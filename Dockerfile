ARG CUDA_VER=notset
ARG LINUX_VER=notset
FROM nvidia/cuda:${CUDA_VER}-base-${LINUX_VER}

ARG LINUX_VER
ARG PYTHON_VER
ARG DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/conda/bin:$PATH
ENV PYTHON_VERSION=${PYTHON_VER}

# Create a conda group and assign it as root's primary group
RUN groupadd conda; \
  usermod -g conda root

# Ownership & permissions based on https://docs.anaconda.com/anaconda/install/multi-user/#multi-user-anaconda-installation-on-linux
COPY --from=condaforge/miniforge3:23.11.0-0 --chown=root:conda --chmod=770 /opt/conda /opt/conda

# Ensure new files are created with group write access & setgid. See https://unix.stackexchange.com/a/12845
RUN chmod g+ws /opt/conda

RUN \
  # Ensure new files/dirs have group write/setgid permissions
  umask g+ws; \
  # install expected Python version
  mamba install -y -n base python="${PYTHON_VERSION}"; \
  mamba update --all -y -n base; \
  find /opt/conda -follow -type f -name '*.a' -delete; \
  find /opt/conda -follow -type f -name '*.pyc' -delete; \
  conda clean -afy;

# Reassign root's primary group to root
RUN usermod -g root root

RUN \
  # ensure conda environment is always activated
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh; \
  echo ". /opt/conda/etc/profile.d/conda.sh; conda activate base" >> /etc/skel/.bashrc; \
  echo ". /opt/conda/etc/profile.d/conda.sh; conda activate base" >> ~/.bashrc;

RUN case "${LINUX_VER}" in \
    "ubuntu"*) \
      apt-get update \
      && apt-get upgrade -y \
      && apt-get install -y --no-install-recommends \
        # needed by the ORC library used by pyarrow, because it provides /etc/localtime
        tzdata \
      && rm -rf "/var/lib/apt/lists/*"; \
      ;; \
  esac
