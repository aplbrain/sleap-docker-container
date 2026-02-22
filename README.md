# sleap-docker-container

This repository stores a containerized version of the [`sleap-nn`](https://nn.sleap.ai/latest/) library, a standalone package for PyTorch-based training/inference pipelines. The layout of this repository follows the guidance for creating [applications in Pennsieve](https://github.com/Penn-I3H/python-application-template), to enable running SLEAP workflows through the Pennsieve platform.

### Requirements
- Docker
- (Optional) NVIDIA GPU + NVIDIA Container Toolkit

### Build the Docker Image

From the root of the repository:

`docker build -t sleap-uv .`

### Run the Container (Interactive Shell)

Mount a local `data` directory into the container:

```
docker run --rm -it \
  -v "$(pwd)/data":/workspace \
  sleap-uv \
  bash
```

Inside the container:

```
cd /workspace
sleap-nn --help
```

### Run `sleap-nn` Directly

Instead of launching a shell, you can run commands directly:

```
docker run --rm -it \
  -v "$(pwd)/data":/workspace \
  sleap-uv \
  sleap-nn predict --help
```

All input/output files should live in the mounted directory (`/workspace`) so results persist on the host.

### GPU Usage

If running on a machine with an NVIDIA GPU:

```
docker run --rm -it \
  --gpus all \
  -v "$(pwd)/data":/workspace \
  sleap-uv \
  sleap-nn train ...
```
