FROM quay.io/keboola/docker-custom-r:1.5.3

WORKDIR /code

# Initialize the tree runner
COPY . /code/

# Install some commonly used R packages and the R application
RUN Rscript ./init.R

# Install the app-tree package which is in the local directory
RUN R CMD build .
RUN R CMD INSTALL keboola.r.custom.application.tree_*

# Run the application
ENTRYPOINT Rscript ./main.R /data/
