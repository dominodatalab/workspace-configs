#!/bin/bash
set -o nounset -o errexit

CONF_DIR="$HOME/.ipython/profile_default"
mkdir -p "${CONF_DIR}"

CONF_FILE="${CONF_DIR}/ipython_notebook_config.py"
PREFIX=/${DOMINO_PROJECT_OWNER}/${DOMINO_PROJECT_NAME}/notebookSession/${DOMINO_RUN_ID}/

cat >> $CONF_FILE << EOF
c = get_config()
c.NotebookApp.notebook_dir = '${DRT_WORKING_DIR:-"/mnt"}'
c.NotebookApp.base_url = '${PREFIX}'
c.NotebookApp.base_kernel_url = '${PREFIX}'
c.NotebookApp.base_project_url = '${PREFIX}'
c.NotebookApp.tornado_settings = {'headers': {'Content-Security-Policy': 'frame-ancestors *'}, 'static_url_prefix': '${PREFIX}static/'}
c.NotebookApp.default_url = '/lab'
c.NotebookApp.token = u''
EOF
                                                                                                                                    
COMMAND='jupyter-lab --config="$CONF_FILE" --no-browser --ip="0.0.0.0" 2>&1'
eval ${COMMAND}                                                                                                               