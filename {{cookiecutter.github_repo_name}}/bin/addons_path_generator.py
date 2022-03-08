#!/usr/bin/env python3
# Copyright 2021 Andrea Colangelo <andrea.colangelo@gmail.com>.
# This software is released under the terms of the WTFPL (http://www.wtfpl.net/txt/copying/).

import os
import sys

from configparser import ConfigParser
from git import Repo
import yaml

ADDONS_PATH = sys.argv[1]
ENTERPRISE_PATH = sys.argv[2]
DUMMY_SUBMODULE_PATH = sys.argv[3]
OODO_CONF_TEMPLATE_PATH = sys.argv[4]
ODOO_CONF_PATH = sys.argv[5]

if __name__ == '__main__':
    os.chdir(ADDONS_PATH)
    repo = Repo()

    submodules = [
        os.path.join(ADDONS_PATH, submodule.path)
        for submodule
        in repo.iter_submodules()
    ]
    # Sorting is needed to simulate an undocumented feature of odoo.sh and let
    # this docker-env behave just like that
    paths = [ADDONS_PATH, ENTERPRISE_PATH, DUMMY_SUBMODULE_PATH]
    if submodules:
        submodules = ','.join(sorted(submodules))
        paths.append(submodules)
    # Check YAML FILE if custom PATHS are inserted
    with open('/rocco/etc/extra_addons_path.yaml', 'r') as extra_addons_path:
        extra_addons_file = yaml.load(extra_addons_path, Loader=yaml.FullLoader)
        extra_addons_list = extra_addons_file.get("addons_path")
        if extra_addons_list:
            paths.extend(extra_addons_list)
    # Generate the comma-separated addons path
    addons_path = ','.join(paths)

    parser = ConfigParser()
    parser.read(OODO_CONF_TEMPLATE_PATH)
    parser.set('options', 'addons_path', addons_path)
    with open(ODOO_CONF_PATH, 'w') as odoo_conf_file:
        parser.write(odoo_conf_file)
