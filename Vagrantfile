settings = YAML.load_file 'settings.yml'

username = settings['guestuser'].strip
homedir = "/home/#{username}"

Vagrant.configure("2") do |config|
	config.vbguest.auto_update = settings['vbguest']
	config.vbguest.no_remote = false

	config.vm.box = "ubuntu/bionic64"
	config.vm.box_check_update = false

	config.ssh.username = username

	config.vm.network "private_network", ip: "192.168.33.11"
	# for port in settings['ports']
	# 	config.vm.network "forwarded_port", guest: port, host: port
	# end

	config.vm.synced_folder "./", "/vagrant", mount_options: ['dmode=777', 'fmode=777'], disabled: true

	for dir in settings['mount']
		host_path = `echo #{dir}`.strip
		basename = File.basename(host_path)
	  config.vm.synced_folder host_path, "#{homedir}/#{basename}", mount_options: ['dmode=777', 'fmode=777'],  type: "virtualbox", owner: username, group: username
	end

	# config.hostsupdater.aliases = settings['hostsupdater']

	config.vm.provider "virtualbox" do |vb|
		vb.memory = settings['vb']['memory']
		vb.cpus = settings['vb']['cpus']
		vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
		vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
	end

	config.vm.provision "first_config", type: "shell", path: "first_config.sh", args: username, privileged: false
	# config.vm.provision "runTest", type: "shell", run: "never", inline: "echo helloooooooooooo"

end
