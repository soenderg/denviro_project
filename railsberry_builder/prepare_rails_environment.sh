#!/bin/bash

echo "***** INSTALLING RVM..."
echo
bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
echo '[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && . \"$HOME/.rvm/scripts/rvm\" # Load RVM function' >> ~/.bash_profile
source "$HOME/.rvm/scripts/rvm"

echo "***** INSTALLING RVM REQUIREMENTS..."
echo
rvm requirements 2>&1 | grep "Missing required"|cut -d: -f2|tr '[\.,]' ' '| xargs sudo apt-get -y install

echo "***** INSTALLING RUBY 1.9.3..."
echo
rvm install 1.9.3
rvm use 1.9.3 --default

echo "***** INSTALLING PASSENGER+NGINX..."
echo
export rvmsudo_secure_path=1
rvmsudo gem install passenger --no-ri --no-rdoc
rvmsudo passenger-install-nginx-module --auto --auto-download

echo "***** INSTALLING RAILS3.2.2..."
echo
rvm gemset create rails322
rvm gemset use rails322
gem install rails -v 3.2.2  --no-ri --no-rdoc

echo "***** INSTALLING INIT.D SCRIPT..."
echo
cd /tmp
if [ -d "rails-nginx-passenger-ubuntu" ]; then
  rm -fr rails-nginx-passenger-ubuntu
fi
if [ -d "/etc/init.d/nginx" ]; then
  rm -fr /etc/init.d/nginx" ]
fi
git clone git://github.com/jnstq/rails-nginx-passenger-ubuntu.git
sudo mv rails-nginx-passenger-ubuntu/nginx/nginx /etc/init.d/nginx
sudo chown root:root /etc/init.d/nginx

echo "***** INSTALLING RAILS APPLICATION..."
echo
sudo mkdir /var/railsapps 2>/dev/null
sudo chown denviro:users /var/railsapps 2>/dev/null
cd /var/railsapps
# Change to the real app, once ready
if [ -d "sample_app" ]; then
  rm -fr sample_app
fi
git clone https://github.com/soenderg/sample_app.git
rvmsudo gem update
export RAILS_ENV=production
cd sample_app
bundle install
bundle exec rake assets:precompile #Precompile assets to public/ dir
bundle exec rake db:migrate

echo "***** SETTING UP PASSENGER/NGINX..."
echo
sudo mkdir -p /opt/nginx/conf 2>/dev/null
sudo echo "
server {
listen 80;
server_name m23.merlose.dk;
rails_env production;
root /var/rails_apps/sample_app/public; # <--- be sure to point to 'public'!
passenger_enabled on;
}" >> /opt/nginx/conf/nginx.conf
sudo /etc/init.d/nginx restart
