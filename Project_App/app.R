#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(magrittr)
library(ggmap)
library(leaflet)
library(twitteR)
library(DT)
library(tm)
library(wordcloud)
library(stringr)
library(dplyr)
library(SnowballC)
library(RSentiment)
library(ggplot2)

ui <- shinyUI(fluidPage(
  theme = "flatly.css",
  titlePanel("Twitter and Dynamic Sentiment Analysis"),
  navbarPage(title = "Sections",
             tabPanel("Discussion",
                      h1("Brief:"),
                      p("This tab contains more detailed discussion of each of the various moving parts
                        of this project than the code commentary on their respective tabs will contain, if at
                        any point you find yourself thinking, 'What is this?', the answer is probably here."),
                      br(),
                      h3("Data Import"),
                      p("When I was working on an early iteration of this project, I had chosen a cliche political
                        topic, pulled a bunch of data, and kept asking myself
                        'why the [expletive] would I use Shiny for this?'. After all, if we're analyzing static
                        data, aren't dynamic visualizations and model parameters just window dressing? Then I realized
                        that the problem was with my question, not the format of the answer. So, what we have in this section
                        is a tool that passes off a search term to a reactive version of the twitteR import function. It also cleans the 
                        data but you'll have to check out the server.R for specifics"),
                      p("Choose what
                        topic you want to search for, you could do Trump (the default), Obamacare, or whatever, but I bet by the time you're grading this
                        you'll have seen a dozen of those. So try 'Frosted Flakes', 'Spinoza', or 'Ubuntu', it's your call really. 
                        This project ended up being about making a tool, rather than just using using them"),
                      p("On a less poetic note, the search issues a call by default for 100 tweets in english, you can scale up N if desired, but I found
                        that it took unreasonably long to do google API call that tags user locations for mapping with anything much larger. In fact, you may want to scale
                        down to < 50 while you confirm that I've made a working map tool."),
                      p("Finally, all the normal restraints on the twitter API still apply, so if you issue too many searches it will make you wait 15 minutes"),
                      br(),
                      h3("Word Cloud"),
                      p("This is a wordcloud using the creatively named wordcloud package, there's sliders for minimum word length, maximum word length, and number of words
                        . I think it's pretty self explanatory. Make sure to have imported some data from the Data Import section first, it won't work without something to
                        work on."),
                      br(),
                      h3("User Location Mapping"),
                      p("I've opted to use Leaflet for the dynamic mapping, as it feels more suited  ")
                      ),
             tabPanel("Data Import",
                      fluidRow(
                      column(4, textInput("searchkw", label = "Search For:", value = "Trump OR Putin")),
                      column(4, textInput("tweetstopull", label = "Number of Tweets:", value = 100))),
                      p("Enter your search here. This will feed to a reactive version of searchTwitter().
                        Remember, you can use 'OR' and 'from:' to query multiple terms or specific tweeters respectively"),
                      br(),
                      h2("10 most recent tweets"),
                      p("(if this doesn't populate your query did not return results)"),
                      tableOutput("table")),
             tabPanel("Word Cloud",
                      fluidRow(
                          column(4, sliderInput("minleng",
                                      "Minimum Word Length:",
                                      min = 1, max = 20, value = 2)),
                          column(4, sliderInput("maxleng",
                                      "Maximum Word Length:",
                                      min = 1, max = 20, value = 10)),
                          column(4, sliderInput("wordno",
                                      "Number of Words:",
                                      min = 1, max = 100, value = 50))),
                      plotOutput("wordcloud")),
             tabPanel("User Location Map",
                      h3("THIS LOADS SLOWLY, BE PATIENT OR SELECT A LOWER NUMBER OF TWEETS"),
                      leafletOutput("leafmap"),
                      p("This map will dynamically plot the location of each user tweeting about this topic. However, this is one aspect where the dynamic
                        nature of the project bottlenecks us, as the Google Maps API that is being used to pull lat/long data is not particularly quick")),
             tabPanel("Sentiment Analysis",
                      plotOutput("sentimentbins")
                      ),
             tabPanel("Conclusion")
             )
  )
)

server <- shinyServer(function(input, output) {
   
  # Authentication
  consumer_key <- "eofYOEKWlkufkIMh85PuXYYkm"
  consumer_secret <- "LCn43w0Jsk4dbXxn6WKKJTfiwZ8pn807hy6gkM3b3FR5Otq84U"
  access_token <- "807917512415440896-aoOUbyZJFyaKHPTBEtsLPI9lel6sytD"
  access_secret <- "2mPrTaM39pGdh3JAM97dUYO2HHh9PQRJ9Vvwe2kMP5bsm"
  options(httr_oauth_cache = TRUE)
  setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
  
  # Query Twitter
  
  twitterData <- reactive({
    tweets <- searchTwitter(input$searchkw, n = input$tweetstopull, lang = "en")
    twListToDF(tweets)
  })
  
  # Dynamic Table of Query
  
  output$table <- renderTable({
    head(twitterData()[,c("text", "screenName", "retweetCount")],n = 10)
  })

 # Word Cloud
  
 output$wordcloud <- renderPlot({
   words <- enc2native(twitterData()[,c("text")])
   words <- removeWords(words, c(stopwords("en"), "RT", "via", input$searchkw))
   words <- tolower(words)
   words <- removePunctuation(words, TRUE)
   words <- sapply(words, function(row) iconv(row, "latin1", "ASCII", sub = ""))
   words <- unlist(strsplit(words, " "))
   words <- removeWords(words, c(stopwords("en"), "rt", " ", ""))
   words <- gsub("^\\s+|\\s+$", "", words)
   words <- gsub("https", "", words)
   words <- sort(table(words), TRUE)
   wordcloud(names(words), words, random.color = TRUE, colors = rainbow(10), scale = c(input$maxleng, input$minleng), max.words = input$wordno)
})
   
 
 # Associate Tweets with User Location
 
 twitterUserData <- reactive({
   users <- lookupUsers(twitterData()[, c("screenName")])
   usersDF <- twListToDF(users)
 })
  
 locatedusers <- reactive({
    users <- lookupUsers(twitterUserData()[,c("screenName")])
    usersDF <- twListToDF(users)
    usersDF <- usersDF[!(is.na(usersDF$location) | usersDF$location == ""), ]
    locations <- geocode(usersDF$location)
    usersDF <- cbind(usersDF, locations)
    usersDF <- usersDF[!is.na(usersDF[, "lon"]),]
 })
 
 # Mapping using Leaflet
 
 mapTweets <- reactive({
   map = leaflet() %>%
     addTiles() %>%
     addMarkers(locatedusers()$lon, locatedusers()$lat, popup = locatedusers()$screenName)
 })
 
 output$leafmap <- renderLeaflet(mapTweets())
 
 
 # Sentiment Analysis
 
 cleantweets <- reactive({
  clean_tweets <- twitterData()[,c("text")]
  clean_tweets <- removeWords(clean_tweets, c(stopwords("en"), "rt", "via", input$searchkw))
  clean_tweets <- sapply(clean_tweets, function(row) iconv(row, "latin1", "ASCII", sub = ""))
  clean_tweets <- tolower(clean_tweets)
  clean_tweets <- removePunctuation(clean_tweets, TRUE)
  clean_tweets <- gsub("^\\s+|\\s+$", "", clean_tweets)
  clean_tweets <- data.frame(clean_tweets)
 })
 
sentiment_categories <- reactive({
  score <-  calculate_sentiment(cleantweets()[,c("clean_tweets")])
})


output$sentimentbins <- renderPlot({
  ggplot(sentiment_categories(), aes(sentiment)) + geom_bar()
})

})

# Run the application 
shinyApp(ui = ui, server = server)

