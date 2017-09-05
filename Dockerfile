FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m syndicate

ENV SYNDICATE_DATA=/home/syndicate/.syndicate

RUN apt-get install -y libgmp-dev 

USER syndicate

RUN cd /home/syndicate && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone https://github.com/SyndicateLabs/SyndicateQT.git syndicated && \
    cd /home/syndicate/syndicated/src && \
    make -f makefile.unix && \
    strip Syndicated
    
EXPOSE 9999 22348

#VOLUME ["/home/syndicate/.syndicate"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
#     cp /home/syndicate/syndicated/src/Syndicated-cli /usr/bin/Syndicate-cli && chmod 755 /usr/bin/Syndicate-cli && \
#     cp /home/syndicate/syndicated/src/Syndicate-tx /usr/bin/Syndicate-tx && chmod 755 /usr/bin/Syndicate-tx && \
     cp /home/syndicate/syndicated/src/Syndicated /usr/bin/Syndicated && chmod 755 /usr/bin/Syndicated

ENTRYPOINT ["/entrypoint.sh"]

CMD ["Syndicated"]
