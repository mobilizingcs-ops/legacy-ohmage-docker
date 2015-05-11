FROM ohmage/base
MAINTAINER Steve Nolen <technolengy@gmail.com>
# Report issues here: https://github.com/ohmage/docker
 
RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y nginx-full git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
#### download ohmage ####
ENV OHMAGE_PKGS_URL https://web.ohmage.org/ohmage/packages/latest
 
WORKDIR $OHMAGE_DATA/flyway/sql
RUN curl -fSL "$OHMAGE_PKGS_URL"/server/app.war -o /usr/local/tomcat/webapps/app.war
RUN curl -fSL "$OHMAGE_PKGS_URL"/server/migrations.tar.gz -o migrations.tar.gz \
    && tar -xvf migrations.tar.gz \
    && rm migrations.tar.gz

#### download/extract ohmage frontends ####
WORKDIR /var/www
RUN git clone https://github.com/mobilizingcs/navbar.git -b generic --single-branch .
RUN mkdir /var/www/webapps \
  && ln -s /var/www/webapps /var/www/navbar

WORKDIR /var/www/webapps/web
RUN curl -fsl  "$OHMAGE_PKGS_URL"/gwt-front-end.tar.gz -o /var/www/webapps/web/gwt-front-end.tar.gz \
  && tar -xvf gwt-front-end.tar.gz \
  && rm gwt-front-end.tar.gz

WORKDIR /var/www/webapps/monitor
RUN git clone https://github.com/mobilizingcs/campaign_monitor .

WORKDIR /var/www/webapps/survey
RUN curl -fsl  "$OHMAGE_PKGS_URL"/survey.tar.gz -o /var/www/webapps/survey/survey.tar.gz \
  && tar -xvf survey.tar.gz --strip-components=1 \
  && rm survey.tar.gz

WORKDIR /var/www/webapps/dashboard
RUN curl -fsl  "$OHMAGE_PKGS_URL"/dashboard.tar.gz -o /var/www/webapps/dashboard/dashboard.tar.gz \
  && tar -xvf dashboard.tar.gz --strip-components=1 \
  && rm dashboard.tar.gz

# make sure nginx can read the static content
RUN chown -R www-data.www-data /var/www

 
ADD run.sh /run.sh
ADD nginx-ohmage /etc/nginx/sites-available/ohmage
 
RUN chmod +x /run.sh \
    && ln -s /etc/nginx/sites-available/ohmage /etc/nginx/sites-enabled/ohmage \
    && rm /etc/nginx/sites-enabled/default
 
EXPOSE 80
 
VOLUME /var/lib/ohmage
VOLUME /var/lib/mysql

CMD ["/run.sh"]