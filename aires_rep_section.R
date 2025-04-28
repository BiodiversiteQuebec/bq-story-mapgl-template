# Fonction pour choisir un ficher d'aires de repartition parmi ceux du gouvernement

aires <- st_read("data/aires_repartition.gpkg")
aires_pmtiles <- 'https://object-arbutus.cloud.computecanada.ca/bq-io/geoio/aires_repartition.pmtiles'


aires_rep_section <- function(){
  story_section(
    "Répartition de l'espèce au Québec",
    content = (fluidPage(
      tags$head(includeCSS("www/home.css")),
      h4("Aires de répartition validée par des experts (MELCCFP)"))
    ),
    width= '40vw', 
    position = 'left'
  ) 
}  


# Fonction pour produire la carte de l'aire de repartition de l'espece
render_aires <- function(espece){
    maplibre_proxy("map") |>
      clear_layer("sdm-layer") |>  
      fit_bounds(data) |>
      add_fill_layer(
        id = "aires-layer",
        source = 'aires',
        source_layer = 'aires_repartition',
        fill_color = "blue",
        fill_opacity = 0.5,
        filter = list('==','NOM_SCIENT',espece)
      )
}
# Function to produire le tableau d'information extrait des fichiers du gouvernement
render_species_info <- function(species)
{
  data <- aires |> filter(NOM_SCIENT==species)
  french_name <- unique(data$nom_franca)
  english_name <- unique(data$nom_angla)
  scient_name <- unique(data$nom_scient)
  family_name <- unique(data$famille)
  area_value <- st_area(data) / 10^6
  
  tagList(
    h3(paste("Nom francais: ", french_name)),
    p(sprintf("Nom anglais: %s", english_name)),
    p(sprintf("Nom scientifique: %s", tags$em(scient_name))),
    p(sprintf("Famille: %s", family_name)),
    p(sprintf("Aire de répartition : %.2f km²", area_value)),
    p("Plus d'information à venir.")
  )
}

