###################################################################################################
##                                                                                               ##
##                                                                                               ##
##                                 Application de suivi des tests                                ##
##                                                                                               ##
##                                        Fichier Server                                         ##
##                                                                                               ##
##                                                                                               ##
###################################################################################################


function(input, output, session) {
  
  ## 1. Page A propos ----
  
  # Logo Picture ----
  output$Logo <- renderImage(
    list(src = 'Ecusson.png',
         height = 200,
         alt = "Picture"),
    deleteFile = FALSE
  )
  
  # Import de l'illustration de la jonglerie
  output$jonglage <- renderImage(
    list(src = 'jonglage.png',
         height = 200,
         alt = "jonglage"),
    deleteFile = FALSE
  )
  
  # Import de l'illustration de la vitesse
  output$vitesse <- renderImage(
    list(src = 'vitesse.png',
         height = 200,
         alt = "vitesse"),
    deleteFile = FALSE
  )
  
  # Import de l'illustration de la vivacité
  output$vivacite <- renderImage(
    list(src = 'vivacite.png',
         height = 200,
         alt = "vivacite"),
    deleteFile = FALSE
  )
  
  # Import de l'illustration du Luc-Léger
  output$VMA <- renderImage(
    list(src = 'luc-léger.png',
         height = 200,
         alt = "luc-léger"),
    deleteFile = FALSE
  )
  
  # Import de l'illustration de la conduite
  output$conduite <- renderImage(
    list(src = 'conduite.png',
         height = 200,
         alt = "conduite"),
    deleteFile = FALSE
  )
  
  ## 2. Page Saison actuelle ----
  
  #### 2.1. Dépendance du filtre de sous-catégorie au filter de l'équipe ----
  observe({
    x <- data$Sous_cat[data$Equipe == input$Equipe] %>% na.omit()
    updateCheckboxGroupInput(session,
                             inputId = "Sous_cat",
                             choices = unique(x),
                             selected = unique(x))
  })
  
  #### 2.2. Modification de la liste de joueuse en fonction de la sous-catégorie sélectionnée ----
  observe({
    x <- data$Joueuse[data$Sous_cat %in% input$Sous_cat & data$Saison == max(data$Saison)]
    updateSelectInput(session,
                      inputId = "Joueuse",
                      choices = unique(x))
  })
  
  #### 2.3. Table générale ----
  first <- reactive(
    data %>% 
      filter(data$Sous_cat %in% input$Sous_cat,
             data$Saison == max(data$Saison),
             data$Session == min(data$Session))
  )
  session123 <- reactive(
    data %>% 
      filter(data$Sous_cat %in% input$Sous_cat,
             data$Saison == max(data$Saison),
             data$Session == input$Affichage)
  )
  best <- reactive({
    d <- data %>% 
      filter(data$Sous_cat %in% input$Sous_cat,
             data$Saison == max(data$Saison)) %>% 
      na.omit()
    chrono <- d %>% 
      filter(d$Test %in% test_chrono())
    non_chrono <- d %>% 
      filter(d$Test %in% test_nonchrono())
    chrono <- aggregate(chrono$Résultat, by = list(chrono$Joueuse, chrono$Test), FUN = function(x){min(x, na.rm = TRUE)})
    colnames(chrono) <- c('Joueuse', 'Test', 'Résultat')
    non_chrono <- aggregate(non_chrono$Résultat, by = list(non_chrono$Joueuse, non_chrono$Test), FUN = max)
    colnames(non_chrono) <- c('Joueuse', 'Test', 'Résultat')
    d <- rbind(chrono, non_chrono)
    return(d)
  })
  dataTable <- reactive({
    if(input$Affichage == 4){
      table <- best()
    } else {
      table <- session123()
    }
    return(table)
  })
  dataSpred <- reactive({
    spred <- dataTable() %>% 
      spread(Test, Résultat)
    return(spred)
  })
  dataOrdonnee <- reactive(
    dataSpred()[order(dataSpred()[input$Ordre], decreasing = chrono()), c('Joueuse', input$Tests)]
  )
  
  # Ordre croissant ou décroissant selon si le test est chronométré
  chrono <- reactive(
    ifelse(input$Ordre %in% c(test_chrono(), 'Joueuse'), FALSE, TRUE)
  )
  
  test_chrono <- reactive(
    c('Conduite pied droit',
      'Conduite pied gauche',
      'Vivacité L',
      'Vitesse 10m',
      'Vitesse 20m',
      'Vitesse 40m')
  )
  
  test_nonchrono <- reactive(
    c('Luc-Léger',
      'Jonglage pied droit',
      'Jonglage pied gauche',
      'Jonglage tête',
      'Détente')
  )
  
  output$table <- renderTable(dataOrdonnee())
  
  # Bouton de téléchargement
  output$Download <- downloadHandler(filename = 'tests.csv',
                                     content = function(file){
                                       write.csv2(dataOrdonnee(), file, row.names = FALSE)
                                     }
  )
  
  #### 2.4. Tableau individuel ----
  
  tableInd <- reactive({
    table <- data %>% 
      filter(data$Joueuse == input$Joueuse,
             data$Saison == max(data$Saison)) %>% 
      spread(Session, Résultat) %>% 
      select('Test', '1', '2')
    table$Progression <- (table$`2` - table$`1`) %>% round(2)
    table[table$Test %in% test_chrono(), 'Progression'] <- -table[table$Test %in% test_chrono(), 'Progression']
    best <- spread(best(), Test, Résultat)
    data <- data %>% filter(data$Saison == max(data$Saison)) %>% select('Joueuse', 'Equipe') %>% unique() %>% na.omit()
    best <- merge(best, data, by = 'Joueuse')
    rownames(best) <- best$Joueuse
    best <- best[, -1]
    best <- best %>% filter(best$Equipe == input$Equipe) %>% select(-Equipe)
    rank <- best
    for (col in colnames(rank)) {
      if (col %in% test_nonchrono()) {
        rank[, col] <- rank(desc(rank[, col]), na.last = 'keep', ties.method = "min")
      } else {
        rank[, col] <- rank(rank[, col], na.last = 'keep', ties.method = "min")
      }
    }
    rank <- t(rank) %>% as.data.frame() %>% select(input$Joueuse)
    table <- merge(table, rank, by.x = 'Test', by.y = 'row.names')
    td <- t(best) %>% as.data.frame() %>% select(input$Joueuse)
    table <- merge(table, td, by.x = 'Test', by.y = 'row.names')
    colnames(table) <- c('Test', 'Session 1', 'Dernière session', 'Progression', 'Classement', 'Meilleur score')
    table <- table[, c(1, 6, 5, 3, 4)]
    #table <- table[order(table$Classement),]
    return(table)
  })
  
  output$tableInd2 <- renderFormattable(
    formattable(tableInd(), align = c('l', 'c', 'c', 'c', 'c'),
                list(Test = formatter('span', style = ~ style(color = 'gray')), 
                     Progression = formatter('span', style = ~ style(color = ifelse(Progression < 0, 'red', ifelse(Progression > 0, 'green', 'grey'))),
                                             ~ icontext(ifelse(Progression > 0, 'arrow-up', ifelse(Progression < 0, 'arrow-down', 'arrow-right')), Progression))
                ))
  )
  output$classementMoyen <- renderText(
    paste('Classement moyen : ', tableInd()$Classement %>% mean(na.rm = TRUE) %>% round(1), sep = ''))
  
  #### 2.5. Dumbell plot ----
  
  dumbell <- reactive({
    a <- data %>%
    filter(data$Test == input$Test,
           data$Equipe == input$Equipe,
           data$Saison == max(data$Saison)) %>% 
    select('Joueuse', 'Session', 'Résultat')
  a <- spread(a, Session, Résultat)
  colnames(a) <- c('Joueuse', 'First', 'Last')
  a$Joueuse <- factor(a$Joueuse, levels = a$Joueuse[order(a$Last, decreasing = ifelse(input$Test %in% test_nonchrono(), FALSE, TRUE), na.last = FALSE)])
  p <- plot_ly(a, color = I("gray80")) %>% 
    add_segments(x = ~First, xend = ~Last, y = ~Joueuse, yend = ~Joueuse, showlegend = FALSE) %>% 
    add_markers(x = ~First, y = ~Joueuse, name = "Premier test", color = I("lightblue"), hoverinfo = 'text', text = ~paste0(Joueuse, '<br>', First)) %>% 
    add_markers(x = ~Last, y = ~Joueuse, name = "Dernier test", color = I("darkblue"), hoverinfo = 'text', text = ~paste0(Joueuse, '<br>', Last)) %>% 
    layout(
      title = '',
      xaxis = list(title = '',
                   autorange = ifelse(input$Test %in% test_chrono(), 'reversed', '')),
      yaxis = list(title = ''),
      margin = list(l = 65)
    ) %>% config(displayModeBar = FALSE)
  return(p)
  })
  
  output$vuecollective <- renderPlotly(dumbell())
  
  ## 3. Page Records ----
  
  #### 3.1. Records absolus ----
  
  records <- reactive({
    data <- data[data$Sous_cat %in% input$sous_cat,]
    chrono <- data[data$Test %in% test_chrono(),]
    nonchrono <- data[data$Test %in% test_nonchrono(),]
    chrono <- aggregate(chrono$Résultat, by = list(chrono$Test), FUN = function(x){min(x, na.rm = TRUE)})
    nonchrono <- aggregate(nonchrono$Résultat, by = list(nonchrono$Test), FUN = function(x){max(x, na.rm = TRUE)})
    records <- rbind(chrono, nonchrono)
    colnames(records) <- c('Test', 'Record')
    records <- merge(records, data, by.x = c('Test', 'Record'), by.y = c('Test', 'Résultat'), all.x = TRUE)  
    records <- records %>% select(Test, Record, Joueuse, Saison, Session, Sous_cat) 
    colnames(records) <- c('Test', 'Record', 'Joueuse', 'Saison', 'Session', 'Sous-catégorie')
    return(records)
  })
  
  output$records <- renderTable(records())
  
  #### 3.2. Meilleures performances ----
  
  perf <- reactive({
    perf <- data %>% 
      filter(data$Test == input$Test2,
             data$Sous_cat %in% input$sous_cat) %>% 
      na.omit()
    if (input$Test2 %in% test_chrono()) {
      perf$Rang <- rank(perf$Résultat, ties.method = 'min')
    } else {
      perf$Rang <- rank(desc(perf$Résultat), ties.method = 'min')
    }
    perf <- perf[perf$Rang %in% 1:input$top, c('Rang', 'Joueuse', 'Résultat', 'Sous_cat', 'Saison', 'Session')]
    colnames(perf) <- c('Rang', 'Joueuse', 'Résultat', 'Sous-catégorie', 'Saison', 'Session')
    perf <- perf[order(perf$Rang),]
    return(perf)
  })
  
  output$Perf <- renderTable(perf())
  
  #### 3.3. Meilleures performeuses ----
  
  perf2 <- reactive({
    perf <- data %>% 
      filter(data$Test == input$Test2,
             data$Sous_cat %in% input$sous_cat) %>% 
      na.omit()
    if (input$Test2 %in% test_chrono()) {
      perf <- aggregate(perf$Résultat, by = list(perf$Test, perf$Joueuse), FUN = min)
      colnames(perf) <- c('Test', 'Joueuse', 'Record')
      perf$Rang <- rank(perf$Record, ties.method = 'min')
    } else {
      perf <- aggregate(perf$Résultat, by = list(perf$Test, perf$Joueuse), FUN = max)
      colnames(perf) <- c('Test', 'Joueuse', 'Record')
      perf$Rang <- rank(desc(perf$Record), ties.method = 'min')
    }
    perf <- merge(perf, data[data$Sous_cat %in% input$sous_cat,], by.x = c('Test', 'Joueuse', 'Record'), by.y = c('Test', 'Joueuse', 'Résultat'), all.x = TRUE)
    perf <- perf[perf$Rang %in% 1:input$top, c('Rang', 'Joueuse', 'Record', 'Sous_cat', 'Saison', 'Session')]
    colnames(perf) <- c('Rang', 'Joueuse', 'Résultat', 'Sous-catégorie', 'Saison', 'Session')
    perf <- perf[order(perf$Rang),]
    return(perf)
  })
  
  output$Perf2 <- renderTable(perf2())
  
  #### 3.4. Modification de la liste de sous-catégorie ----
  observe({
    if (input$cat == 1) {
      updateSelectInput(session,
                      inputId = "sous_cat",
                      selected = data$Sous_cat %>% unique() %>% na.omit())
    }
  })
  
  #### 3.5. Création du rapport ----
  output$rapport_pdf <- downloadHandler(
    filename = 'rapport.pdf', # à améliorer
    content = function(file){
      out <- render('/Users/Antoine/Documents/Olympique de Neuilly/Saison 2020-2021/U13F/Tests/Performeuses.Rmd', pdf_document())
      file.rename(out, file)
    }
  )
  
  output$rapport_records_pdf <- downloadHandler(
    filename = 'rapport.pdf', # à améliorer
    content = function(file){
      out <- render('/Users/Antoine/Documents/Olympique de Neuilly/Saison 2020-2021/U13F/Tests/Records.Rmd', pdf_document())
      file.rename(out, file)
    }
  )
}



