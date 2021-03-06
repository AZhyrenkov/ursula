FROM rocker/shiny:latest

MAINTAINER Aleksey Zhirenkov "ozhyrenkov@gmail.com"
# Inspired by Sebastian Kranz "sebastian.kranz@uni-ulm.de" https://github.com/skranz/shinyrstudioDocker

# Prepare linux environment
RUN apt-get update && \
    apt-get install -y \
        gdebi-core \
        libxml2-dev \
        apt-utils \
        libcairo2-dev \
        libsqlite0-dev \
        libmariadbd-dev \
        libmariadb-client-lgpl-dev \
        libpq-dev \
        libssh2-1-dev \
        sudo \
        openssl \
        libgit2-dev \
        libssl-dev \
        pandoc \
        pandoc-citeproc \
        libcurl4-gnutls-dev \
        libcairo2-dev \
        libxt-dev && \
    wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    rm -rf /var/lib/apt/lists/*



#install necessary packages 
RUN su - -c "R -e \"source('https://bioconductor.org/biocLite.R')\""

# basic R stuff
RUN su - -c "R -e \"install.packages(c('shiny','tidyverse','ggplot2','formatR','remotes','selectr','dplyr', repos='https://cran.rstudio.com/')\""

# R dtabase stuff
RUN su - -c "R -e \"install.packages(c('DBI','RODBC','RMySQL','RPostgreSQL', repos='https://cran.rstudio.com/')\""

# R extras
RUN su - -c "R -e \"install.packages(c('devtools','slackr','corrr','carret', repos='https://cran.rstudio.com/')\""

#install shiny stuff
RUN wget\
  https://raw.github.com/rstudio/shiny-server/master/config/upstart/shiny-server.conf\
  -O /etc/init/shiny-server.conf

# Copy run-shiny.sh to the right location to start up the shiny server

RUN mkdir -p /etc/services.d/shiny-server

# Copy configs and service runners
COPY conf/shiny-server.sh /usr/bin/shiny-server.sh 
COPY conf/run-shiny.sh /etc/services.d/shiny-server/run
COPY conf/run-rstudio.sh /etc/services.d/rstudio/run
COPY conf/userconf.sh /etc/cont-init.d/conf

CMD ["/init"]