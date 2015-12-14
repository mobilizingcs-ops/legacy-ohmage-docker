FROM ohmage/base
MAINTAINER Steve Nolen <technolengy@gmail.com>
# Report issues here: https://github.com/ohmage/docker
 
RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y nginx-full git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#### download/extract ohmage frontends ####
ENV OHMAGE_PKGS_URL https://web.ohmage.org/ohmage/packages/latest
WORKDIR /var/www
RUN rm -rf * \
  && git clone https://github.com/mobilizingcs/navbar.git --single-branch .
RUN mkdir /var/www/webapps \
  && ln -s /var/www/webapps /var/www/navbar

WORKDIR /var/www/webapps/
RUN git clone https://github.com/mobilizingcs/monitor \
  && git clone --single-branch https://github.com/mobilizingcs/admin \
  && git clone --single-branch https://github.com/mobilizingcs/campaigns \
  && git clone --single-branch https://github.com/mobilizingcs/documents \
  && git clone --single-branch https://github.com/mobilizingcs/responses \
  && git clone --single-branch https://github.com/mobilizingcs/author \
  && git clone --single-branch https://github.com/mobilizingcs/classes
#  && git clone --single-branch https://github.com/mobilizingcs/demo

# frontends that need compiling. not doing that here for now.
WORKDIR /var/www/webapps/survey
RUN curl -fsl  "$OHMAGE_PKGS_URL"/survey.tar.gz -o /var/www/webapps/survey/survey.tar.gz \
  && tar -xvf survey.tar.gz --strip-components=1 \
  && rm survey.tar.gz

WORKDIR /var/www/webapps/dashboard
RUN curl -fsl  "$OHMAGE_PKGS_URL"/dashboard.tar.gz -o /var/www/webapps/dashboard/dashboard.tar.gz \
  && tar -xvf dashboard.tar.gz --strip-components=1 \
  && rm dashboard.tar.gz

# make sure nginx can read the static content
RUN chown -R www-data.www-data /var/www \
  && chmod -R 0770 /var/www
 
RUN sed -i 's/#platform-bits-here/service nginx start/g' /run.sh
ADD nginx-ohmage /etc/nginx/sites-available/ohmage
 
RUN ln -s /etc/nginx/sites-available/ohmage /etc/nginx/sites-enabled/ohmage \
    && rm /etc/nginx/sites-enabled/default
 
EXPOSE 80
 
VOLUME /var/lib/ohmage
VOLUME /var/lib/mysql

CMD ["/run.sh"]