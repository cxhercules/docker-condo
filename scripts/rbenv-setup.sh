#!/bin/bash
# Install rbenv
git clone https://github.com/rbenv/rbenv /usr/local/rbenv && \
echo '# rbenv setup' > /etc/profile.d/rbenv.sh  && \
echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh  && \
echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh  && \
echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh  && \
chmod +x /etc/profile.d/rbenv.sh && \
source /etc/profile.d/rbenv.sh && \
cat  /etc/profile.d/rbenv.sh >> /home/builder/.bash_profile && \
pushd /tmp  && \
git clone https://github.com/rbenv/ruby-build.git  && \
cd  ruby-build  && \
./install.sh  && \
popd && \
rbenv install $1 && \
rbenv global $1 && \
gem install bundle && \
rbenv rehash 
