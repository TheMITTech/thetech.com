Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.synced_folder ".", "/home/vagrant/app"
    config.vm.network "forwarded_port", guest: 3000, host: 3000
    config.vm.provider 'virtualbox' do |v|
        v.memory = 2048
    end

    config.berkshelf.enabled = true
    config.berkshelf.berksfile_path = "./cookbooks/thetech-dev/Berksfile"

    config.vm.provision :chef_solo do |chef|
        chef.run_list = [
            'recipe[apt]',
            'recipe[thetech-dev::default]'
        ]
    end
end
