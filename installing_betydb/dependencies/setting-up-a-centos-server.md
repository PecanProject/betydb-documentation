# Setting up a CentOS Server

## Install CentOS 7

Download CentOS from [https://www.centos.org/download/](https://www.centos.org/download/). The DVD ISO should have the essentials.

Alternatively, you can use the NetInstall verion. Instructions are here: [https://www.if-not-true-then-false.com/2014/centos-7-netinstall-guide/](https://www.if-not-true-then-false.com/2014/centos-7-netinstall-guide/)

## Install additional system software

We assume you are logged in as a user with sudo privileges.

The following commands will get you most of what's needed:

```bash
sudo -s

yum install postgres
yum install httpd
yum install epel-release
yum install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-3.noarch.rpm
yum install postgresql94-server postgresql-contrib postgis2_94 postgresql94-devel
yum install emacs # (or your favorite editor)
yum install git
yum install graphviz
yum install R
yum install java
```

## Install required Ruby and Rails software

### RVM \(Ruby Version Manager\)

* Run the following three commands to get and install RVM and add yourself to the `rvm` group:

  ```bash
  sudo grgpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | sudo bash -s stable
  sudo usermod -a -G rvm `whoami`
  ```

* Ensure rvmsudo works:

  ```bash
  if sudo grep -q secure_path /etc/sudoers; then sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh" && echo Environment variable installed; fi
  ```

* Log out of the server and then log back in to make RVM take effect.
* Install the correct version of Ruby

  First, visit [https://github.com/PecanProject/bety/blob/master/.ruby-version](https://github.com/PecanProject/bety/blob/master/.ruby-version) and note the version of Ruby that BETYdb currently expects.

  To install that version of Ruby, run

  ```bash
  rvm install ruby-X.X.X
  ```

  where X.X.X is the version number found in the .ruby-version file. Ensure this version is set as the default by running

  ```bash
  rvm --default use ruby-2.3.0
  ```

## Bundler:

```text
gem install bundler --no-rdoc --no-ri
```

## node.js \(needed to be able to compile Rails assets\):

```bash
sudo yum install -y epel-release
sudo yum install -y --enablerepo=epel nodejs npm
```

## Phusion Passenger

Passenger requires EPEL. Enable it with the following commands:

```bash
sudo yum install -y epel-release yum-utils
sudo yum-config-manager --enable epel
sudo yum clean all && sudo yum update -y
```

Ensure the `date` is working properly and install ntp if not:

```bash
date
```

If this gives the wrong output, install ntp:

```bash
sudo yum install -y ntp
sudo chkconfig ntpd on
sudo ntpdate pool.ntp.org
sudo service ntpd start
```

Now add the Passenger YUM repository:

```bash
sudo curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo
```

Install Passenger + Apache module:

```bash
sudo yum install -y mod_passenger || sudo yum-config-manager --enable cr && sudo yum install -y mod_passenger
```

Restart Apache:

```bash
sudo systemctl restart httpd
```

Check installation:

```bash
sudo /usr/bin/passenger-config validate-install
```

