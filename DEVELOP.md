# Developing with Docker

## Setup

0. Clone the repository to your computer.

1. Install [Docker](https://docs.docker.com/install/). Choose your operating
system on the left sidebar, and follow the instruction.

2. In the root directory of the repo, run `docker-compose up`. Wait until you
see a line containing the sentence "Seed data importing finished" in the log
messages.

3. Now you should be able to access your website sandbox at
http://localhost:3000. You local changes to the code will automatically be
reflected in the sandbox. When you're done developing, you can simply use Ctrl-C
to stop the sandbox. To start the sandbox again, do `docker-compose start`.

## Usage

You can access the CMS backend at `http://localhost:3000/admin`. The default
admin account has email `admin@tech.mit.edu` and password `TheMITTech`.

Current limitations of the development box:

- Editing images (including uploading new images and deleting existing images)
  will not work. However, existing images should display normally on the
  development box website. Reach out to Techno Director if you need to work on
  related functionalities.

- Elasticsearch indices are not set up  by default. See section "(Optional) Set
  Up Elasticsearch Indices" for more details.

## Useful Docker Commands

- To shut down the sandbox: `docker-compose stop`
- To start up the sandbox again: `docker-compose start`
- To rebuild the sandbox: `docker-compose build`
- To remove the sandbox from your computer: `docker-compose down`
- To recreate a sandbox after removal: `docker-compose up`
- To enter the Rails console: `docker-compose exec web bundle exec rails console`
- To do a Rails database migration: `docker-compose exec web bundle exec rake db:migrate`
- To enter a container (`web`, `db`, `redis`, or `elasticsearch`):
`docker-compose exec CONTAINER_NAME /bin/bash`
- To run a command on a container that is not started (eg, `bundle update`): `docker-compose run <container name> bash`

Note: to install new gems, etc, within the docker container, you will likely need to run `bundle config --delete frozen` to allow editing the lockfile.

## (Optional) Set Up Elasticsearch Indices

By default, Elasticsearch indices are not created in the sandbox, since the
initial indexing can take quite a bit of time. Therefore, frontend search
functionalities will not work. If you need to work on related functionalities,
do the following to create the needed Elasticsearch indices:

```
$ docker-compose exec web rails console
> Article.reindex
> Image.reindex
```

To launch the rails console use this:

```
$ docker-compose exec web bundle exec rails console
```
