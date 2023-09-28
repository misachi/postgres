FROM amd64/ubuntu:latest
ENV APP_HOME=/postgres/ ID=991 USR=postgres USR_HOME=/home/postgres PG_FILES=/usr/local/pgsql/ BASH_PROFILE=/etc/bash.bashrc

RUN groupadd -g ${ID} ${USR} && \
    useradd -r -u ${ID} -g ${USR} ${USR}
ADD . ${APP_HOME}
WORKDIR ${APP_HOME}
RUN chown -R ${USR}:${USR} ${APP_HOME} && \
        mkdir -p ${USR_HOME} && \
        chown -R ${USR}:${USR} ${USR_HOME}

RUN apt-get update && apt-get install -y g++ \
            zlib1g-dev \
            make curl \
            tar gzip \
            git \
            libreadline-dev \
            flex bison 
            # libxml2-dev libxslt-dev libssl-dev libxml2-utils xsltproc ccache

# RUN git clone https://github.com/misachi/postgres.git
RUN ./configure && \
        make  && \
        make all && \
        make install

RUN echo "export PATH=$PATH:/usr/local/pgsql/bin/" >>  ${BASH_PROFILE} && \
        chown -R ${USR}:${USR} ${PG_FILES}
USER ${USR}
# Post-Installation
RUN ${PG_FILES}/bin/pg_ctl -D /usr/local/pgsql/data initdb
CMD [ "pg_ctl", "-D", "/usr/local/pgsql/data", "-l", "logfile start" ]
