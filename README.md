# sleap-docker-container

Docker image for running `sleap-nn` training and tracking workflows.

This container is designed primarily for running inside Pennsieve processors, where the platform provides `INPUT_DIR` and `OUTPUT_DIR`. It is also set up so the same behavior can be tested locally with `docker run`.

The entrypoint currently supports two modes:

- `train`
- `track`

Run all commands below from inside `sleap-docker-container/`.

## Build

```bash
docker build -t sleap-uv .
```

## Directory Layout

The local examples below assume this layout:

```text
data/
  input/
    sleap_config.yaml
    train.pkg.slp
    val.pkg.slp
  models/
    my_first_model/
  output/
```

## Train

This command runs:

```bash
sleap-nn train --config /app/input/sleap_config.yaml
```

Use:

```bash
docker run --rm -it \
  -e RUN_MODE=train \
  -e INPUT_DIR=/app/input \
  -e OUTPUT_DIR=/app/output \
  -e CONFIG=sleap_config.yaml \
  -v "$(pwd)/data/input":/app/input \
  -v "$(pwd)/data/":/app/output \
  sleap-uv
```

## Track

This command runs:

```bash
sleap-nn track \
  --data_path /app/input/val.pkg.slp \
  --model_paths /app/models/my_first_model/ \
  -o /app/output/val.predictions.slp
```

Use:

```bash
docker run --rm -it \
  -e RUN_MODE=track \
  -e INPUT_DIR=/app/input \
  -e OUTPUT_DIR=/app/output \
  -e MODEL_INPUT_DIR=/app/models \
  -e DATA_PATH=val.pkg.slp \
  -e MODEL_PATHS=my_first_model/ \
  -e O=val.predictions.slp \
  -v "$(pwd)/data/input":/app/input \
  -v "$(pwd)/data/models":/app/models \
  -v "$(pwd)/data/output":/app/output \
  sleap-uv
```

## Environment Variables

- `RUN_MODE`: `train` or `track`
- `INPUT_DIR`: base directory for config and input data
- `OUTPUT_DIR`: base directory for outputs and `-o`
- `CONFIG`: config file path relative to `INPUT_DIR` for `train`
- `DATA_PATH`: input file path relative to `INPUT_DIR` for `track`
- `MODEL_PATHS`: model directory path relative to `MODEL_INPUT_DIR` for `track`
- `MODEL_INPUT_DIR`: optional model base directory for `track`; defaults to `INPUT_DIR`
- `O`: output file path relative to `OUTPUT_DIR` for `track`

## Pennsieve Note

Pennsieve provides `INPUT_DIR` and `OUTPUT_DIR`. For Pennsieve, the preferred setup is to make all required tracking inputs available under `INPUT_DIR`. `MODEL_INPUT_DIR` is mainly useful for local Docker runs when models live outside the main input directory.
