# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.hostname = "mongol"
	config.vm.box = "ubuntu/xenial64"

	config.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"
	end

	config.vm.provision "shell", inline: <<-SHELL
		apt-get update

		apt-get install -y build-essential
		apt-get install -y curl

		# --- Perl
		curl -sL http://cpanmin.us | perl - App::cpanminus

		cpanm Module::Build

		echo "installdeps --cpan_client='cpanm --mirror http://cpan.org'" | tee $HOME/.modulebuildrc

		# --- MongoDB
		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
		echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list

		apt-get update

		apt-get install -y mongodb-org
	SHELL
end
