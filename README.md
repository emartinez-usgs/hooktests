hooktests
=========

This project provides simple scripts to help automate deployment of simple
content from a development system through an integration (testing) system
and ultimately to a production environment.

The high-level concept is that work can be completed on the development server,
once this work is complete, the developer commits the work to the local
git repository. Upon commit (post-commit hook) pushes the changes back to
the origin repository then accesses a configured set of integration systems
onto which the updates are pulled back down.

For release, a release manager should create a pull request from the master
branch to the production branch. The production branch is what is running
on the production server (surprise!). When the pull request is merged to
the production branch, the production server will automatically fetch this
content on regular interval.

**NB: These scripts have limited functionality soliving a specific problem. This
should not be seen as a generalized solution.**


Installation Instructions
----------------------

### Static Content System

- Check out the project onto the development system.
  - The origin remote should be configured such that any developer can push
    changes directly to the master branch.
- Create a post-commit.config file in the project hooks directory.
  - This is typically: ```project/.git/hooks/post-commit.config```
  - This script is a shell script that should be source-able by BASH.
  - You must define the following three variables in the configuration file:
    - **deployHosts** : A comma-separated string listing the FQDN for each host
      to which commits should be automatically pushed.
    - **deployPath** : A string indicating the absolute path to the project
      root directory on each deploy host. This must be the same
      on each deploy host.
    - **deployUser** : This is the user that logs into each configured deploy
      host to pull the content from the origin remote.
- Configure each deploy host.
  - Each deploy host must have a copy of the project cloned locally into the
    configured deployPath.
  - The local clone on each deploy host must use an origin remote that allows
    for passwordless pulls from the origin.
  - Each deploy host must allow the deployUser to log in and execute
    git commands without a password.
- Install the post-commit.sh hook from this project into the target project.
  - This is typically: ```project/.git/hooks/post-commit```
  - This script must be executable.


### Integration System
TODO


### Production System
TODO
