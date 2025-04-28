# Fonction pour choisir un ficher d'aires de repartition parmi ceux du gouvernement
aires <- function(input)
{
    return(st_read("data/Aires_repartition.gpkg"))
}


# Fonction pour produire la carte de l'aire de repartition de l'espece
render_aires <- function(species_data)
{
  maplibre(
    carto_style("positron"),
    bounds = species_data,
    scrollZoom = FALSE
  ) |>
    add_fill_layer(
      id = "species_layer",
      source = species_data,
      fill_color = "blue",
      fill_opacity = 0.5
    )
}

# Function to produire le tableau d'information extrait des fichiers du gouvernement
render_species_info <- function(species)
{
  french_name <- unique(species$nom_franca)
  english_name <- unique(species$nom_angla)
  scient_name <- unique(species$nom_scient)
  family_name <- unique(species$famille)
  area_value <- st_area(species) / 10^6
  
  tagList(
    h3(paste("Nom francais: ", french_name)),
    p(sprintf("Nom anglais: %s", english_name)),
    p(sprintf("Nom scientifique: %s", tags$em(scient_name))),
    p(sprintf("Famille: %s", family_name)),
    p(sprintf("Aire de répartition : %.2f km²", area_value)),
    p("Plus d'information à venir.")
  )
}

