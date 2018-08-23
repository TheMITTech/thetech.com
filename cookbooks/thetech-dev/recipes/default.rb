################################################################################
# Sets up Ruby, Rails, and Gems
################################################################################

ruby_runtime 'thetech' do
    provider :ruby_build
    version '2.2.6'
end

file "/home/vagrant/.bash_profile" do
    content <<-HEREDOC
export PATH="/opt/ruby_build/builds/thetech/bin:$PATH"

export S3_BUCKET="thetech-production"
export S3_HOST_NAME="s3.amazonaws.com"
HEREDOC

    owner 'vagrant'
    group 'vagrant'
    mode 00644
end

apt_package 'libmagickwand-dev'
apt_package 'imagemagick'
apt_package 'libmysqlclient-dev'
apt_package 'libpq-dev'

ENV['PKG_CONFIG_PATH'] = '/usr/lib/x86_64-linux-gnu/pkgconfig/'

bundle_install '/home/vagrant/app/Gemfile' do
    vendor '/home/vagrant/bundle'
    user 'vagrant'
end

################################################################################
# Sets up redis
################################################################################

include_recipe 'redisio::default'
include_recipe 'redisio::enable'

################################################################################
# Sets up the database
################################################################################

postgresql_server_install 'Installing postgresql 9.6' do
    version '9.6'
    port 5432
end

postgresql_user 'thetech' do
    password 'TheMITTech'
    superuser true
end

postgresql_database 'thetech-dev' do
    owner 'thetech'

    # Workaround for idempotency bug: https://github.com/sous-chefs/postgresql/issues/533
    not_if '/usr/bin/psql -h 127.0.0.1 -U thetech --list | grep thetech-dev', user: 'vagrant'
end

file "/home/vagrant/.pgpass" do
    content <<-HEREDOC
127.0.0.1:5432:thetech-dev:thetech:TheMITTech
127.0.0.1:5432:postgres:thetech:TheMITTech
HEREDOC

    owner 'vagrant'
    group 'vagrant'
    mode 00600
end

execute 'import_dev_seed' do
    command '/usr/bin/pg_restore -O -h 127.0.0.1 -d thetech-dev -U thetech /home/vagrant/app/docker/db/dev-seed.dump'
    user 'vagrant'

    not_if '/usr/bin/psql thetech-dev -h 127.0.0.1 -U thetech -c "select count(*) from users"', user: 'vagrant'
end

file "/home/vagrant/app/config/database.yml" do
    content <<-HEREDOC
development:
  adapter: postgresql
  encoding: unicode
  database: thetech-dev
  pool: 5
  host: 127.0.0.1
  username: thetech
  password: TheMITTech
HEREDOC

    owner 'vagrant'
    group 'vagrant'
    mode 00644
end

################################################################################
# Sets up ElasticSearch
################################################################################

node.default['java']['install_flavor'] = 'openjdk'
node.default['java']['jdk_version'] = '8'

include_recipe 'java'

elasticsearch_user 'elasticsearch'
elasticsearch_install 'elasticsearch' do
    version '5.6.9'
end
elasticsearch_configure 'elasticsearch'
elasticsearch_service 'elasticsearch'
