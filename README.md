- Download and install git for windows from https://git-for-windows.github.io if you are running windows.
- Download and install VirtualBox from https://www.virtualbox.org/wiki/Downloads.
- Download and install Vagrant from https://www.vagrantup.com/downloads.html.
- Clone the hadoop-vagrant GitHub repository into a convenient folder on your PC or Mac. Navigate to the folder, and enter the following command from the terminal:
```
$ git clone https://github.com/python279/hadoop-vagrant.git
```
- Add virtual machine hostnames and addresses to the /etc/hosts file on your computer. The following command copies a set of host names and addresses from hadoop-vagrant/append-to-etc-hosts.txt to the end of the /etc/hosts files:
Linux and Mac
```
$ sudo -s 'cat hadoop-vagrant/append-to-etc-hosts.txt >> /etc/hosts'
```
Windows
Append the content of 'hadoop-vagrant\append-to-etc-hosts.txt' to 'C:\Windows\System32\drivers\etc\hosts'.

- Use the vagrant command to create a private key to use with virtual Linux:
```
$ vagrant
```
- Change your current directory to hadoop-vagrant/ubuntu14.4
```
$ cd hadoop-vagrant/ubuntu14.4
```
- Cascade the splitted box files to one box
```
$ cat ubuntu1404.box.* > ubuntu1404.box
```
- Copy the private key into the directory associated with the chosen operating system. 
For this example, which uses ubuntu14.4, issue the following command:
```
$ cp ~/.vagrant.d/insecure_private_key .
```
- Every virtual machine will have a directory called /vagrant inside the VM. This corresponds to the hadoop-vagrant/<os> directory on your local computer, making it easy to transfer files back and forth between your host Mac and the virtual machine. If you have any files to access from within the VM, you can place them in this shared directory.
- Start one or more VMs, using the ./up.sh command. Each VM will run one HDP node. Recommendation: if you have at least 16GB of RAM on your Mac and wish to run a small cluster, start with three nodes.
```
$ ./up.sh 1 # numberof VMs to launch
```
- Check the status of your VM(s), and review any errors. The following example shows the results of ./up.sh 1 for three VMs running with Ubuntu 14.04:
```
$ vagrant status
Current machine states:

u1401                     running (virtualbox)
u1402                     not created (virtualbox)
u1403                     not created (virtualbox)
u1404                     not created (virtualbox)
u1405                     not created (virtualbox)
u1406                     not created (virtualbox)
u1407                     not created (virtualbox)
u1408                     not created (virtualbox)
u1409                     not created (virtualbox)
u1410                     not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```
- At this point, you can snapshot the VMs to have a fresh set of running machines to reuse if desired. For more information about snapshots, see the vagrant snapshot command from https://www.vagrantup.com/docs/cli/snapshot.html. 
- To log on to a virtual machine, use the 'vagrant ssh' command on your host machine, and specify the hostname; for example:
```
$ vagrant ssh u1401
Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.13.0-24-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
New release '16.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Mon Dec 26 10:31:01 2016 from 10.0.2.2
vagrant@u1401:~$
- Destroy the vm
```
$ vagrant destroy u1401
```
- Re-provision the bootstrap.sh
```
$ vagrant provision u1401
```
- Shutdown the vm
```
$ vagrant halt u1401
```
