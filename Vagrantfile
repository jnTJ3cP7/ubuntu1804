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

	config.disksize.size = '30GB'

	config.ssh.username = username

	config.vm.network "private_network", ip: private_ip
	# for port in settings['ports']
	# 	config.vm.network "forwarded_port", guest: port['guest'], host: port['host']
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
		vb.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]

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

	# Must
	provision_script_base_path = "provision_scripts"
	config.vm.provision "first_config", type: "shell", path: "#{provision_script_base_path}/first_config.sh", privileged: false
	config.vm.provision :reload
	config.vm.provision "git", type: "shell", path: "#{provision_script_base_path}/git.sh", privileged: false
	config.vm.provision "terminal", type: "shell", path: "#{provision_script_base_path}/terminal.sh", privileged: false
	config.vm.provision "anyenv", type: "shell", path: "#{provision_script_base_path}/anyenv.sh", privileged: false
	config.vm.provision "python", type: "shell", path: "#{provision_script_base_path}/python.sh", privileged: false

	# Option
	config.vm.provision "node", type: "shell", path: "#{provision_script_base_path}/node.sh", privileged: false
	config.vm.provision "go", type: "shell", path: "#{provision_script_base_path}/go.sh", privileged: false
	config.vm.provision "java", type: "shell", path: "#{provision_script_base_path}/java.sh", privileged: false
	config.vm.provision "vscode", type: "shell", path: "#{provision_script_base_path}/vscode.sh", args: [settings['vscode']['personal_access_token'], settings['vscode']['gist_id']], privileged: false
	config.vm.provision "docker", type: "shell", path: "#{provision_script_base_path}/docker.sh", privileged: false
	config.vm.provision "k8s", type: "shell", path: "#{provision_script_base_path}/k8s.sh", args: private_ip, privileged: false
	config.vm.provision "react", type: "shell", path: "#{provision_script_base_path}/react.sh", privileged: false
	config.vm.provision "awscli", type: "shell", path: "#{provision_script_base_path}/awscli.sh", privileged: false
	config.vm.provision "first_config_remained", type: "shell", path: "first_config_remained.sh", args: username, privileged: false, run: "never"
	config.vm.provision :reload

end
