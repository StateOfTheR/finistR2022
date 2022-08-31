
FROM rocker/geospatial:4
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update \
 && apt-get install -y pandoc \
    pandoc-citeproc
RUN R -e "install.packages('remotes')"
RUN R -e "install.packages('microbenchmark')"
RUN R -e "install.packages('purrr')" # map function
RUN R -e "install.packages('BiocManager')" # map function
RUN R -e "BiocManager::install('BiocPkgTools')" 
RUN R -e "install.packages('httr')" # GET function
ENV R_CRAN_WEB="https://cran.rstudio.com/" 
RUN R -e "install.packages('cowplot')" # GET function
RUN R -e "install.packages('torch')"
RUN R -e "torch::install_torch(type = 'cpu')"
RUN R -e "install.packages('PLNmodels')"
RUN R -e "install.packages('torchvision')"
