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