#FROM dynamonda/rails
FROM centos:7.6.1810
MAINTAINER dynamonda <v7gj9kk@gmail.com>

RUN yum install -y git

RUN git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build
RUN $HOME/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
    echo 'eval "$(rbenv init -)"' >> .bashrc

RUN yum install -y bzip2 gcc openssl-devel readline-devel zlib-devel make sqlite-devel

ENV CONFIGURE_OPTS --disable-install-doc
RUN rbenv install 2.5.0 && \
    rbenv global 2.5.0
RUN gem install rails && \
    gem install sqlite3 -v '1.4.0' && \
    gem install bundler
RUN rails new railsproject

WORKDIR railsproject
RUN echo "gem 'therubyracer'" >> Gemfile
RUN yum install -y gcc-c++
RUN bundle update

RUN sed -i -e "s/gem 'sqlite3'/gem 'sqlite3', '~> 1.3.6'/" Gemfile
RUN bundle install
RUN rails db:create

# httpd, Passenger
RUN yum install -y httpd libcurl-devel httpd-devel apr-devel apr-util-devel
RUN gem install passenger
RUN passenger-install-apache2-module --auto > passenger.log
RUN sed -n 560,564p passenger.log > /etc/httpd/conf.d/passenger.conf
RUN sed -i '95a ServerName localhost:80' /etc/httpd/conf/httpd.conf
RUN echo $'<VirtualHost *:80> \n\
  ServerName localhost:80 \n\
  DocumentRoot /railsproject/public \n\
  PassengerEnabled on \n\
  ErrorLog /var/log/httpd/error_log \n\
  CustomLog /var/log/httpd/access_log combined \n\
  \n\
  <Directory /railsproject/public> \n\
    AllowOverride all \n\
    Options -MultiViews \n\
  </Directory> \n\
</VirtualHost>' > /etc/httpd/conf.d/rails.conf

EXPOSE 3000

#CMD ["rails", "server", "-b", "0.0.0.0"]
#CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
CMD ["passenger", "start"]

