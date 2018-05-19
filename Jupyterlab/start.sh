#!/bin/bash
set -o nounset -o errexit

IP_ADDR=$(/sbin/ifconfig eth0 | grep "inet addr" | cut -d ":" -f2 | cut -d " " -f1)
CONF_DIR="$HOME/.ipython/profile_default"
mkdir -p "${CONF_DIR}"

CONF_FILE="${CONF_DIR}/ipython_notebook_config.py"
PREFIX=/${DOMINO_PROJECT_OWNER}/${DOMINO_PROJECT_NAME}/notebookSession/${DOMINO_RUN_ID}/

cat >> $CONF_FILE << EOF
c = get_config()
c.LabApp.notebook_dir = '${DRT_WORKING_DIR:-"/"}'
c.LabApp.tornado_settings = {'headers': {'Content-Security-Policy': 'frame-ancestors *'}, 'static_url_prefix': '${PREFIX}static/'}
c.LabApp.base_url = '${PREFIX}'
c.LabApp.default_url = '/lab/tree${DOMINO_WORKING_DIR}'
c.LabApp.token = u''
EOF
                                                                                                                                    
COMMAND='jupyter-lab --config="$CONF_FILE" --no-browser --ip=* 2>&1'
FINAL_COMMAND=$(echo "${COMMAND}" | sed "s/--ip=\\*/--ip=${IP_ADDR}/")

eval ${COMMAND}

