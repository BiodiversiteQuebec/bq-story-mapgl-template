
home_section <- function(){
  story_section(
    "Exploration des espèces",
    content = (fluidPage(
      tags$head(includeCSS("www/home.css")),
      h4("Espèces du Québec"))
    ),
    width= '100vw', 
    position = 'center'
  )
}