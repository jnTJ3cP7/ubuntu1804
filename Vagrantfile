settings = YAML.load_file 'settings.yaml'

for plugin in settings.fetch('plugins', [])
	unless Vagrant.has_plugin?(plugin)
		raise "#{plugin} is not installed!\nPlease execute the command [ vagrant plugin install #{plugin} ]"
	end
end

username = settings['guestuser'].strip
homedir = "/home/#{username}"
private_ip = settings['private_ip'].strip

Vagrant.configure("2") do |config|
	if Vagrant.has_plugin?('vagrant-vbguest')
		config.vbguest.auto_update = false
	end

	config.vm.box = "ubuntu/bionic64"
	config.vm.box_check_update = false

	config.ssh.username = username

	config.vm.network "private_network", ip: private_ip
	# for port in settings['ports']
	# 	config.vm.network "forwarded_port", guest: port, host: port
	# end

	config.vm.synced_folder "./", "/vagrant", disabled: true

	for dir in settings['mount']
		host_path = `echo #{dir}`.strip
		basename = File.basename(host_path)
		config.vm.synced_folder host_path, "#{homedir}/#{basename}", mount_options: ['dmode=755', 'fmode=744'],  type: "virtualbox", owner: username, group: username
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
      "--vram", "256",
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

	provision_script_base_path = "provision_scripts"
	config.vm.provision "first_config", type: "shell", path: "#{provision_script_base_path}/first_config.sh", privileged: false
	config.vm.provision :reload
	config.vm.provision "anyenv", type: "shell", path: "#{provision_script_base_path}/anyenv.sh", privileged: false
	config.vm.provision "python", type: "shell", path: "#{provision_script_base_path}/python.sh", privileged: false
	config.vm.provision "node", type: "shell", path: "#{provision_script_base_path}/node.sh", privileged: false
	config.vm.provision "go", type: "shell", path: "#{provision_script_base_path}/go.sh", privileged: false
	config.vm.provision "vscode", type: "shell", path: "#{provision_script_base_path}/vscode.sh", args: [settings['vscode']['personal_access_token'], settings['vscode']['gist_id']], privileged: false
	config.vm.provision "docker", type: "shell", path: "#{provision_script_base_path}/docker.sh", privileged: false
	config.vm.provision "k8s", type: "shell", path: "#{provision_script_base_path}/k8s.sh", args: private_ip, privileged: false
	# config.vm.provision "java", type: "shell", path: "java.sh", args: username, privileged: false
	# config.vm.provision "runTest", type: "shell", run: "never", inline: "echo helloooooooooooo"
	# config.vm.provision "first_config_remained", type: "shell", path: "first_config_remained.sh", args: username, privileged: false
	config.vm.provision :reload

end
