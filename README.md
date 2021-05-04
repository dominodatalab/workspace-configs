# workspace-configs


# Usage

In your docker file, you are going to want to download this repo and then use the install scripts for the notebooks you'd like to use.
Make sure you using the latest tag/release (e.g. 2021q1-v1 in the example). **Do not use the develop branch.**
```bash
# Note: Make sure you are using the latest release if you'd like the latest version of the workspaces
# https://github.com/dominodatalab/workspace-configs/releases/latest
RUN mkdir -p /var/opt/workspaces && cd /tmp && \
    wget https://github.com/dominodatalab/workspace-configs/archive/2021q1-v1.zip && \
    unzip 2021q1-v1.zip && \
    cp -Rf workspace-configs-2021q1-v1/* /var/opt/workspaces && \
    rm -rf /var/opt/workspaces/workspace-logos /var/opt/workspaces/README.md && \
    rm -rf /tmp/workspace-configs-2021q1-v1 /tmp/2021q1-v1.zip
```

Following is an example to install a pluggable notebook in your base image.  
Add this to your Dockerfile instructions in the target Domino compute environments:
```bash
# Install Jupyter from workspaces
RUN chmod +x /var/opt/workspaces/jupyter/install && /var/opt/workspaces/jupyter/install
```

Add the `properties.yaml` to Pluggable notebook properties in the Domino compute environments.  
You can find the properties in corresponding notebook folder.
```yaml
jupyter:
  title: "Jupyter (Python, R, Julia)"
  iconUrl: "https://raw.github.com/dominodatalab/workspace-configs/develop/workspace-logos/Jupyter.svg?sanitize=true"
  start: [ "/var/opt/workspaces/jupyter/start" ]
  httpProxy:
    port: 8888
    rewrite: false
    internalPath: "/{{#if pathToOpen}}tree/{{pathToOpen}}{{/if}}"
```


# Project Structure

Create a directory for each workspace application -- e.g. jupyter, rstudio.

In that directory, create these files:

1. `install` - A Bash script for installing the application and its required packages, and for adding static configuration files.  
_This script will be executed as root when building the Docker image for the environment that will offer this workspace application._

2. `init` - An optional Bash script for configuring the workspace application just before it starts.
For instance, for creating a customized configuration file from a template, using environment variables.  
_This script will be executed as root in the post-setup script of a Domino run, when launching an workspace, so it will have access to write to any file._

3. `start` - A Bash script for launching the workspace application.
This script must start the application's web server and block until that process is terminated.  
_It will be executed as a regular user as part of the run launch command._

4. `properties.yaml` - This is a text file in YAML format specifying the Domino configuration properties for launching instances of this workspace.

5. `etc/` - An optional directory containing any additional files that are required by the scripts mentioned above.
For instance, configuration files, or templates for generating configuration files.

Make all of bash scripts files executable:
```bash
chmod +x install start start
```
