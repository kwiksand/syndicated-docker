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
    cd /home/syndicate/syndicated/src && \
#    sed -i 's/<const\ CScriptID\&/<CScriptID/' rpcrawtransaction.cpp && \
    make -f makefile.unix && \
    strip Syndicated && \
    strip Syndicate-tx && \
    strip Syndicate-cli && \
    mv Syndicated Syndicate-cli Syndicate-tx /home/syndicate/bin && \
    rm -rf /home/syndicate/syndicated
    
EXPOSE 22348 9999

#VOLUME ["/home/syndicate/.Syndicate"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    echo "\n# Some aliases to make the syndicate clients/tools easier to access\nalias syndicated='/usr/bin/Syndicated -conf=/home/syndicate/.Syndicate/Syndicate.conf'\nalias Syndicated='/usr/bin/Syndicated -conf=/home/syndicate/.Syndicate/Syndicate.conf'\nalias Syndicatecli='/usr/bin/Syndicate-cli -conf=/home/syndicate/.Syndicate/Syndicate.conf'\n\n[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash.bashrc && \
    echo "Syndicate (SYNX) Cryptocoin Daemon\n\nUsage:\n Syndicate-cli help - List help options\n Syndicate-cli listtransactions - List Transactions\n\n" > /etc/motd && \
    chmod 755 /home/syndicate/bin/Syndicated && \
    chmod 755 /home/syndicate/bin/Syndicate-cli && \
    chmod 755 /home/syndicate/bin/Syndicate-tx && \
    mv /home/syndicate/bin/Syndicated /usr/bin/Syndicated && \
    mv /home/syndicate/bin/Syndicate-cli /usr/bin/Syndicate-cli && \
    mv /home/syndicate/bin/Syndicate-tx /usr/bin/Syndicate-tx && \
    ln -s /usr/bin/Syndicated /usr/bin/syndicated && \
    ln -s /usr/bin/Syndicate-cli /usr/bin/syndicate-cli && \
    ln -s /usr/bin/Syndicate-tx /usr/bin/syndicate-tx

ENTRYPOINT ["/entrypoint.sh"]

CMD ["Syndicated"]
