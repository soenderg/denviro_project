#!/bin/bash

setup_gemrc () {
  echo "install: --no-rdoc --no-ri" >> "$HOME/.gemrc"
  echo "update: --no-rdoc --no-ri" >> "$HOME/.gemrc"
}

install_rails_app () {
  echo "***** INSTALLING RAILS APPLICATION..."
  echo
  sudo mkdir /var/railsapps 2>/dev/null
  sudo chown denviro:users /var/railsapps 2>/dev/null
  cd /var/railsapps
  # Change to the real app, once ready
  if [ -d "sample_app" ]; then
    rm -fr sample_app
  fi
  rails new sample_app
}

setup_passenger () {  
  echo "***** SETTING UP PASSENGER/NGINX..."
  echo
  #mkdir -p /opt/nginx/conf 2>/dev/null
  #chown denviro:users /opt/nginx/conf
  #cat << EOF >> /opt/nginx/conf/nginx.conf
  #server \{
  #listen 80;
  #server_name m23.merlose.dk;
  #rails_env production;
  #root /var/rails_apps/sample_app/public; # <--- be sure to point to 'public'!
  #passenger_enabled on;
  #\}
#EOF
  /etc/init.d/nginx restart
}

usage () {
  echo "Read the shell script..."
  exit 1
}

while [ "$1" != "" ]; do
    case $1 in
        --all )			shift
				time setup_gemrc
				time install_rails_app
				time setup_passenger
                                ;;
        --setup-gemrc )		shift
				time setup_gemrc
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

