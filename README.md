The MIT Tech
===============

Development Box (VM) Setup
-----------------------------

1. Install [Vagrant](https://www.vagrantup.com/downloads.html).
2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
3. Install [ChefDK](https://downloads.chef.io/chefdk).
4. Install Vagrant Berkshelf plugin: `vagrant plugin install vagrant-berkshelf`.
5. Launch your development box: `vagrant up`. This should take 5-15 minutes.
6. Connect to your development box: `vagrant ssh`.
7. In your development box, go to `~/app` and launch the Rails server: `cd app && bundle exec rails server`.
8. You can now access the website in your host machine at `http://localhost:3000`. First-time access is expected to be slow (around 10-20 seconds) due to the need to ramp-up various caches on the homepage.

The `~/app` directory in the development box is synced with the git repository directory on your host machine. This way you can work directly on the host machine, and have the changes synced into the development machine automatically.

You can access the CMS backend at `http://localhost:3000/admin`. The default admin account has email `admin@tech.mit.edu` and password `TheMITTech`.

Current limitations of the development box:

- Editing images (including uploading new images and deleting existing images) will not work. However, existing images should display normally on the development box website.
- ElasticSearch is not set up yet in the development box – hence frontend search functionalities will not work.

Development Workflow
--------------------

1. Make your awesome changes.
2. Add your changes to the Git staging area: `git add <changed_files>`.
3. Commit your changes: `git commit -m "Some message better than this"`.
4. Rebase your changes to make sure you're staying on top of the newest `dev` branch: `git pull --rebase origin dev`.
5. Push to the `dev` branch: `git push origin dev`
6. Ping the Techno Director, to have the changes merged into master, and deployed to the staging/production website.

Commonly Used Commands
----------------------

Unless otherwise specified, the following commands should be executed in the development box under the directory `~/app`.

1. Start the Rails server: `bundle exec rails server`.
2. Launch the Rails console: `bundle exec rails console`.
3. Open a PostgreSQL database console: `psql thetech-dev -h 127.0.0.1 -U thetech`.

Deployment Environment Variables
--------------------------------

The following environment variables should be set on staging/production servers (also note that `production` environment should be used for both staging and production):

```
# Amazon AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
S3_BUCKET
S3_HOST_NAME

# PostgreSQL database
DB_DATABASE
DB_HOST
DB_PASSWORD
DB_USERNAME

# Secret keys
DEVISE_SECRET_KEY
SECRET_KEY_BASE

# App configuration
RAILS_ENV
```
