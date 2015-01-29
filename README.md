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
