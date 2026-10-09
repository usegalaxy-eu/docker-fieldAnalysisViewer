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
| `just r-packages` | List installed R packages in the image      |

## Project structure

```
.
├── Dockerfile      # two-stage build (package builder + runtime)
├── justfile        # build/run helper commands
├── README.md
└── app/
    ├── app.Rmd                   # the flexdashboard (runtime: shiny)
    └── MASTER_SpATS_results.csv  # data file (mounted into the container, not baked in)
```

## The data file

The data file is **not** part of the image — it is mounted read-only into the
container at `/inputs/input.csv` (handled automatically by `just run` / `just up`).

The app checks for the file at startup: if it is present, the dashboard loads
it; if it is missing, a friendly warning page is shown instead, explaining how
to mount the file.

## How the Dockerfile works

The build is split into two stages:

1. **Builder stage** — installs all R packages into `/usr/local/lib/R/site-library`,
   grouped into separate `RUN` layers (dashboard/rendering, data handling,
   interactive graphics, spatial statistics). If a new dependency is added to one
   group, only that layer rebuilds; all others come from the Docker cache.
2. **Runtime stage** — a fresh `rocker/shiny-verse` image that only receives the
   compiled package libraries and the app files, keeping the final image lean.

## Data file location

`just run` mounts `app/MASTER_SpATS_results.csv` from the host into the
container at `/inputs/input.csv`. To use a different file or location, adjust
the `data_file` variable in the `justfile`, or run Docker manually:

```bash
docker run -d --name fieldanalysisviewer-app \
  -p 3838:3838 \
  -v $(pwd)/app/MASTER_SpATS_results.csv:/inputs/input.csv:ro \
  fieldanalysisviewer
```

## Adding new R dependencies

Edit the appropriate `RUN` layer in the `Dockerfile` (or add a new one) and run
`just up`. Only the modified layers are rebuilt.
