# sudo docker build -t countryyear -f code/Dockerfile .
# docker run -ti --rm -v "$PWD":/home/docker -w /home/docker -u docker countryyear

FROM r-base

RUN apt-get update \ 
    && apt-get install -y --no-install-recommends \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssh2-1-dev \
    bzip2

RUN install2.r --error \ 
    -r 'http://cran.rstudio.com' \
    pacman \
    tibble \
    dplyr \
    tidyr \
    readr \
    readxl \
    testthat \
    httr \
    jsonlite \
    xml2 \
    rvest \
    wdman \
    RSelenium \
    crayon \
    praise \
    janitor \
    countrycode
