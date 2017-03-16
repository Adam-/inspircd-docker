#!/bin/sh

# Fail fast
set -e

# Some useful functions. See https://www.shivering-isles.com/helpful-shell-snippets-for-docker-testing-and-bootstrapping/
command_exists() { command -v $1 >/dev/null 2>&1 || { echo >&2 "I require $1 but it's not installed.  Aborting."; exit 1; }; }
docker_installed() { command -v docker >/dev/null 2>&1 || { wget -O- http://get.docker.com | sh - ; }; command -v docker >/dev/null 2>&1 || { echo >&2 "I require docker but it's not installed and I can't install it myself.  Aborting."; exit 1; }; }

command_exists wget
docker_installed

# Check to make sure we can talk to the docker daemon
[ -w /var/run/docker.sock ] || SUDO=sudo

# Default run parameter
RUNPARAM="-d"

# Check for available ports
[ $(netstat -an | grep LISTEN | grep :6667 | wc -l) -eq 0 ] && RUNPARAM="$RUNPARAM -p 6667:6667" || RUNPARAM="$RUNPARAM -p 6667" echo "exposing 6667 on random port. Check \'docker ps\' for details"
[ $(netstat -an | grep LISTEN | grep :6697 | wc -l) -eq 0 ] && RUNPARAM="$RUNPARAM -p 6697:6697" || RUNPARAM="$RUNPARAM -p 6697" echo "exposing 6697 on random port. Check \'docker ps\' for details"

$SUDO docker run $RUNPARAM inspircd/inspircd-docker
