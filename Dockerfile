FROM debian:buster

MAINTAINER Daniel Konrad <mail@daniel-konrad.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-transport-https wget gnupg gnupg2 gnupg1

ADD open-xchange.list /etc/apt/sources.list.d/open-xchange.list
ADD adoptopenjdk.list /etc/apt/sources.list.d/adoptopenjdk.list

RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN wget http://software.open-xchange.com/oxbuildkey.pub -O - | apt-key add - && \
    apt-get update && \
    apt-get install -y \
        vim \
        open-xchange \
        open-xchange-authentication-database \
        open-xchange-grizzly \
        open-xchange-admin open-xchange-appsuite \
        open-xchange-appsuite-backend \
        open-xchange-appsuite-manifest

ADD proxy_http.conf /etc/apache2/conf-available/proxy_http.conf
ADD open-xchange /etc/apache2/sites-enabled/000-default.conf

RUN a2enmod proxy proxy_http proxy_balancer expires \
    deflate headers rewrite mime setenvif && \
    a2enconf proxy_http.conf

RUN    mkdir -p -m 0777 /ox /ox/store && \
    chown open-xchange:open-xchange /ox/store

ADD run.sh /ox/run.sh

VOLUME ["/ox/store", "/var/lib/mysql"]

EXPOSE 80

CMD /ox/run.sh; bash
