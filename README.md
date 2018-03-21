# Vagrant box for CKAN (2.7.3)

[CKAN](http://ckan.org) (the apt-get for opendata) is an open-source portal application developed by the [OKFN](http://okfn.org).

In order to make the getting started part easier I created this shell script to create a CKAN instance with the help of vagrant, a nice wrapper around virtualbox that creates and manages virtual machines.


## Setup

1. Install [Virtualbox](https://www.virtualbox.org)
2. Install [vagrant](http://www.vagrantup.com)
3. Clone this repository `git clone git://github.com/allysonbarros/ckan-vagrant.git`
4. Move to the directory with your terminal application `cd ckan-vagrant/`
5. Create the instance `vagrant up`
6. Go get some coffee (it takes up to 15 minutes)
7. Add to following line to `/etc/hosts`:  `192.168.19.97 ckan.lo`
8. Open [http://ckan.lo](http://ckan.lo) in your browser.