FROM rocker/tidyverse:4

RUN mkdir -p /usr/local
RUN (cd /usr/local && wget https://raw.githubusercontent.com/UW-GAC/pgsc_calc_wdl/refs/heads/main/ancestry_adjustment.R)
RUN (cd /usr/local && git clone https://github.com/UW-GAC/prsmix_validation.git)

RUN Rscript -e 'install.packages(c("remotes"))'
RUN Rscript -e 'remotes::install_github("schaidlab/pgsmetrics", upgrade=FALSE)'
