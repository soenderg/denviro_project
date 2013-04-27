#!/bin/bash

install_rvm () {
  echo "***** INSTALLING RVM..."
  echo
  #bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
  curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable
  echo "source \"$HOME/.rvm/scripts/rvm\"" >> ~/.bash_profile
  source "$HOME/.rvm/scripts/rvm"
  echo "install: --no-rdoc --no-ri" >> "$HOME/.gemrc"
  echo "update: --no-rdoc --no-ri" >> "$HOME/.gemrc"
}

install_rvm_pkgs () {
  echo "***** INSTALLING RVM REQUIREMENTS..."
  echo
  rvm requirements 2>&1 | grep "Missing required"|cut -d: -f2|tr '[\.,]' ' '| xargs sudo apt-get -y install
}

install_ruby () {
  echo "***** INSTALLING RUBY 1.9.3..."
  echo
  rvm install 1.9.3
  rvm use 1.9.3 --default
}

install_passenger () {
  echo "***** INSTALLING PASSENGER+NGINX..."
  echo
  export rvmsudo_secure_path=1
  rvmsudo gem install passenger --no-ri --no-rdoc
  rvmsudo passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx
}

install_rails () {
  echo "***** INSTALLING RAILS3.2.2..."
  echo
  rvm gemset create rails322
  rvm gemset use rails322
  gem install rails -v 3.2.2  --no-ri --no-rdoc
}

install_initd_script () {
  echo "***** INSTALLING INIT.D SCRIPT..."
  echo
  cd /tmp
  if [ -d "rails-nginx-passenger-ubuntu" ]; then
    rm -fr rails-nginx-passenger-ubuntu
  fi
  if [ -d "/etc/init.d/nginx" ]; then
    rm -fr /etc/init.d/nginx ]
  fi
  git clone git://github.com/jnstq/rails-nginx-passenger-ubuntu.git
  sudo mv rails-nginx-passenger-ubuntu/nginx/nginx /etc/init.d/nginx
  sudo chown root:root /etc/init.d/nginx
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
  git clone https://github.com/soenderg/sample_app.git
  rvmsudo gem update --no-ri --no-rdoc
  export RAILS_ENV=production
  cd sample_app
  bundle install
  bundle exec rake assets:precompile #Precompile assets to public/ dir
  bundle exec rake db:migrate
}

setup_passenger () {  
  echo "***** SETTING UP PASSENGER/NGINX..."
  echo
  sudo mkdir -p /opt/nginx/conf 2>/dev/null
  sudo chown denviro:users /opt/nginx/conf
  cat << EOF >> /opt/nginx/conf/nginx.conf
  server \{
  listen 80;
  server_name m23.merlose.dk;
  rails_env production;
  root /var/rails_apps/sample_app/public; # <--- be sure to point to 'public'!
  passenger_enabled on;
  \}
EOF
  sudo /etc/init.d/nginx restart
}

usage () {
  echo "Read the shell script..."
  exit 1
}

while [ "$1" != "" ]; do
    case $1 in
        --all )			shift
				time install_rvm
				time install_rvm_pkgs
				time install_ruby
				time install_passenger
				time install_rails
				time install_initd_script
				time install_rails_app
				time setup_passenger
                                ;;
        --install-rvm )		shift
				time install_rvm
                                ;;
        --install-rvm-pkgs )	shift
				time install_rvm_pkgs
                                ;;
        --install-ruby )	shift
				time install_ruby
                                ;;
        --install-passenger )	shift
				time install_passenger
                                ;;
        --install-rails )	shift
				time install_rails
                                ;;
        --install-initd )	shift
				time install_initd_script
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

