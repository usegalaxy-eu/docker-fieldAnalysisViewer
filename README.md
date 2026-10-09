# Field Analysis Viewer

A flexdashboard-based Shiny web application for field/spatial analysis, running inside Docker.

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [just](https://github.com/casey/just) (command runner)

## Quick start

```bash
just up
```

Then open <http://localhost:3838/app/>.

## Available commands

| Command        | Description                                    |
|----------------|------------------------------------------------|
| `just build`   | Build the Docker image                         |
| `just run`     | Run the container (detached)                   |
| `just up`      | Build and run                                  |
| `just stop`    | Stop and remove the container                  |
| `just logs`    | Follow the container logs                      |
| `just open`    | Open the app in the browser                    |
| `just clean`   | Remove container and image                     |

## The data file

The data file is **not** part of the image, it is mounted read-only into the
container at `/inputs/input.csv`.

The app checks for the file at startup: if it is present, the dashboard loads
it; if it is missing, a friendly warning page is shown instead, explaining how
to mount the file.

## Data file location

`just run` mounts `app/MASTER_SpATS_results.csv` from the host into the
container at `/inputs/input.csv`. To use a different file or location, adjust
the `data_file` variable in the `justfile`, or run Docker manually:

```bash
docker run -d --name fieldanalysisviewer-app \
  -i -t --rm 3838:3838 \
  -v $(pwd)/app/MASTER_SpATS_results.csv:/inputs/input.csv:ro \
  fieldanalysisviewer
```

