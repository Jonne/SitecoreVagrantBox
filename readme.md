# Sitecore Vagrant Box  
I really believe that it should be as easy as possible to start work on a project or to switch projects. New team members shouldn't have to follow lists of installation instructions on how to set up a new project specific development environment.

Vagrant provides a really nice mechanism that lets you configure a development environment in your repo. New team members get the repository and run vagrant up, which will create a box with all the project dependencies.

I like Desired Stated Configuration for provisioning and used [this excellent blog post](https://jermdavis.wordpress.com/2015/10/12/development-environments-with-powershell-dsc-part-1/) by Jeremy Davis to write the DSC scripts, so big shout out to him!

## Prerequisites
[Virtual Box](https://www.virtualbox.org/) is used as virtualization technology.

Install latest version of [Vagrant](https://www.vagrantup.com/).

Because [Desired State Configuration](http://technet.microsoft.com/en-au/library/dn249912.aspx) is used to provision the box, you also need to install the [Vagrant DSC Plugin](https://github.com/mefellows/vagrant-dsc) by running:

```vagrant plugin install vagrant-dsc```

Next to this provisioning needs the following files:

- Sitecore 8.1 MSI installer
- Sitecore license file
- Sql Server installer
- Sql Server ini file
- MongoDB installer
- MongoDB config file 

And I recommend you to create your own base box, although this is optional. Its also possible to use one from the [Hashi corp repository](https://atlas.hashicorp.com/boxes/search). If you want to create your own, it only needs the bare minimals. I created mine using this excellent blog post: http://huestones.co.uk/node/305.

## Using

### Configure the files
The files downloaded in the prerequistes step need to be available by the provisioning process. So you can but them on a share, but what I did was putting them in a files folder in the repository and excluded this folder from Git. This is handy because all the files in the repository will be available within the box in c:\vagrant. 

When you have put them somewhere you need to configure the locations in the powershell\manifests\Vagrant.psd1 file. This file also contains other options that you can tweak.

Also check the properties of the MongoDB installer and copy the Subject in the properties tab. Change the value of the Mongo -> InstallerAppName in the Vagrant manifest to match this. 

### Configure a Vagrant base box
When you have created your own vagrant base box, you need to add this to vagrant.

```vagrant box add /path/to/output/windows.box --name ANameForYourBox```

If you want to use a box from the repository, you can add this by name.

```vagrant box add hashicorp/precise64```

Next you need to configure the base box in the VagrantFile. Change the following property to the name of the box:

```config.vm.box = "C:/boxes/Windows-2012-R2-base.box" ```

### Vagrant up

Now run vagrant up, this will create the virtual box and start provisioning it. The box is configured with port forwarding, so when everything succeeds the new sitecore site should be available in your host at: http://localhost:5555
