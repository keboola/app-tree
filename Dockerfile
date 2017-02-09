FROM quay.io/keboola/docker-base-r-packages:3.3.2-b

WORKDIR /home

# Initialize the tree runner
COPY . /home/

# Install some commonly used R packages and the R application
RUN Rscript ./init.R

# Install the app-tree package which is in the local directory
RUN R CMD build .
RUN R CMD INSTALL keboola.r.custom.application.tree_*

# Run the application
ENTRYPOINT Rscript ./main.R /data/
