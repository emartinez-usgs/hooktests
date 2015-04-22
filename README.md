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

  > NB: These scripts have limited functionality soliving a specific problem.
  > This should not be seen as a generalized solution.


Installation Instructions
-------------------------

There is a tight coupling between the static content system and the integration
system. As such, both the static content and integration systems must be
configured before trying to test this auto-deployment scheme. Steps for the
production system may be done at any point.

### Prerequisites

Each system in the auto-deploy scheme must be able to run BASH scripts and
must have git installed. They require active internet connections and must
be able to access the github.com host using ports 22 (static content) and
443 (integration/production).

### Static Content System

- Clone the project onto the development system.
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
- Install the post-commit.sh hook from this project into the target project.
  - This is typically: ```project/.git/hooks/post-commit```
  - This script must be executable.

### Integration System

- Configure the ```deployUser``` to be able to log in using SSH from the
  static content system without needing a password.
  - Public keypairs work great for this!
- Clone the project onto the integration system.
  - The origin remote should be configured such that the ```deployUser``` is
    able to pull changes from the origin remote without a password.


### Production System

- Clone the project onto the production system.
  - The origin remote should be configured such that the ```deployUser``` is
    able to pull changes from the origin remote without a password.
- Check out the production branch on the local repository clone.
- Configure the ```deployUser``` to be able to pull updates from the origin
  remote *product* branch into the local repository clone.
  - This is largely just ensuring proper file system access to update files.
- Create a cron job for the ```deployUser``` to pull updates on a regular
  interval.
```
*/5 * * * * (cd <deployPath> && git pull origin production)
```

  > Note: Replace ```<deployPath>``` with fully-qualified path to the local
  > repository clone in the file system.
