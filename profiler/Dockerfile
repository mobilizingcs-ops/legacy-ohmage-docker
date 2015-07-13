FROM ohmage/platform
MAINTAINER Steve Nolen <technolengy@gmail.com>
# Report issues here: https://github.com/ohmage/docker

ADD server.xml /usr/local/tomcat/conf/server.xml
ADD catalina-jmx-remote.jar /usr/local/tomcat/lib/catalina-jmx-remote.jar
RUN chown ohmage.root /usr/local/tomcat/conf/server.xml \
  && chown ohmage.root /usr/local/tomcat/lib/catalina-jmx-remote.jar
 
EXPOSE 80
EXPOSE 1099
EXPOSE 10001
EXPOSE 10002
 
VOLUME /var/lib/ohmage
VOLUME /var/lib/mysql

ADD run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]