# {{cookiecutter.project_name}} Docker Environment

This Docker Environment allows you to develop Odoo for {{cookiecutter.project_name}} within a Docker container.

## Get started

To start using this environment, you need to clone this repository in your local machine

```
$ git clone git@github.com:{{cookiecutter.github_repo_user}}/{{cookiecutter.github_repo_name}}.git
```

Then run it:

```
$ docker-compose up -d
```

## Configuration tuning

To edit configuration, just change etc/odoo.conf, which is a standard odoo configuration file, then restart the container. `addons_path` will be automatically derived from your addons repo and the conffile will be generated before starting odoo. All other options will be taken from this file.

## Add new addons

To add new addons, add them as submodules to your addons repo and rebuild/recreate your image/container `odoo_conf_generator.py` will automatically pick them up and add  themeto the Odoo configuration file at runtime.

## Add new Python dependencies

To add new Python dependencies, add them to the file `requirements.txt` if it is related to this specific Docker Environment, or to the same file in your addons repo if it's related to Odoo and your specific project. Then rebuild and recreate your images and containers.

## Odoo Shell

You can start an Odoo shell by launching `docker-compose run --rm odoo shell -d {{cookiecutter.project_code}}

## Debugging

There are times when you need to make some debug and maybe you need to put a breakpoint somewhere. This can be done by adding new `volumes` to the odoo container. For example, if you want to add a breakpoint in your own code, run :

```
git clone https://{{cookiecutter.github_token}}@github.com/{{cookiecutter.github_addons_repo_user}}/{{cookiecutter.github_addons_repo_name}}.git
```

and then uncomment the volume line already available in the `docker-compose.yml` file:

```
...
volumes:
  ...
  - "./{{cookiecutter.github_addons_repo_name}}:/parts/project_addons"
```

Then, to have the interpreter available to you when the breakpoint is catched, just run docker-compose run:

```
docker-compose run --rm --service-ports odoo
```

## About

This Docker Environment has been built with ROCCO, the Rapsodoo Original CookieCutter for Odoo. For more information: https://www.github.com/saydigital/rocco.
