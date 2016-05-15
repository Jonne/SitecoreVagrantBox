
$shell_script = <<SCRIPT
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
  choco install seek-dsc -y
  Get-DSCResource
SCRIPT

unless Vagrant.has_plugin?("vagrant-dsc")
  raise 'vagrant-dsc plugin is not installed! Please install with: vagrant plugin install vagrant-dsc'
end

Vagrant.configure(2) do |config|
  config.vm.box = "C:/boxes/Windows-2012-R2-base.box"
  config.vm.guest = :windows
  config.vm.communicator = "winrm"

  config.vm.provider "virtualbox" do |v|
    v.gui = true
    v.memory = 2048
    v.cpus = 2
    v.customize ["modifyvm", :id, "--vram", "128"]
  end

  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"
  config.ssh.insert_key = false

  config.vm.network "forwarded_port", guest: 80, host: 5555

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.50.10"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./", "/vagrant_data"
    
  # Install Chocolatey and some basic DSC Resources
  config.vm.provision "shell", inline: $shell_script
  
  config.vm.provision :dsc do |dsc|
    dsc.configuration_data_file  = "powershell/manifests/Vagrant.psd1"
    dsc.configuration_file  = "powershell/Config.ps1"
    dsc.module_path = ["powershell/modules"]
    dsc.temp_dir = "c:/tmp/vagrant-dsc"
    #dsc.configuration_params = {"-ConfigurationData $configurationData" => nil}
  end
    
end
