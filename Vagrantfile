settings = YAML.load_file 'settings.yaml'

for plugin in settings.fetch('plugins', [])
	unless Vagrant.has_plugin?(plugin)
		raise "#{plugin} is not installed!\nPlease execute the command [ vagrant plugin install #{plugin} ]"
	end
end

username = settings['guestuser'].strip
homedir = "/home/#{username}"

Vagrant.configure("2") do |config|
	if Vagrant.has_plugin?('vagrant-vbguest')
		config.vbguest.auto_update = false
	end

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

		vb.gui = settings['vb']['gui']
    vb.customize [
      "modifyvm", :id,
      "--vram", "128",
      "--accelerate3d", "on",
      "--hwvirtex", "on",
      "--nestedpaging", "on",
      "--largepages", "on",
      "--ioapic", "on",
      "--pae", "on",
			"--paravirtprovider", "kvm",
			"--clipboard", "bidirectional",
			"--draganddrop", "bidirectional",
		]
	end

	config.vm.provision "first_config", type: "shell", path: "first_config.sh", args: username, privileged: false
	config.vm.provision :reload
	config.vm.provision "vscode", type: "shell", path: "vscode.sh", args: username, privileged: false
	config.vm.provision "java", type: "shell", path: "java.sh", args: username, privileged: false
	# config.vm.provision "runTest", type: "shell", run: "never", inline: "echo helloooooooooooo"

end
