# miniforge-cuda

> [!IMPORTANT]
> `miniforge-cuda` images are now generated in https://github.com/rapidsai/ci-imgs. Please direct issues and pull requests to that repository.

A simple set of images that install [Miniforge](https://github.com/conda-forge/miniforge) on top of the [nvidia/cuda](https://hub.docker.com/r/nvidia/cuda) images.

These images are intended to be used as a base image for other RAPIDS images. Downstream images can create a user with the `conda` user group which has write access to the base conda environment in the image.

## `latest` tag

The `latest` tag is an alias for the Docker image that has the latest CUDA version, Python version, and Ubuntu version supported by this repository at any given time.
