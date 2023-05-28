#!/bin/bash

# For Docker Installation
sudo apt update -y && sudo apt upgrade -y
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER && newgrp docker
