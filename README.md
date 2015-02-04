The MIT Tech
===============

Dependencies
------------

* Ruby 2.1.3 and gems in `Gemfile`
* ImageMagick
* PhantomJS

Setup
-----

* Migrate database with `rake db:migrate`.
* Add legacy database connection data to `config/database.yml`. The format is: 
```
legacy:
  host: 
  username: 
  password: 
  database: 
```
* Run the bootstrap script with `rake prefill:setup[NUM_OF_ISSUES_TO_IMPORT]`.
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
```