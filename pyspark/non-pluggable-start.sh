#!/bin/bash
set -o nounset -o errexit
IP_ADDR=$(/sbin/ifconfig eth0 | grep "inet addr" | cut -d ":" -f2 | cut -d " " -f1)

CONF_DIR="$HOME/.ipython/profile_default"
mkdir -p "${CONF_DIR}"

CONF_FILE="${CONF_DIR}/ipython_notebook_config.py"

PREFIX=/${DOMINO_PROJECT_OWNER}/${DOMINO_PROJECT_NAME}/notebookSession/${DOMINO_RUN_ID}/

# Check for Jupyter Notebook support for browsing to the root directory.
IPYTHON_VERSION=$(ipython --version)
function format_version { echo "$@" | awk -F. '{ printf("%03d%03d%03d", $1,$2,$3); }'; }
echo "IPython version: $IPYTHON_VERSION"
if which awk 1>/dev/null 2>/dev/null
then
  if [ $(format_version "$IPYTHON_VERSION") -lt $(format_version "4.2.0") ]
  then
    echo "Running a pre-4.2 IPython version."
    DOMINO_JUPYTER_ROOT_BROWSING_SUPPORTED="false"
  else
    echo "Running an IPython version more recent than 4.1."
    DOMINO_JUPYTER_ROOT_BROWSING_SUPPORTED="true"
  fi
else
  echo "awk is not available."
  DOMINO_JUPYTER_ROOT_BROWSING_SUPPORTED="true"
fi

echo "c = get_config()" >> "${CONF_FILE}"
echo "c.NotebookApp.base_url = '${PREFIX}'" >> "${CONF_FILE}"
echo "c.NotebookApp.base_kernel_url = '${PREFIX}'" >> "${CONF_FILE}"
echo "c.NotebookApp.tornado_settings = {'headers': {'Content-Security-Policy': 'frame-ancestors *'}, 'static_url_prefix': '${PREFIX}static/'}" >> "${CONF_FILE}"

if [ "$DOMINO_JUPYTER_ROOT_BROWSING_SUPPORTED" == "true" ]
then
  echo "Browsing to the root directory in Jupyter will be supported."
  echo "c.NotebookApp.notebook_dir = '${DRT_WORKING_DIR:-"/"}'" >> "${CONF_FILE}"
  echo "c.NotebookApp.default_url = '/tree${DOMINO_WORKING_DIR}'" >> "${CONF_FILE}"
else
  echo "Browsing to the root directory in Jupyter will not be supported."
  echo "c.NotebookApp.notebook_dir = '${DRT_WORKING_DIR:-"/mnt"}'" >> "${CONF_FILE}"
  # Subtract the base dir from the main project working dir to get the optional sub-path to redirect the user to
  MAIN_PROJECT_REDIRECT_DIR=${DOMINO_WORKING_DIR#"/mnt"}
  echo "c.NotebookApp.default_url = '/tree${MAIN_PROJECT_REDIRECT_DIR}'" >> "${CONF_FILE}"
fi

# Replace * in "--ip=*" with the actual IP address of the container
COMMAND='PYSPARK_DRIVER_PYTHON="ipython" PYSPARK_DRIVER_PYTHON_OPTS="notebook --ip=* " pyspark  2>&1'
FINAL_COMMAND=$(echo "${COMMAND}" | sed "s/--ip=\*/--ip=${IP_ADDR}/")

eval ${FINAL_COMMAND}
