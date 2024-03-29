FROM odoo:{{cookiecutter.odoo_version}}
LABEL maintainer={{cookiecutter.git_email}}

# Switch to super user to perform privileged operatiosn
USER root

# Change this value to regenerate the whole image
ENV _UPDATED 2022-04-08

# Install missing useful stuff
RUN apt-get update && apt-get install -y git vim curl wget python3-wheel build-essential python3-dev libffi-dev

# Create needed paths
ENV PARTS_PATH /parts
ENV ROCCO_PATH /rocco
# This custom odoo data path is needed as the Odoo Docker images path causes issues when re-declared as volume in the composefile
ENV DATA_PATH /var/odoo
ENV PROJECT_ADDONS_PATH $PARTS_PATH/project_addons
ENV ENTERPRISE_PATH $PARTS_PATH/enterprise
# This path can be used to mount the submodule during development,
# before making them active on the remote repo
ENV DUMMY_SUBMODULE_PATH $PARTS_PATH/dummy_submodule
RUN mkdir -m 777 -p $DATA_PATH $ROCCO_PATH $PROJECT_ADDONS_PATH $ENTERPRISE_PATH $DUMMY_SUBMODULE_PATH
RUN chown -R odoo:odoo $ROCCO_PATH $PARTS_PATH $DATA_PATH

# Install Python libraries
COPY requirements.txt requirements.txt
RUN python3 -m pip install -r requirements.txt

# Switch back to the standard user
USER odoo

# Clone code and chage submodules urls to use the provided GitHub token
RUN git clone --depth=1 -b {{cookiecutter.github_addons_repo_branch}} https://{{cookiecutter.github_token}}@github.com/{{cookiecutter.github_addons_repo_user}}/{{cookiecutter.github_addons_repo_name}}.git $PROJECT_ADDONS_PATH
RUN git clone --depth=1 -b {{cookiecutter.odoo_version}} https://{{cookiecutter.github_token}}@github.com/odoo/enterprise.git $ENTERPRISE_PATH
ADD bin/ $ROCCO_PATH/bin
RUN python3 $ROCCO_PATH/bin/submodules_processor.py $PROJECT_ADDONS_PATH {{cookiecutter.github_token}}

# It looks like Python requirements must be installed as root, otherwise odoo (the software) won't see them if we install them as odoo (user) :-|
USER root
# Install Addons Repo Requirements, this will drill down and find all requirements files
RUN find "$PROJECT_ADDONS_PATH" -name "requirements.txt" -exec pip3 install -r {} \;
# Switch back to the standard user again
USER odoo

# Configure git, just in case
RUN git config --global user.email "{{cookiecutter.git_email}}"; \
    git config --global user.name "{{cookiecutter.git_name}}"

# Override the standard entry point to generate the odoo conf file at runtime
COPY ./entrypoint.sh /
