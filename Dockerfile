# Base R Shiny image
FROM rocker/geospatial

# Make a directory in the container
RUN mkdir /home/shiny-app

# Install R dependencies
RUN R -e "install.packages(c('pak')); \
          pak::pak(c('mapgl','viridisLite'))"

# Copy the Shiny app code
COPY app.R /home/shiny-app/app.R

# Run the R Shiny app
CMD ["R", "-e", "library(shiny); setwd('/home/shiny-app/'); addResourcePath('www', '/home/shiny-app/www'); source('app.R')"]