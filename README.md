# The MIT Tech

## Development Setup

The recommended way to develop on this website is to use Docker. See
[DEVELOP.md](DEVELOP.md) for more details.

## Development Workflow

1. Make your awesome changes.
2. Add your changes to the Git staging area: `git add <changed_files>`.
3. Commit your changes: `git commit -m "Some message better than this"`.
4. Rebase your changes to make sure you're staying on top of the newest `dev` branch: `git pull --rebase origin dev`.
5. Push to the `dev` branch: `git push origin dev`
6. Ping the Techno Director, to have the changes merged into master, and deployed to the staging/production website.

## Deployment Environment Variables

The following environment variables should be set on staging/production servers (also note that `production` environment should be used for both staging and production):

```
# Amazon AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
S3_BUCKET
S3_HOST_NAME

# Service URLs
REDIS_URL
POSTGRES_URL
ELASTICSEARCH_URL

# Secret keys
DEVISE_SECRET_KEY
SECRET_KEY_BASE

# App configuration
RAILS_ENV
```
