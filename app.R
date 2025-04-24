library(shiny)
library(mapgl)
library(tidycensus)
library(tidyverse)
library(sf)

fl_age <- get_acs(
  geography = "tract",
  variables = "B01002_001",
  state = "FL",
  year = 2023,
  geometry = TRUE
) |>
  separate_wider_delim(NAME, delim = "; ", names = c("tract", "county", "state")) %>%
  st_sf()

ui <- fluidPage(
  story_maplibre(
    map_id = "map",
    sections = list(
      "home" = story_section(
        "Exploration des espèces",
        content = (fluidPage(
          tags$head(includeCSS("www/home.css")),
          h4("Espèces du Québec"))
          ),
        width= '100vw', 
        position = 'center'
      ),
      "page2" = story_section(
        "Page 2",
        content = (fluidPage(
          tags$head(includeCSS("www/home.css")),
          h4("Page 2"))
        ),
        width= '100vw', 
        position = 'center'
      ),
            "intro" = story_section(
        "Median Age in Florida",
        content = list(
          selectInput(
            "county",
            "Select a county",
            choices = sort(unique(fl_age$county))
          ),
          p("Scroll down to view the median age distribution in the selected county.")
        )
      ),
      "county" = story_section(
        title = NULL,
        content = list(
          uiOutput("county_text"),
          plotOutput("county_plot")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  sel_county <- reactive({
    filter(fl_age, county == input$county)
  })
  
  output$map <- renderMaplibre({
    maplibre(
      carto_style("positron"),
      bounds = fl_age,
      scrollZoom = FALSE
    ) |>
      add_fill_layer(
        id = "fl_tracts",
        source = fl_age,
        fill_color = interpolate(
          column = "estimate",
          values = c(20, 80),
          stops = c("lightblue", "darkblue"),
          na_color = "lightgrey"
        ),
        fill_opacity = 0.5
      ) |>
      add_legend(
        "Median age in Florida",
        values = c(20, 80),
        colors = c("lightblue", "darkblue"),
        position = "bottom-right"
      )
  })
  
  output$county_text <- renderUI({
    h2(toupper(input$county))
  })
  
  output$county_plot <- renderPlot({
    ggplot(sel_county(), aes(x = estimate)) +
      geom_histogram(fill = "lightblue", color = "black", bins = 10) +
      theme_minimal() +
      labs(x = "Median Age", y = "")
  })
  
  on_section("map", "intro", {
    maplibre_proxy("map") |>
      set_filter("fl_tracts", NULL) |>
      fit_bounds(fl_age, animate = TRUE)
  })
  
  on_section("map", "county", {
    maplibre_proxy("map") |>
      set_filter("fl_tracts", filter = list("==", "county", input$county)) |>
      fit_bounds(sel_county(), animate = TRUE)
  })
  
}

shinyApp(ui, server)