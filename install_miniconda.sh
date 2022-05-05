#!/bin/bash
set -e
ARCH=$(uname -p)

if [[ "$LINUX_VER" == *ubuntu* ]]; then
  apt-key adv \
    --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/${LINUX_VER/./}/${ARCH}/3bf863cc.pub"
  apt-get update && apt-get install -y \
    wget
  rm -rf /var/lib/apt/lists/*
elif [[ "$LINUX_VER" == *centos* ]]; then
  if [[ "$LINUX_VER" == "centos8" ]]; then
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*
  fi
  yum install -y wget
else
  echo "invalid OS"
  exit 1
fi

wget --quiet \
  -O miniconda.sh \
  https://repo.anaconda.com/miniconda/Miniconda3-py${PY_VER/./}_${MINICONDA_VER}-Linux-${ARCH}.sh
bash miniconda.sh -b -p /opt/conda
rm miniconda.sh
. /opt/conda/etc/profile.d/conda.sh
conda activate base
# the following lines were copied from miniconda's own images
/opt/conda/bin/conda clean -afy
find /opt/conda/ -follow -type f -name '*.a' -delete
find /opt/conda/ -follow -type f -name '*.js.map' -delete
