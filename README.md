# ROCCO: the Rapsodoo Original CookieCutter for Odoo
## A long and durable piece of software

ROCCO is your swiss-army knife to build Docker Environments for Odoo. It has been designed to replicate odoo.sh projects locally by just providing a valid GitHub Token and the main GitHub repo. Once ROCCO has done all its magic, you can `docker-compose up` a perfect replica of your odoo.sh project, submodules included. It can also be used the other way around, that is: to build a Docker Environments uwith an addons repo that will eventually build an odoo.sh project.

ROCCO is based on the standard Odoo Docker images, and comes with Odoo Enterprise included by default. In case you don't want to use Odoo Enterprise, just comment out the corresponding line in the Dockerfile once you have built your docker-env. In the same way, feel free to customize the resulting template at your wish if you need to change its behaviour.

## Usage

Install [cookiecutter](http://cookiecutter.readthedocs.io/):
```bash
python3 -m pip install cookiecutter
```

Then run cookicutter passing it the directory containing this template
```bash
python3 -m cookiecutter .
```

You will be asked a few parameters, including the name and organization for both the addons repo and the docker-env repo. Then, the actual docker-env folder will be available for you. It will be automatically linked to the project addons repo you entered.

## Caveats
- A proxy server is not provided by the docker-compose orchestration.
- Accessing different submodules/repos with different github tokens (or with other mean of authentication) is not possible at the moment.
- Submodules are added to the odoo configuration addons_path in alphabetical order. This is meant to reproduce an undocumented feature of Odoo.sh

## FIXME
- Permissions of the filestore directory are not properly handled. This may result in Odoo not being able to respond to HTTP requests. You can try and manually set permissions on the running container to work around this problem until I fix it once and for all.
- Submodules whose path inside the addons repo doesn't match their github repo name are not properly handled. This will be fixed in a future release.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Credits
Thanks to Francesco Apruzzese for providing the name of this long and durable piece of software.

ROCCO is based on ideas inspired by several different people of several different companies. Thank you all for sharing ideas, concepts, technologies and hints for this tool.

## License
Copyright 2021 Andrea Colangelo <andrea.colangelo@gmail.com>.
This software is released under the terms of the
[WTFPL](http://www.wtfpl.net/txt/copying/).
