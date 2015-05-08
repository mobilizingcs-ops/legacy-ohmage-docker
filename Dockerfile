FROM debian:wheezy
MAINTAINER Steve Nolen <technolengy@gmail.com>
# Report issues here: https://github.com/ohmage/docker
 
RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y mysql-server openjdk-7-jre-headless curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
#### ohmage dirs ####
ENV OHMAGE_DATA /var/lib/ohmage
ENV OHMAGE_LOG /var/log/ohmage
RUN set -x\
    && mkdir -p "$OHMAGE_DATA"/audio \
    && mkdir "$OHMAGE_DATA"/audits \
    && mkdir "$OHMAGE_DATA"/documents \
    && mkdir "$OHMAGE_DATA"/images \
    && mkdir "$OHMAGE_DATA"/videos \
    && mkdir "$OHMAGE_DATA"/flyway \
    && mkdir -p "$OHMAGE_LOG"
 
#### download tomcat ####
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME
 
# see https://www.apache.org/dist/tomcat/tomcat-8/KEYS
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
  05AB33110949707C93A279E3D3EFE6B686867BA6 \
  07E48665A34DCAFAE522E5E6266191C37C037D42 \
  47309207D818FFD8DCD3F83F1931D684307A10A5 \
  541FBE7D8F78B25E055DDEE13C370389288584E7 \
  61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
  713DA88BE50911535FE716F5208B0AB1D63011C7 \
  79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
  9BA44C2621385CB966EBA586F72C284D731FABEE \
  A27677289986DB50844682F8ACB77FC2E86E29AC \
  A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
  DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
  F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
  F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23
 
ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.61
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
 
RUN set -x \
  && curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
  && curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
  && gpg --verify tomcat.tar.gz.asc \
  && tar -xvf tomcat.tar.gz --strip-components=1 \
  && rm bin/*.bat \
  && rm tomcat.tar.gz* \
  && rm -rf /usr/local/tomcat/webapps/ROOT \
  && rm -rf /usr/local/tomcat/webapps/docs \
  && rm -rf /usr/local/tomcat/webapps/examples \
  && rm -rf /usr/local/tomcat/webapps/manager \
  && rm -rf /usr/local/tomcat/webapps/host-manager
 
#### download flyway (ohmage doesn't do migrations) ####
WORKDIR $OHMAGE_DATA/flyway
ENV FLYWAY_TGZ_URL http://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/3.2.1/flyway-commandline-3.2.1.tar.gz
RUN set -x \
    && curl -fSL "$FLYWAY_TGZ_URL" -o flyway.tar.gz \
    && tar -xvf flyway.tar.gz --strip-components=1 \
    && rm flyway.tar.gz
 
#### download ohmage ####
ENV OHMAGE_WAR_URL https://web.ohmage.org/ohmage/packages/latest/server/app.war
ENV OHMAGE_MIGRATIONS_URL https://web.ohmage.org/ohmage/packages/latest/server/migrations.tar.gz
 
WORKDIR $OHMAGE_DATA/flyway/sql
RUN curl -fSL "$OHMAGE_WAR_URL" -o /usr/local/tomcat/webapps/app.war
RUN curl -fSL "$OHMAGE_MIGRATIONS_URL" -o migrations.tar.gz && \
    tar -xvf migrations.tar.gz && \
    rm migrations.tar.gz
 
ADD run.sh /run.sh
ADD ohmage.conf /etc/ohmage.conf
 
RUN chmod +x /run.sh
 
#### setup run user ####
RUN useradd -ms /bin/bash ohmage && \
    chown -R ohmage "$CATALINA_HOME" && \
    chown -R ohmage "$OHMAGE_DATA" && \
    chown -R ohmage "$OHMAGE_LOG"
 
EXPOSE 8080
 
VOLUME /var/lib/ohmage
VOLUME /var/lib/mysql

CMD ["/run.sh"]