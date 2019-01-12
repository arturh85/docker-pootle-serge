FROM webdevops/bootstrap:ubuntu-16.04
MAINTAINER Artur Hallmann "arturh@arturh.de"
ENV POOTLE_VERSION="2.8.2"
ENV SERGE_VERSION="master"

RUN chmod -R 2777 /tmp

# Install apt packages
RUN /usr/local/bin/apt-install build-essential \
  swig \
  git \
  xmlstarlet \
  xsltproc \
  zip \
  cron \
  wget \
  curl \
  supervisor \
  unzip \
  mysql-client \
  openssh-client \
  python-dev \
  libexpat-dev \
  libxml2-dev \
  libssl-dev \
  libxslt1-dev \
  zlib1g-dev \
  libmysqlclient-dev \
  python-pip \
  python-xapian \
  xapian-tools \
  python-setuptools
# Update pip
RUN pip install --upgrade pip
# Install python packages
RUN pip install -q virtualenv \
    MySQL-python \
    flup \
    python-memcached \
    python-Levenshtein \
    m2crypto \
    wheel
# Install pootle
RUN pip install -I pootle==$POOTLE_VERSION
# Configure pootle
COPY pootle.conf /root/.pootle/pootle.conf
RUN mkdir -p /srv/pootle/po/.tmp
RUN ln -s /usr/lib/python2.7/dist-packages/xapian /usr/local/lib/python2.7/dist-packages/xapian
# RUN pootle setup
COPY pootle.sh /etc/profile.d/pootle.sh
RUN /etc/profile.d/pootle.sh
COPY scripts /home/pootle/scripts
COPY templates /home/pootle/templates
COPY frontend /usr/local/lib/python2.7/dist-packages/pootle/static
COPY serge.cron /etc/cron.d/serge
COPY pootle.cron /etc/cron.d/pootle
RUN cp -R /usr/lib/python2.7/dist-packages/xapian /usr/local/lib/python2.7/dist-packages/pootle/assets
RUN pootle collectstatic --noinput --clear
RUN pootle assets build

# switch to this directory
WORKDIR /usr/lib
# download required Serge version (be quiet; save to serge-<version>.zip)
RUN wget -q https://github.com/evernote/serge/archive/$SERGE_VERSION.zip -O serge-$SERGE_VERSION.zip
# unpack the archive (it will create /usr/lib/serge-<version> subfolder)
RUN unzip serge-$SERGE_VERSION.zip
# delete the archive, since it is no longer needed
RUN unlink serge-$SERGE_VERSION.zip
# install cpanm tool (package App::cpanminus) from CPAN
RUN cpan App::cpanminus
### Install Perl modules
# switch to app folder
WORKDIR /usr/lib/serge-$SERGE_VERSION
# install dependency Perl modules using cpanm
RUN cpanm --installdeps .
# run tests
RUN cpanm --test-only .
# clean temporary Build files
RUN ./Build distclean
### Create symlinks
# go back to the parent directory
WORKDIR /usr/lib
# map `/usr/lib/serge-<version>` folder to `/usr/lib/serge`
RUN ln -s serge-$SERGE_VERSION serge
# add symlink to `serge`
RUN ln -s /usr/lib/serge/bin/serge /usr/bin/serge

WORKDIR /home/pootle

EXPOSE 8000
VOLUME ["/usr/local/lib/python2.7/dist-packages/pootle"]
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
