#!/bin/bash

setup_gemrc () {
  echo "***** SETUP GEMRC..."
  echo
  echo "install: --no-rdoc --no-ri" >> "$HOME/.gemrc"
  echo "update: --no-rdoc --no-ri" >> "$HOME/.gemrc"
}

install_nginx_passenger () {
  echo "***** INSTALLING NGINX WITH PASSENGER..."
  echo
  echo "gem install passenger"
  gem install passenger
  echo "/usr/local/bin/passenger-install-nginx-module --auto --prefix=/opt/nginx --auto-download"
  /usr/local/bin/passenger-install-nginx-module --auto --prefix=/opt/nginx --auto-download
}

install_rails_app () {
  echo "***** INSTALLING RAILS APPLICATION..."
  echo
  export RAILS_ENV=production
  sudo mkdir /var/railsapps 2>/dev/null
  sudo chown denviro:users /var/railsapps 2>/dev/null
  cd /var/railsapps
  # Change to the real app, once ready
  if [ -d "sample_app" ]; then
    rm -fr sample_app
  fi
  echo "rails new sample_app"
  rails new sample_app
  cd sample_app
  bundle exec rake assets:precompile
  cd ..
  chown -R denviro:users /var/railsapps/sample_app
}

setup_passenger () {  
  echo "***** SETTING UP PASSENGER/NGINX..."
  echo
  echo "cp /home/denviro/denviro_project/railsberry_builder/nginx.init.d /etc/init.d/nginx"
  cp /home/denviro/denviro_project/railsberry_builder/nginx.init.d /etc/init.d/nginx
  echo "cp /home/denviro/denviro_project/railsberry_builder/nginx.conf.d /opt/nginx/conf/nginx.conf"
  cp /home/denviro/denviro_project/railsberry_builder/nginx.conf /opt/nginx/conf/nginx.conf
}

usage () {
  echo "Read the shell script..."
  exit 1
}

while [ "$1" != "" ]; do
    case $1 in
        --all )			shift
				time setup_gemrc
				time install_nginx_passenger
				time install_rails_app
				time setup_passenger
                                ;;
        --setup-gemrc )		shift
				time setup_gemrc
                                ;;
        --install-nginx-passenger )	shift
				time install_rails_app
                                ;;
        --install-rails-app )	shift
				time install_rails_app
                                ;;
        --setup-passenger )	shift
				time setup_passenger
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

