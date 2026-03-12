#!/bin/bash

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source ${CURDIR}/reboot-router/.venv/bin/activate

#pip install -r ${CURDIR}/reboot-router/requirements.txt

python ${CURDIR}/reboot-router/python/main.py
