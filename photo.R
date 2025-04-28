

library(jsonlite)

photo_section <- function(sdm){
  story_section(
    "",
    content = (fluidPage(
      tags$head(includeCSS("www/photo.css"),
      tags$script(HTML("
      Shiny.addCustomMessageHandler('scrollTo', function(anchor) {
        setTimeout(function(){document.getElementsByName(anchor)[0].scrollIntoView({ behavior: 'smooth' });},2000)
      });
    "))),
      fluidRow(
        a(name='photos'),
        uiOutput("photos")
      )    )),
    width= '100vw', 
    position = 'center'
  )
}

photo_server <- function(input, espece){
  maplibre_proxy("map") |>
    clear_layer("sdm-layer")
  maplibre_proxy("map") |> 
    clear_layer('aires-layer')
  renderUI({
    sp <- espece()
    if(sp !='' & input$go){
      photo_files <- getCC0links(sp)$url[1:12]
      n <- length(photo_files)
  
      photo_elements <- lapply(1:n, function(i) {
        div(div(style=paste0('float:left;background:url("',photo_files[i],'");width:25vw;height:25vw;background-size:cover;background-position:center;')),style='width:100vw')
      })
      fluidRow(photo_elements)
    }
  })
}

getCC0links<-function(species,license=c("cc0", "cc-by", "cc-by-nc")){  
  sp<-gsub(" ","%20",species)
  cc<-paste(license,collapse="0%2C")
  urlsearch<-paste0("https://api.inaturalist.org/v1/taxa?q=",sp,"&order=desc&order_by=observations_count")
  x<-fromJSON(urlsearch)$results
  taxonid<-x$id[1]
  x<-fromJSON(paste0("https://api.inaturalist.org/v1/observations?photo_license=",cc,"&taxon_id=",taxonid,"&&quality_grade=research&order=desc&order_by=created_at"))
  if(x$total_results==0){
    return(NA)
  }else{
    x<-x$results
  }
  users<-x$user[,c("login","name")]
  pics<-do.call("rbind",lapply(seq_along(x$observation_photos),function(i){
    res1<-x$observation_photos[[i]]$photo[,c("url","license_code","attribution")]
    res2<-x$observation_photos[[i]]$photo$original_dimensions[,c("width","height")]
    res<-cbind(res1,res2)
    res<-res[1,] 
    cbind(id=x$id[i],res,users[rep(i,nrow(res)),])
  })) 
  pics$url<-gsub("/square","/medium",pics$url)
  pics<-pics[which(pics$width>205 & pics$height>205),]
  pics
}

