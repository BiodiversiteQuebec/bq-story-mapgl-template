library(shiny)
library(terra)
library(mapgl)
library(tidycensus)
library(dplyr)
library(tidyr)
library(sf)
library(viridisLite)

source('home.R')
source('sdm_section.R')
source('photo.R')

ui <- fluidPage(
  tags$head(tags$script(HTML("
      Shiny.addCustomMessageHandler('scrollTo', function(anchor) {
        document.getElementsByName(anchor)[0].scrollIntoView({ behavior: 'smooth' });
      });
  "))),
  story_maplibre(
    map_id = "map",
    sections = list(
      "home" = home_section(),
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
    session$sendCustomMessage(type = 'scrollTo', message = 'photos')
  })
  
  output$map <- renderMaplibre({
    maplibre(
      carto_style("positron"),
      zoom=4,
      center=c(-70,53),
      scrollZoom = FALSE
    ) |> set_projection('globe') |>
      add_raster_source(
        id = "sdm",
        tiles = url
      )
  })
  
  output$county_text <- renderUI({
    h2(toupper(input$county))
  })
  
  output$espece <- renderText({ input$espece })
  
  output$photos <- photo_server(input)
  
  output$county_plot <- renderPlot({
    ggplot(sel_county(), aes(x = estimate)) +
      geom_histogram(fill = "lightblue", color = "black", bins = 10) +
      theme_minimal() +
      labs(x = "Median Age", y = "")
  })
  
  on_section("map", "sdm", {
    render_sdm()
  })
  
  output$photos <- photo_server(input, espece)

}

shinyApp(ui, server)