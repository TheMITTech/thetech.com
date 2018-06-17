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

Unless otherwise specified, these commands should be executed in the development box under the directory `~/app`.

1. Start the Rails server: `bundle exec rails server`.
2. Launch the Rails console: `bundle exec rails console`.
3. Open a PostgreSQL database console: `psql thetech-dev -h 127.0.0.1 -U thetech`.

Dependencies
------------

* Ruby 2.1.3 and gems in `Gemfile`.
You may want to try using `rvm`, Ruby version manager, to install Ruby 2.1.3 if there are other versions present on your system.
* Mysql (needed to parse the old website's database)
* ImageMagick
* PhantomJS

There are some more fundamental dependencies. For those, on ubuntu, use these commands (similar command on other systems, probably). This should make the install process a lot easier:

```
sudo apt-get install postgressql postgresql-contrib
sudo apt-get install mysql-client libmysqlclient-dev
sudo apt-get install libmagickwand-dev
rake acts_as_taggable_on_engine:install:migrations
```

Setup
-----
Create the `config/database.yml` file. A pre-setup version can be found in the Tech athena locker under `techno`. Do not change the legacy database connection settings — it will be used to log into the old website and pull old content.

##### Postgresql

After installing dependencies and the `database.yml` file, you need to set up a Postgresql database on your machine.

Create a Postgresql user that matches the name in the `username` field of your config file, and give it `createdb` permissions. You can see how to do this in the Postgresql docs — `createuser -d [name]` should work.

Then you can create the database with `rake db:create`.

Next:
* Migrate database with `rake db:migrate`.
* If not already there, add legacy database connection data to `config/database.yml`. The format is:
```
legacy:
  host:
  username:
  password:
  database:
```

* You will need to create a root account, 6 sections, 1 issue, and a homepage for the site to render properly. You can run `rake prefill:setup` to do all these tasks for you.

* Start the rails server with `rails s`. The app can now be reached at `localhost` on default port `3000`.
* From there, you can sign in into the system with the default admin account `admin@mit.edu` and password `themittech`.

Application Role
----------------

In real use, two copies of this application should be deployed. One as the "frontend" version, and the other as the "backend" version. In the frontend version, all the non-frontend controllers (aka. the admin controllers) would be disabled (by throwing HTTP Error 404), and database access would be limited to read-only on an ActiveRecord level.

In order to designate which role a particular deployment should be, create ``config/application.yml`` and put in the following content:

```
tech_app_role: 'backend' # or 'frontend'
```

or equivalently, set an environment variable named ``tech_app_role`` to either ``backend`` or ``frontend``.

Deployment Environment Variables
--------------------------------

The following environment variables should be set on staging/production servers (also note that ``production'' environment should be used for both staging and production):

```
# Amazon AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

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
S3_BUCKET
S3_HOST_NAME
TECH_APP_ROLE
TECH_APP_FRONTEND_HOSTNAME # if TECH_APP_ROLE is false, e. g. http://tech.mit.edu
VARNISH_USED
VARNISH_HOST_NAME
LEGACY_REDIRECT_DOMAIN_NAME # e.g. http://tech-legacy.mit.edu
```
