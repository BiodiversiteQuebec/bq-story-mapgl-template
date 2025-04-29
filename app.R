library(shiny)
library(terra)
library(mapgl)
library(dplyr)
library(tidyr)
library(sf)
library(viridisLite)
options(shiny.port = 8088)

source('home.R')
source('aires_rep_section.R')
source('sdm_section.R')
source('photo.R')

ui <- fluidPage(
  tags$head(tags$script(HTML("
      Shiny.addCustomMessageHandler('scrollTo', function(anchor) {
        document.getElementById(anchor).scrollIntoView({ behavior: 'smooth', block: 'start'  });
      });
  "))),
  story_maplibre(
    map_id = "map",
    sections = list(
      "home" = home_section(),
      "aires" = aires_rep_section(),
      "photos" = photo_section(),
      "sdm" = sdm_section()
    )
  )
)

server <- function(input, output, session) {

  espece <- eventReactive(input$go, {
    input$espece
  })
  
  observeEvent(input$go, {
    session$sendCustomMessage(type = 'scrollTo', message = 'section-aires')
  })
  
  output$map <- renderMaplibre({
    maplibre(
      carto_style("positron"),
      zoom=2,
      center=c(-70,53),
      scrollZoom = FALSE
    ) |> set_projection('globe') |>
      add_raster_source(
        id = "sdm",
        tiles = url
      ) |>
      add_vector_source('aires',url=paste0('pmtiles://',aires_pmtiles))
  })
  
  output$county_text <- renderUI({
    h2(toupper(input$county))
  })
  
  output$espece <- renderText({ input$espece })
  
  output$photos <- photo_server(input)
  
  on_section("map", "home", {
    maplibre_proxy("map") |> fly_to(center=c(-70,53),zoom=2) |>
      clear_layer("sdm-layer") |> 
      clear_layer('aires-layer')
  })
  
  on_section("map", "sdm", {
    render_sdm()
  })

  on_section("map", "aires", {
    render_aires({espece()})
  })
  
  on_section("map", "photos",{
    maplibre_proxy("map") |>
      clear_layer("sdm-layer") |> 
      clear_layer('aires-layer')
  })
  output$photos <- photo_server(input, espece)
}

app <- shinyApp(ui, server)
runApp(app, host ="0.0.0.0", port = 8088, launch.browser = FALSE)