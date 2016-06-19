# Dockerfile for a Ruby project container.
#
# Provides an environment for running Ruby apps and nothing else.
#FROM       d11wtq/ubuntu:14.04

FROM ubuntu:15.04


#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu vivid main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu vivid-updates main universe\n" >> /etc/apt/sources.list

RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install software-properties-common \
  && add-apt-repository -y ppa:git-core/ppa

#========================
# Miscellaneous packages
# iproute which is surprisingly not available in ubuntu:15.04 but is available in ubuntu:latest
# OpenJDK8
# rlwrap is for azure-cli
# groff is for aws-cli
# tree is convenient for troubleshooting builds
#========================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    iproute \
    sudo \
    openssh-client ssh-askpass\
    ca-certificates \
    openjdk-8-jdk \
    tar zip unzip \
    wget curl \
    git \
    build-essential \
    less nano tree \
    python python-pip groff \
    rlwrap \
    bison \
    libffi-dev \
    libgdbm-dev \
    libgdbm3 \
    libncurses5-dev \
    libreadline6-dev \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev \
    libxslt-dev \
    tofrodos \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

# workaround https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=775775
RUN [ -f "/etc/ssl/certs/java/cacerts" ] || /var/lib/dpkg/info/ca-certificates-java.postinst configure
#========================================
# Add normal user with passwordless sudo
#========================================
RUN useradd builder --shell /bin/bash --create-home \
  && usermod -a -G sudo builder \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'builder:secret' | chpasswd


#==========
# Maven
#==========
ENV MAVEN_VERSION 3.3.9

RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven


#====================================
# NODE JS
# See https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
#====================================
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash \
   && apt-get install -y nodejs
RUN  npm install npm --global
#====================================
# BOWER, GRUNT, GULP
#====================================

RUN npm install --global --no-interactive --grunt-cli@0.1.2 gulp@3.9.0

RUN npm install --global bower@1.4.1  --config.interactive=false
#====================================
# install Rbenv,Ruby 
#====================================

ARG RUBY_VERSION
ENV RUBY_VERSION=${RUBY_VERSION:-2.2.3}
COPY scripts/rbenv-setup.sh /
RUN bash /rbenv-setup.sh $RUBY_VERSION
RUN rm -fv /rbenv-setup.sh

RUN sudo chmod -R 777 /usr/local/rbenv

ADD scripts/init.sh /usr/local/bin/init.sh 
RUN chmod +x /usr/local/bin/init.sh 
sudo chown -R builder /usr/local
sudo chown -R builder /usr/bin
RUN chmod -R 755 /usr/bin/
RUN chmod -R 755 /tmp
RUN chown builder:builder /usr/local/bin/init.sh
USER builder



