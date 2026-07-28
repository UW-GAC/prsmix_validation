FROM rocker/tidyverse:4

RUN Rscript -e 'install.packages(c("remotes"))'
RUN Rscript -e 'remotes::install_github("schaidlab/pgsmetrics", upgrade=FALSE)'
