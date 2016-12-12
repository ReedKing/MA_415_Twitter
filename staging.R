consumer_key <- "eofYOEKWlkufkIMh85PuXYYkm"
consumer_secret <- "LCn43w0Jsk4dbXxn6WKKJTfiwZ8pn807hy6gkM3b3FR5Otq84U"
access_token <- "807917512415440896-aoOUbyZJFyaKHPTBEtsLPI9lel6sytD"
access_secret <- "2mPrTaM39pGdh3JAM97dUYO2HHh9PQRJ9Vvwe2kMP5bsm"
options(httr_oauth_cache = TRUE)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets <- searchTwitter("#christmas", n = 15, lang = "en")
tweets <- twListToDF(tweets)

searchTwitter('fenway')

tweets_geolocated <- searchTwitter("#Trump", n=250, lang="en")
tweets_geoolocated.df <- twListToDF(tweets_geolocated)


  users <- lookupUsers(tweets$screenName)
  usersDF <- twListToDF(users)
  usersLocation <- !is.na(usersDF$location)
  located <- geocode(usersDF$location[usersLocation])
  
  
  output$wordcloud <- renderPlot(function(){
    
    words <- enc2native(tweets$text)
    words <- removeWords(words, c(stopwords("en"), "RT", "#trump"))
    words <- tolower(words)
    words <- removePunctuation(words, TRUE)
    words <- unlist(strsplit(words, " "))
    words <- removeWords(words, c(stopwords("en"), "RT", " ", ""))
    words <- sort(table(words), TRUE)
    wordcloud(names(words), words, random.color = TRUE, colors = rainbow(10), scale = c(15, 2))
    
  })
  

    
  users <- lookupUsers(tweets$screenName)
  usersDF <- twListToDF(users)
  usersDF <- usersDF[!(is.na(usersDF$location) | usersDF$location == ""), ]
  locations <- geocode(usersDF$location)
  usersDF <- cbind(usersDF, locations)
  usersDF <- usersDF[!is.na(usersDF[, "lon"]),]
    
  
  clean_tweets <- tweets$text
  clean_tweets <- sapply(clean_tweets, function(row) iconv(row, "latin1", "ASCII", sub = ""))
  clean_tweets <- tolower(clean_tweets)
  clean_tweets <- removeWords(clean_tweets, c(stopwords("en"), "rt", "via"))
  clean_tweets <- removePunctuation(clean_tweets, TRUE)
  clean_tweets <- gsub("^\\s+|\\s+$", "", clean_tweets)
  clean_tweets <- as.character(clean_tweets)
  clean_tweets <- data.frame(clean_tweets)
  
  binary <- calculate_sentiment(clean_tweets$clean_tweets)
  category <- data.frame(calculate_total_presence_sentiment(clean_tweets$clean_tweets))
                         colnames(category) <- as.character(unlist(category[1,]))
                         category = category[-1, ]
  
  