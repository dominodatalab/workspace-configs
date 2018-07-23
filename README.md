# workspace-configs

# Usage


In your docker file, you are going to want to download this repo and then use the install scripts for the notebooks you'd like to use. Make sure you using the latest tag/release (e.g. v1.11 in the example). Do not use the develop branch. 
```
#Clone in workspaces install scripts
RUN mkdir /var/opt/workspaces

#note: Make sure you are using the latest release if you'd like the latest version of the workspaces
#https://github.com/dominodatalab/workspace-configs/releases
RUN  cd /tmp && wget https://github.com/dominodatalab/workspace-configs/archive/2018q2-v1.11.zip && unzip 2018q2-v1.11.zip  && cp -Rf workspace-configs-2018q2-v1.11/. /var/opt/workspaces && \
rm -rf /var/opt/workspaces/workspace-logos && rm -rf /tmp/workspace-configs- 2018q2-v1.11

```




Following is an example to install a pluggable notebook in your base image - 

Add to dockerfile instructions in Domino compute environments - 
```
####Install Jupyter from workspaces
RUN chmod +x /var/opt/workspaces/jupyter/install
RUN /var/opt/workspaces/jupyter/install
```

Add to Pluggable notebook properties in Domino compute environments - 
You can find the properties in properties.yaml file. (check the notebook folder for corresponding properties)

```
jupyter:
  title: "Jupyter (Python, R, Julia)"
  iconUrl: "https://raw.github.com/dominodatalab/workspace-configs/develop/workspace-logos/Jupyter.svg?sanitize=true"
  start: [ "/var/opt/workspaces/jupyter/start" ]
  httpProxy:
    port: 8888
    rewrite: false
    internalPath: "/{{#if pathToOpen}}tree/{{pathToOpen}}{{/if}}"
  supportedFileExtensions: [ ".ipynb" ]
```



# Structure
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


