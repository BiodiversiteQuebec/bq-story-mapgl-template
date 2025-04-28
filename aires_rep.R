# Fonction pour choisir un ficher d'aires de repartition parmi ceux du gouvernement
selected_community <- function(input)
{
  if (input$Community == "Amphibiens")
  {
    return(st_read("data/Aires_repartition_amphibiens.sqlite"))
  }
  else if (input$Community == "Mammifères")
  {
    return(st_read("data/Aires_repartition_MT.sqlite"))
  }
  else if (input$Community == "Poissons")
  {
    return(st_read("data/Aires_repartition_poisson_eau_douce.sqlite"))
  }
  else
  {
    return(st_read("data/Aires_repartition_reptiles.sqlite"))
  }
}

# Fonction pour obtenir la liste des especes dans un fichier
# Note: Pour le moment le nom pour les fichiers .sqlite sont utilises
get_species_choices <- function(community)
{
  sort(unique(community$nom_franca))
}

# Fonction pour obtenir l'aire de repartition de l'espece choisie
# Note: Ici encore, le nom pour les fichiers .sqlite est utilise
sel_species <- function(input, selected_community)
{
  community_data <- selected_community(input)
  filter(community_data, nom_franca == input$Espèces)
}


# Fonction pour produire la carte de l'aire de repartition de l'espece
render_species_map <- function(community_data, species_data)
{
  maplibre(
    carto_style("positron"),
    bounds = community_data,
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

