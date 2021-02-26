###################################################################################################
##                                                                                               ##
##                                                                                               ##
##                                 Application de suivi des tests                                ##
##                                                                                               ##
##                                         Fichier global                                        ##
##                                                                                               ##
##                                                                                               ##
###################################################################################################

## 1. Packages  ----
pacotes = c("shiny", "shinythemes", "plotly", "tidyverse",
            "scales",  "dplyr",
            'htmlwidgets', 'shinyWidgets', 'lubridate', 'stringr', 'formattable',
            'rmarkdown')

# Run the following command to verify that the required packages are installed. If some package
# is missing, it will be installed automatically
package.check <- lapply(pacotes, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
  }
})

## 2. Chargement des données ----
setwd('/Users/Antoine/Documents/Olympique de Neuilly/Saison 2020-2021/U13F/Tests')
Tests_2020 <- read.csv2('Tests_2020.csv', fileEncoding = 'UTF-8', stringsAsFactors = TRUE)
Tests_2021 <- read.csv2('Tests_2021.csv', fileEncoding = 'UTF-8', stringsAsFactors = TRUE)
data <- rbind(Tests_2020, Tests_2021)
players_ID <- read.csv2('players_ID.csv')
equipe <- read.csv2('Equipes.csv')
transfert_ID <- read.csv2('transfert_ID.csv')
players_ID <- rbind(players_ID, transfert_ID)

## 3. Création de la liste des joueuses ----
players_ID$Nom_complet <- paste(str_to_upper(players_ID$Nom), players_ID$Prénom, sep = ' ')
players_ID$Date_Naissance <- as.Date(players_ID$Date_Naissance, format = '%d/%m/%Y')
players_ID$Annee_Naissance <- year(players_ID$Date_Naissance)

## 4. Création de la table complète ----
data <- merge(data, players_ID[, c('Nom_complet', 'Annee_Naissance')], by.x = 'Joueuse', by.y = 'Nom_complet', all.x = TRUE)
data$Age <- data$Saison - data$Annee_Naissance
data <- merge(data, equipe, by = 'Age', all.x = TRUE)
data$Sous_cat <- ifelse(data$Age > 20, 'Sénior', paste('U', data$Age, 'F', sep = ''))



