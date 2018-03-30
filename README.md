# workspace-configs

Domino workspace definitions.

DO NOT ADD SECRETS TO THIS REPOSITORY

Structure
Create a directory for each workspace application -- e.g. jupyter, rstudio.

In that directory, create these files:

install
A Bash script for installing the application and its required packages, and for adding static configuration files.

This script will be executed as root when building the Docker image for the environment that will offer this workspace application.

Make this file executable:

chmod +x install
init
An optional Bash script for configuring the workspace application just before it starts.

For instance, for creating a customized configuration file from a template, using environment variables.

This script will be executed as root in the post-setup script of a Domino run, when launching an workspace, so it will have access to write to any file.

Make this file executable:

chmod +x init
start
A Bash script for launching the workspace application.

This script must start the application's web server and block until that process is terminated.

It will be executed as a regular user as part of the run launch command.

Make this file executable:

chmod +x start
properties.yaml
This is a text file in YAML format specifying the Domino configuration properties for launching instances of this workspace.

etc
An optional directory containing any additional files that are required by the scripts mentioned above.

For instance, configuration files, or templates for generating configuration files.

Usage
Add to the Docker image a private key with read-only access to the workspaces git repository. E.g.:

RUN mkdir -p $HOME/.ssh
RUN ssh-keyscan github.com >> $HOME/.ssh/known_hosts
RUN echo "...(Base64-encoded key)..." | base64 -d >$HOME/.ssh/workspaces-deploy-key
RUN chmod 0400 $HOME/.ssh/*
Clone the workspaces git repository, with the desired release tag:

RUN ssh-agent bash -c "ssh-add $HOME/.ssh/workspaces-deploy-key; git clone --branch 2017-10-24 git@github.com:cerebrotech/workspaces.git /var/opt/workspaces"
In the "Properties for Notebooks" field, make reference to the full pathname of the scripts from the workspaces repository:

jupyter:
    title: "Jupyter (Python, R, Julia)"
    start: [ "/var/opt/workspaces/jupyter/start" ]
    httpProxy:
        port: 8888
        internalPath: /{{ownerUsername}}/{{projectName}}/{{sessionPathComponent}}/{{runId}}/
        rewrite: false
Good practices
Bash options
Start Bash scripts with these lines:

#!/bin/bash
set -o nounset -o errexit -o pipefail
