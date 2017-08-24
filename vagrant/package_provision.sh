echo "this shell script is going to setup a running ckan instance based on the CKAN 2.6 packages"

echo "switching the OS language"
locale-gen
export LC_ALL="en_US.UTF-8"
sudo locale-gen en_US.UTF-8

echo "updating the package manager"
sudo apt-get update -q

echo "installing dependencies available via apt-get"
sudo apt-get install -y -q nginx apache2 libapache2-mod-wsgi libpq5 redis-server git-core

echo "downloading the CKAN package"
wget -q http://packaging.ckan.org/python-ckan_2.7-trusty_amd64.deb

echo "installing the CKAN package"
sudo dpkg -i python-ckan_2.7-trusty_amd64.deb

echo "install postgresql and jetty"
sudo apt-get install -y -q postgresql solr-jetty openjdk-6-jdk

echo "copying jetty configuration"
cp /vagrant/vagrant/jetty /etc/default/jetty
sudo service jetty start

# echo "resolving the bug \"HTTP 500: JSP support not configured.\" of jetty instalation"
# http://docs.ckan.org/en/ckan-2.7.0/maintaining/installing/install-from-source.html#jsp-support-not-configured
cd /tmp
wget -q https://launchpad.net/~vshn/+archive/ubuntu/solr/+files/solr-jetty-jsp-fix_1.0.2_all.deb
sudo dpkg -i solr-jetty-jsp-fix_1.0.2_all.deb
sudo service jetty restart

echo "linking the solr schema file"
sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/dutch_stop.txt /etc/solr/conf/dutch_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/english_stop.txt /etc/solr/conf/english_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/fr_elision.txt /etc/solr/conf/fr_elision.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/french_stop.txt /etc/solr/conf/french_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/german_stop.txt /etc/solr/conf/german_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/greek_stopwords.txt /etc/solr/conf/greek_stopwords.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/italian_stop.txt /etc/solr/conf/italian_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/polish_stop.txt /etc/solr/conf/polish_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/portuguese_stop.txt /etc/solr/conf/portuguese_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/romanian_stop.txt /etc/solr/conf/romanian_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/spanish_stop.txt /etc/solr/conf/spanish_stop.txt
sudo ln -s /usr/lib/ckan/default/src/ckan/ckanext/multilingual/solr/schema.xml /etc/solr/conf/schema.xml
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml
sudo service jetty restart

echo "create a CKAN database in postgresql"
sudo -u postgres createuser -S -D -R ckan_default
sudo -u postgres psql -c "ALTER USER ckan_default with password 'ckan_default'"
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8

echo "initialize CKAN database"
cp /vagrant/vagrant/package_production.ini /etc/ckan/default/production.ini
sudo ckan db init

echo "enabling filestore with local storage"
sudo mkdir -p /var/lib/ckan/default
sudo chown www-data /var/lib/ckan/default
sudo chmod u+rwx /var/lib/ckan/default
sudo service apache2 restart
sudo service nginx restart

echo "creating an admin user"
source /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default/src/ckan
paster --plugin=ckan user add admin email=admin@email.org password=pass -c /etc/ckan/default/production.ini
paster --plugin=ckan sysadmin add admin -c /etc/ckan/default/production.ini

echo "loading some multilingual test data"
paster --plugin=ckan create-test-data translations -c /etc/ckan/default/production.ini

echo "you should now have a running instance on http://ckan.lo"
