###################################################################################################
##                                                                                               ##
##                                                                                               ##
##                                 Application de suivi des tests                                ##
##                                                                                               ##
##                                           Fichier UI                                          ##
##                                                                                               ##
##                                                                                               ##
###################################################################################################


shinyUI(navbarPage(title = "Les résultats des tests",
                   #tags$div(tags$img(src = 'Ecusson.png', width = 130, height = 100, style = 'float:left; margin-left: 5px; margin-right: 5px, margin-top: -15px')),

           ## 1. Page A propos ----
           tabPanel('A propos', icon = icon('ellipsis-v'),
                    fluidPage(theme = shinytheme("flatly")),
                    fluidRow(
                      column(11,
                        imageOutput('Logo', width = 200, height = 200),
                        align = 'center'
                      )
                      
                    ),
                    br(),
                    p("La section féminine de l'Olympique de Neuilly regroupe une centaine de licenciées 
                      reparties en cinq catégories : U11F, U13F, U15F, U18F et Sénior. A cela s'ajoute 
                      également des filles, plus jeunes, membres de l'école de foot."),
                    p("Des tests sont réalisés trois fois par saison pour suivre et chiffrer
                      la progression individuelle. Ils sont au nombre de onze : 
                      deux tests de conduite (pied droit et pied gauche),
                      trois tests de jonglage (pied droit, pied gauche et tête), 
                      trois tests de vitesse (sur 10m, 20m et 40m),
                      un test de VMA (Luc-Léger) et un test de vivacité."),
                    fluidRow(
                      column(6,
                        h4('Conduite'),
                        p("Le premier test est un parcours de conduite de balle. La joueuse 
                          démarre debout, le ballon arrêté posé au sol devant lui sur la ligne de départ.
                          Elle démarre quand elle le souhaite, le chronomètre est lancé dès que le ballon bouge.
                          La joueuse effectue une conduite de balle d'un seul pied (surfaces de contacts libres)
                          en forme de double-huit pour finir en franchissant la même ligne qu'au départ.
                          Le chronomètre s'arrête dès que le buste franchit la ligne d'arrivée (1m d'écart maximum
                          autorisé entre le corps du et le ballon à l'arrivée). Les deux plots sont distants
                          de 5m. Deux essais pied droit, deux essais pied gauche."),
                      ),
                      column(4,
                             imageOutput('conduite')
                      )
                    ),
                    fluidRow(
                      column(6,
                             h4('Jonglage'),
                             p("Trois tests de jonglage sont réalisés : pied droit, pied gauche et tête.
                               Chaque joueuse effectue deux essais consécutifs pour chaque pied et pour
                               la tête. Pour les essais aux pieds, le ballon démarre au sol, le joueur
                               lève le ballon à l'aide des pieds, aucune surface de rattrapage n'est
                               autorisée. La joueuse qui arrive à 50 répétitions est arrêté.
                               Pour la tête, le ballon est tenu et lancé à deux mains au départ, ensuite 
                               seules les frappes de tête sont autorisées, la joueuse arrivée à 50 répétitions
                               est arrêtée.")
                      ),
                      column(4,
                             imageOutput('jonglage')
                      )
                    ),
                    fluidRow(
                      column(6,
                             h4('Vitesse'),
                             p("Trois tests de vitesse sont réalisés, sur trois distances différentes : 10 mètres,
                               20 mètres et 40 mètres. La joueuse démarre débout, pieds derrière la ligne de départ,
                               le chronomètre manuel démarre dès le décollement du pied arrière. Le test se termine 
                               dès que le buste franchit la ligne d'arrivée. Deux essais par joueuse.")
                      ),
                      column(4,
                             imageOutput('vitesse')
                      )
                    ),
                    fluidRow(
                      column(6,
                             h4('Luc-Léger'),
                             p("Le test Luc-Léger est un test de VMA. La joueuse court, entre deux
                               lignes séparées de 20 mètres, selon un rythme donné par l'éducateur.")
                      ),
                      column(4,
                             imageOutput('VMA')
                      )
                    ),
                    fluidRow(
                      column(6,
                             h4('Vivacité'),
                             p("Le test de vivacité est dit en L. La joueuse démarre debout derrière
                               la ligne de départ, elle effectue un aller-retour sans toucher les plots.
                               Le chronomètre démarre dès le soulèvement du pied arrière. Le test
                               s'arrête dès que le buste de la joueuse franchit la ligne d'arrivée. Les
                               deux côtés du L mesurent 5m chacun. Deux essais par joueuse.")
                      ),
                      column(4,
                             imageOutput('vivacite')
                      )
                    ),
                    
                    p("Cette application met à disposition les résultats obtenus par les joueuses
                      du club depuis plusieurs années, pour chaque test. Les tests actuels ont été
                      mis en place à partir de la saison 2020-2021.")
                    ),
           
           
           ## 2. Page Saison actuelle ---- 
           tabPanel('Saison actuelle', icon = icon('bars'),
                    pageWithSidebar(
                      headerPanel('Saison actuelle'),
                      sidebarPanel(width = 4,
                                   
                                   helpText("Les options ci-dessous permettent de modifier les
                                            informations affichées dans la partie centrale"),
                                   
                                   # Filtre par catégorie
                                   radioButtons(inputId = "Equipe",
                                                      label = "L'équipe :", 
                                                      choices = c("U11F",
                                                                  "U13F",
                                                                  "U15F",
                                                                  "U18F",
                                                                  "Sénior"),
                                                      selected = c("U13F"), 
                                                      inline = FALSE),
                                   
                                   # Filtre par sous-catégorie
                                   conditionalPanel(condition = "input.team_players == 1 | input.team_players == 3",
                                                    checkboxGroupInput(inputId = "Sous_cat",
                                                      label = 'Sous-catégorie :', 
                                                      inline = FALSE)),
                                   
                                   # Choisir la joueuse
                                   conditionalPanel(condition = 'input.team_players == 3',
                                                    selectInput(inputId = 'Joueuse',
                                                                label = 'La joueuse :',
                                                                choices = c(),
                                                                selectize = FALSE)),
                                   
                                   # Tests à afficher
                                   conditionalPanel(condition = "input.team_players == 1",
                                                    selectInput(inputId = 'Tests',
                                                                label = 'Tests à afficher :',
                                                                choices = c('Luc-Léger',
                                                                            'Conduite pied droit',
                                                                            'Conduite pied gauche',
                                                                            'Jonglage pied droit',
                                                                            'Jonglage pied gauche',
                                                                            'Jonglage tête',
                                                                            'Détente',
                                                                            'Vivacité L',
                                                                            'Vitesse 10m',
                                                                            'Vitesse 20m',
                                                                            'Vitesse 40m'),
                                                                selected = c('Luc-Léger',
                                                                             'Conduite pied droit',
                                                                             'Conduite pied gauche',
                                                                             'Jonglage pied droit',
                                                                             'Jonglage pied gauche',
                                                                             'Jonglage tête',
                                                                             'Détente',
                                                                             'Vivacité L',
                                                                             'Vitesse 10m',
                                                                             'Vitesse 20m',
                                                                             'Vitesse 40m'),
                                                                multiple = TRUE,
                                                                selectize = TRUE)),
                                   
                                   # Ordre d'affichage
                                   conditionalPanel(condition = "input.team_players == 1",
                                                    selectInput(inputId = 'Ordre',
                                                    label = 'Ordonner le tableau selon :',
                                                    choices = c('Nom' = 'Joueuse',
                                                                data$Test %>% levels()),
                                                    selected = c('Nom' = 'Joueuse'),
                                                    selectize = TRUE)),
                                   
                                   # Ordre d'affichage
                                   conditionalPanel(condition = 'input.team_players == 1',
                                                    helpText("Les résultats aux tests peuvent s'afficher de 
                                                    différentes façons.")),
                                   conditionalPanel(condition = 'input.team_players == 1',
                                                    radioButtons(inputId = 'Affichage',
                                                                 label = 'Choisir les informations à afficher :',
                                                                 choices = c('Meilleur résultat' = 4,
                                                                             'Session 1' = 1,
                                                                             'Session 2' = 2,
                                                                             'Session 3' = 3),
                                                                 selected = c('Meilleur résultat' = 4),
                                                                 inline = FALSE)),
                                   
                                   # Choisir le test
                                   conditionalPanel(condition = 'input.team_players == 2',
                                                    selectInput(inputId = 'Test',
                                                                label = 'Le test :',
                                                                choices = c('Luc-Léger',
                                                                            'Conduite pied droit',
                                                                            'Conduite pied gauche',
                                                                            'Jonglage pied droit',
                                                                            'Jonglage pied gauche',
                                                                            'Jonglage tête',
                                                                            'Détente',
                                                                            'Vivacité L',
                                                                            'Vitesse 10m',
                                                                            'Vitesse 20m',
                                                                            'Vitesse 40m'),
                                                                #selected = c('Luc-Léger'),
                                                                selectize = FALSE)),
                                   
                                   
                                   # Bouton de téléchargement
                                   conditionalPanel(condition = 'input.team_players == 1',
                                                    helpText('Le tableau affiché dans la partie centrale peut être
                                                             téléchargé au format CSV')),
                                   conditionalPanel(condition = 'input.team_players == 1',
                                                    downloadButton(outputId = 'Download',
                                                                   label = 'Télécharger le tableau'))
                                   
                                   
                                   ),
  
                      mainPanel(
                        tabsetPanel(
                          tabPanel('Tableau général', value = 1, tableOutput('table')),
                          tabPanel('Le test', value = 2, plotlyOutput('vuecollective')),
                          tabPanel('La joueuse', value = 3, formattableOutput('tableInd2')#, fluidRow(textOutput('classementMoyen'))
                                   ),
                          id = 'team_players'
                        )
                        )
                      )
                    ),
           
           ## 3. Page Records ---- 
           tabPanel('Records', icon = icon('trophy'),
                    pageWithSidebar(
                      headerPanel('Records en cours'),
                      sidebarPanel(width = 4,
                                   
                                   # Sélectionner une catégorie
                                   radioButtons(inputId = 'cat',
                                                label = 'Catégories :',
                                                choices = c('Toutes catégories confondues' = 1,
                                                            'Filter par sous-catégories' = 2)),
                                   conditionalPanel(condition = 'input.cat == 2',
                                                    selectInput(inputId = 'sous_cat',
                                                                label = 'Sous-catégories :',
                                                                choices = data$Sous_cat %>% unique() %>% na.omit(),
                                                                selected = data$Sous_cat %>% unique() %>% na.omit(),
                                                                multiple = TRUE)),                                   
                                   
                                   # Tests disponible
                                   conditionalPanel(condition = 'input.records != 1',
                                   selectInput(inputId = 'Test2',
                                                      label = 'Choisir le test :', 
                                                      choices = c('Luc-Léger',
                                                                  'Conduite pied droit',
                                                                  'Conduite pied gauche',
                                                                  'Jonglage pied droit',
                                                                  'Jonglage pied gauche',
                                                                  'Jonglage tête',
                                                                  'Détente',
                                                                  'Vivacité L',
                                                                  'Vitesse 10m',
                                                                  'Vitesse 20m',
                                                                  'Vitesse 40m'),
                                                multiple = FALSE)),
                                   
                                   # Afficher le top...
                                   conditionalPanel(condition = 'input.records != 1',
                                                    radioButtons(inputId = 'top',
                                                label = 'Afficher :',
                                                choices = c('Podium' = 3,
                                                            'Top 5' = 5,
                                                            'Top 10' = 10),
                                                selected = c('Top 5' = 5),
                                                inline = FALSE))

                                   ),
                      
                      mainPanel(
                        tabsetPanel(
                          tabPanel('Records absolus', value = 1, tableOutput('records')),
                          tabPanel('Meilleures performances', value = 2, tableOutput('Perf')),
                          tabPanel('Meilleures performeuses', value = 3, tableOutput('Perf2')),
                          id = 'records'
                        )
                        )
                    )
           ),
           
           ## 4. Page historique ----
           tabPanel('Historique', icon = icon('chart-line'),
                    pageWithSidebar(
                      headerPanel('Historique'),
                      sidebarPanel(),
                      mainPanel()
                    )),
           
           ## 5. Page Rapports ----
           tabPanel('Rapports', icon = icon('edit'),
                    pageWithSidebar(
                      headerPanel('Edition de rapports'),
                      sidebarPanel(
                        
                        # Saison actuelle
                        conditionalPanel(condition = 'input.rapport == 1',
                                         radioButtons(inputId = 'saison',
                                                      label = 'La saison :',
                                                      choices = c('Toutes saisons confondues' = 1,
                                                                  'Saison actuelle uniquement' = 2))),
                        
                        # Filtre par catégorie
                        radioButtons(inputId = 'catégorie',
                                     label = 'La catégorie :',
                                     choices = c('Toutes catégories confondues' = 1,
                                                 'U11F',
                                                 'U13F',
                                                 'U15F',
                                                 'U18F',
                                                 'Sénior')),
                        
                        # Filter d'affichage
                        conditionalPanel(condition = 'input.rapport == 1',
                                         numericInput(inputId = 'Top',
                                                      label = 'Afficher les ... meilleures par test',
                                                      value = 5))
                      ),
                      
                      mainPanel(
                        tabsetPanel(
                          tabPanel('Meilleures performeuses',
                                   value = 1,
                                   
                                   # Description du rapport
                                   p(),
                                   p("Ce rapport propose, pour chaque test réalisé, un tableau 
                                     rassemblant les meilleures joueuses/performeuses."),
                                   p(),
                                   p("Le rapport peut être modifié par trois critères. Le premier
                                     concerne la prise en compte ou non des tests réalisés les saisons
                                     passées. Le second critère est la catégorie concernée : le 
                                     rapport est disponible pour chacune d'entre elle. Le troisième
                                     est le nombre de joueuses affichées pour chaque test. Si le
                                     nombre est cinq (choix par défaut), les cinq meilleures 
                                     performeuses de chaque test seront affichées."),
                                   
                                   # Télécharger le rapport en pdf
                                   downloadButton(outputId = 'rapport_pdf',
                                                  label = 'PDF')
                                   ),
                          
                          tabPanel('Records absolus',
                                   value = 2,
                                   
                                   # Description du rapport
                                   p(),
                                   p("Ce rapport propose la liste des records. Celle-ci contient,
                                     pour chaque test, le record, la joueuse qui le détient, 
                                     la saison pendant laquelle il a été établi, la session pendant
                                     laquelle il a été établi et la sous-catégorie de la joueuse
                                     lorsqu'elle a établi le record."),
                                   p(),
                                   p("Le rapport peut être modifié par un seul critère. Il s'agit
                                     de la catégorie concernée."),
                                   
                                   # Télécharger le rapport en pdf
                                   downloadButton(outputId = 'rapport_records_pdf',
                                                  label = 'PDF')),
                          
                          tabPanel('Rapport individuel',
                                   value = 3),
                          id = 'rapport'
                        )
                        
                      )
                        
                    
                      )
                    )
                    
                    
           
           )
)


