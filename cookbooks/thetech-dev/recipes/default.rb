################################################################################
# Sets up Ruby, Rails, and Gems
################################################################################

ruby_runtime 'thetech' do
    provider :ruby_build
    version '2.2.6'
end

file "/home/vagrant/.bash_profile" do
    content "export PATH=/opt/ruby_build/builds/thetech/bin:$PATH\n"
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
    createdb true
end

postgresql_database 'thetech' do
    owner 'thetech'
end
