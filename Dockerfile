FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m syndicate

ENV DAEMON_RELEASE="v2.2.0"
#ENV DAEMON_RELEASE="master"
#ENV GIT_COMMIT="cabbdc220a6d35fb4b00d9c4655b217b2a4d62b3"
ENV SYNDICATE_DATA=/home/syndicate/.Syndicate

USER root

RUN apt-get install -y libcurl3 libcurl3-dev

USER syndicate

RUN cd /home/syndicate && \
    mkdir /home/syndicate/bin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone --branch $DAEMON_RELEASE https://github.com/SyndicateLtd/SyndicateQT.git syndicated && \
    cd /home/syndicate/syndicated && \
    chmod 777 autogen.sh src/leveldb/build_detect_platform share/genbuild.sh && \
#    sed -i 's/<const\ CScriptID\&/<CScriptID/' rpcrawtransaction.cpp && \
#    make -f makefile.unix && \a
    ./autogen.sh && \
    ./configure LDFLAGS="-L/home/syndicate/db4/lib/" CPPFLAGS="-I/home/syndicate/db4/include/" && \
    make && \
    cd src/ && \
    strip syndicated && \
    strip syndicate-tx && \
    strip syndicate-cli && \
    mv syndicated syndicate-cli syndicate-tx /home/syndicate/bin && \
    chmod 755 /home/syndicate/bin/syndicated && \
    chmod 755 /home/syndicate/bin/syndicate-cli && \
    chmod 755 /home/syndicate/bin/syndicate-tx && \
    rm -rf /home/syndicate/syndicated
    
EXPOSE 51472 51473

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    mv /home/syndicate/bin/* /usr/bin && \
    echo "\n# Some aliases to make the syndicate clients/tools easier to access\nalias syndicated='/usr/bin/syndicated -conf=/home/syndicate/.Syndicate/Syndicate.conf'\nalias syndicate-cli='/usr/bin/syndicate-cli -conf=/home/syndicate/.Syndicate/Syndicate.conf'\n\n[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash.bashrc && \
    echo "Syndicate (SYNX) Cryptocoin Daemon\n\nUsage:\n syndicate-cli help - List help options\n syndicate-cli listtransactions - List Transactions\n\n" > /etc/motd

ENTRYPOINT ["/entrypoint.sh"]

CMD ["syndicated"]
