FROM ohmage/platform
MAINTAINER Steve Nolen <technolengy@gmail.com>
# Report issues here: https://github.com/ohmage/docker

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y libtcnative-1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD setenv /usr/local/tomcat/bin/setenv.sh
ADD server.xml /usr/local/tomcat/conf/server.xml
ADD catalina-jmx-remote.jar /usr/local/tomcat/lib/catalina-jmx-remote.jar
RUN chown ohmage.root /usr/local/tomcat/bin/setenv.sh \
  && chmod +x /usr/local/tomcat/bin/setenv.sh \
  && chown ohmage.root /usr/local/tomcat/conf/server.xml \
  && chown ohmage.root /usr/local/tomcat/lib/catalina-jmx-remote.jar
 
EXPOSE 80
EXPOSE 1099
EXPOSE 10001
EXPOSE 10002
 
VOLUME /var/lib/ohmage
VOLUME /var/lib/mysql

CMD ["/run.sh"]