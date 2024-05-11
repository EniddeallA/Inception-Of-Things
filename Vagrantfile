#Vagrant configuration version 2
Vagrant.configure("2") do |config|
  #set the box for the guest machine to alpine
  config.vm.box = "generic/alpine312"
  
  #Create the server machine
  config.vm.define "akhalidS" do |server|
    server.vm.hostname = "akhalidS"
    server.vm.network "private_network", ip: "192.168.56.110"

    server.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--name", "akhalidS"]
      vb.memory = "512"
      vb.cpus = "1"
    end
  end

  #Create the agent machine
  config.vm.define "akhalidSW" do |worker|
    worker.vm.hostname = "akhalidSW"
    worker.vm.network "private_network", ip: "192.168.56.111"

    worker.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--name", "akhalidSW"]
      vb.memory = "512"
      vb.cpus = "1"
    end
  end
  
end
