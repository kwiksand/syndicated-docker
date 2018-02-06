FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m syndicate

ENV DAEMON_RELEASE="v1.9.9"
#ENV DAEMON_RELEASE="master"
ENV SYNDICATE_DATA=/home/syndicate/.Syndicate

USER syndicate

RUN cd /home/syndicate && \
    mkdir /home/syndicate/bin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone --branch $DAEMON_RELEASE https://github.com/SyndicateLtd/SyndicateQT.git syndicated && \
    cd /home/syndicate/syndicated && \
    chmod 777 autogen.sh src/leveldb/build_detect_platform && \
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
    rm -rf /home/syndicate/syndicated
    
EXPOSE 22348 9999

#VOLUME ["/home/syndicate/.Syndicate"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    echo "\n# Some aliases to make the syndicate clients/tools easier to access\nalias syndicated='/usr/bin/Syndicated -conf=/home/syndicate/.Syndicate/Syndicate.conf'\nalias Syndicated='/usr/bin/Syndicated -conf=/home/syndicate/.Syndicate/Syndicate.conf'\nalias Syndicatecli='/usr/bin/Syndicate-cli -conf=/home/syndicate/.Syndicate/Syndicate.conf'\n\n[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash.bashrc && \
    echo "Syndicate (SYNX) Cryptocoin Daemon\n\nUsage:\n Syndicate-cli help - List help options\n Syndicate-cli listtransactions - List Transactions\n\n" > /etc/motd && \
    chmod 755 /home/syndicate/bin/syndicated && \
    chmod 755 /home/syndicate/bin/syndicate-cli && \
    chmod 755 /home/syndicate/bin/syndicate-tx && \
    mv /home/syndicate/bin/syndicated /usr/bin/syndicated && \
    mv /home/syndicate/bin/syndicate-cli /usr/bin/syndicate-cli && \
    mv /home/syndicate/bin/syndicate-tx /usr/bin/syndicate-tx && \
    ln -s /usr/bin/syndicated /usr/bin/Syndicated && \
    ln -s /usr/bin/syndicate-cli /usr/bin/Syndicate-cli && \
    ln -s /usr/bin/syndicate-tx /usr/bin/Syndicate-tx

ENTRYPOINT ["/entrypoint.sh"]

CMD ["syndicated"]
