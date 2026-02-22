FROM ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    build-essential \
    libglib2.0-0 \
    libgl1 \
    libopengl0 \
    libegl1 \
    libegl1-mesa \
    libgl1-mesa-dri \
  && rm -rf /var/lib/apt/lists/* \
  && ldconfig

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

RUN uv tool install --python 3.11 sleap-nn[torch] --torch-backend auto