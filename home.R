
home_section <- function(){
  story_section(
    "",
    content = (fluidPage(
      tags$head(includeCSS("www/home.css")),
      fluidRow(column(width=12, align='center', img(src='images/logo_bq.png', style='max-width:70%;margin:auto'))),
      fluidRow(column(width=12, align='center', textInput(inputId='espece', label='', placeholder = "Entrer un nom d'espèce"), style='margin:auto')),
    )),
    width= '100vw', 
    position = 'center'
  )
}

home_server <- function(){
  output$value <- renderText({ input$espece })
}