set shell := ["bash", "-uc"]

image := "fieldanalysisviewer"
container := "fieldanalysisviewer-app"
port := "3838"
data_file := "app/MASTER_SpATS_results.csv"

# list available commands
default:
    @just --list

# build the docker image
build:
    docker build -t {{image}} .

# run the container (detached), replacing any existing one; mounts the data file
run:
    docker rm -f {{container}} 2>/dev/null || true
    docker run -d --name {{container}} -p {{port}}:3838 \
      -v {{justfile_directory()}}/{{data_file}}:/inputs/input.csv:ro \
      {{image}}

# build and then run
up: build run

# stop and remove the container
stop:
    docker rm -f {{container}} 2>/dev/null || true

# show container logs
logs:
    docker logs -f {{container}}

# open the app in the browser
open:
    xdg-open http://localhost:{{port}}/app/

# clean up container and image
clean: stop
    docker rmi {{image}} 2>/dev/null || true
