#!/usr/bin/env python3
# Copyright 2021 Andrea Colangelo <andrea.colangelo@gmail.com>.
# This software is released under the terms of the WTFPL (http://www.wtfpl.net/txt/copying/).

import os
import subprocess
import sys

from git import Repo

ADDONS_PATH = sys.argv[1]
GITHUB_TOKEN = sys.argv[2]

if __name__ == '__main__':
    os.chdir(ADDONS_PATH)
    repo = Repo()
    for submodule in repo.iter_submodules():
        if submodule.url.startswith("git@"):
            # All github SSH repos are like git@github.com:<repo_name>.git
            starting_index = submodule.url.find(":") + 1
            repo_infos_str = submodule.url[starting_index:]
            key = f'submodule "{submodule.name}"'
            value = f'https://{GITHUB_TOKEN}@github.com/{repo_infos_str}'
            repo.config_writer().set_value(key, 'url', value).release()
    # This must be necessarily done via subprocess because GitPython will use
    # the URL found in .gitmodules
    os.system('git submodule update --init')
