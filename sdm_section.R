

library(sf)
library(jsonlite)

url <- "https://tiler.biodiversite-quebec.ca/cog/tiles/{z}/{x}/{y}?url=https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux/birds_setophaga_striata_1900-2024_breeding_0621-0726_brt_Predictors_Bias_noSpatial.tif&rescale=0,1&colormap_name=viridis&bidx=1&expression=b1"

url2 <- "/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux/birds_setophaga_striata_1900-2024_breeding_0621-0726_brt_Predictors_Bias_noSpatial.tif"

sdm <- rast(url2)
vals <- global(sdm, "range", na.rm = TRUE) |>
          unlist(use.names = FALSE) |>
          round(2)
cols <- adjustcolor(viridis(100), 0.5)


render_sdm <- function(){
    bounds <- st_bbox(sdm) |>
      st_as_sfc(crs = st_crs(sdm)) |>
      st_transform(crs = 4326) |>
      st_bbox() |>
      as.numeric()
    maplibre_proxy("map") |>
      clear_layer("aires-layer") |>  
      add_raster_layer(
        id = 'sdm-layer',
        source = 'sdm',
        raster_opacity = 0.75
      ) 
    #|>
    #  add_legend(
    #    "Probabilité de présence",
    #    values = vals,
    #    colors = cols,
    #    position = "bottom-right",
    #    layer_id = "sdm-layer"
    #  ) |>
    #  fit_bounds(bounds, animate = TRUE)
}


sdm_section <- function(){
  story_section(
    paste0("Modélisation de la distribution de l'espèce au Québec"),
    content = (fluidPage(
      tags$head(includeCSS("www/home.css")),
      h4("Modèle de distribution illustrant la probabilité de présence"))
    ),
    width= '40vw', 
    position = 'left'
  ) 
}  




