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
  titlePanel("Dynamic Twitter Queries and Analysis With Shiny"),
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
                      p("On a less poetic note, the search issues a call by default for 100 tweets (retweets will be stripped) in english, you can scale up N if desired, but I found
                        that it took unreasonably long to do google API call that tags user locations for mapping with anything much larger. In fact, you may want to scale
                        down to < 50 while you confirm that I've made a working map tool."),
                      p("Finally, all the normal restraints on the twitter API still apply, so if you issue too many searches it will make you wait 15 minutes"),
                      br(),
                      h3("Word Cloud"),
                      p("This is a wordcloud using the creatively named wordcloud package, there's sliders for minimum word length, maximum word length, and number of words
                        . I think it's pretty self explanatory. Make sure to have imported some data from the Data Import section first, it won't work without something to
                        work on."),
                      p("The data cleaning process the tweets undergo before being fed in will nuke a lot of trivial stopwords, so you will need a large sample of tweets
                        to get really big wordclouds"),
                      br(),
                      h3("User Location Mapping"),
                      p("I've opted to use Leaflet for the dynamic mapping, as it is a bit prettier than ggmaps and is easier to incorporate into the Shiny interface.
                        Other than that, this section is a bit bottlenecked by the fact that in order to tag each tweet, it must send a geocode request to the Google
                        Maps API. On static data this wouldn't be a big deal, you could just run it once and store the tags, but since I don't know what is going to be
                        throwin in the search bar, it's set up to dynamically retrieve said values. This unfortuantely isn't very fast, so if you're sitting on that page
                        wondering where the map is, it's loading, but you might want to try a lower tweet value if you're rapidly cycling through different topics."),
                      br(),
                      h3("Sentiment Analysis"),
                      p("This is fairly unremarkable on the surface, but what it does is feed the query through a slightly more sophisticated clean than the word cloud,
                        and then attempt to tag each tweet on a scale of positive to negative using libraries of words found in the tm and Rsentiment packages. The scale is
                        anchored at 0, and tweets are given a positive or negative point for each word identified in the library")
                      ),
             tabPanel("Data Import",
                      fluidRow(
                      column(4, textInput("searchkw", label = "Search For:", value = "#Trump")),
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
                      plotOutput("sentimentbins"),
                      p("Simple but insightful plot showing the distribution of usage of positive and negative words on your sample of tweets. As with everything else
                        this will adjust if you change your search.")
                      ),
             tabPanel("Conclusion",
                      h3("Closing Thoughts"),
                      br(),
                      p("Wow, well I think I feel a WHOLE lot better about using Shiny now, and I think that's the main thing that I've gotten out of this project."),
                      p("Anyway, I think I'm going to try and iterate on this application, not that what I have now isn't a solid base of functionality, but coming into
                        this project what I thought I was going to do was make a decision tree in rpart to classify tweets, what I've ended up with is obviously a much
                        simpler model, as I was spending a lot of time debugging reactive class objects rather than doing fancy statistics. But now that I've got the hang
                        of that skill, I think perhaps I could revist this with some more advanced methods in the future, as well as spruce up the visualizations a bit."),
                      p("I guess I don't really have a lot of conventional statistics stuff to write about given the nature of this project, as I've traveled down the tradeoff
                        curve between broadness of application and specificity of analysis, but honestly I think that was the way to go. If I had chosen to do something flashy 
                        like the aforementioned decision tree, a tweet simulating Markov-chain, or an ARIMA model of tweet frequency, all I'd really be doing was practicing
                        application of statistics. With this, I feel like I've done an excercise that has really fundamentally improved my programming ability, rather than my statistics
                        vocabulary - and I think that's good? Maybe? (I hope?)"),
                        p("Anyway, I hope you think this is a neat tool, I'm pretty sure this isn't going to be the most sophisticated stats application you're going to see
                          but I hope it's at least one of the more novel takes on the idea of the Twitter project.")))
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
    tweets <- strip_retweets(tweets)
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
   words <- sapply(words, function(row) iconv(row, "latin1", "ASCII", sub = ""))
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
  clean_tweets <- sapply(clean_tweets, function(row) iconv(row, "latin1", "ASCII", sub = ""))
  clean_tweets <- tolower(clean_tweets)
  clean_tweets <- removeWords(clean_tweets, c(stopwords("en"), "rt", "via", input$searchkw))
  clean_tweets <- removePunctuation(clean_tweets, TRUE)
  clean_tweets <- gsub("^\\s+|\\s+$", "", clean_tweets)
  clean_tweets <- as.character(clean_tweets)
 })
 
 sentiment_bins <- reactive({
   clean <- cleantweets()
   scores <- data.frame(calculate_score(clean))
 })

output$sentimentbins <- renderPlot({
  datum <- sentiment_bins()
  ggplot(datum, aes(x = calculate_score.clean.)) +
    geom_bar() +
    labs(title = "Sentiment Score", x = "Sum of Positive and Negative Words", y = "Number of Tweets") +
    theme_bw()
})

})

# Run the application 

shinyApp(ui = ui, server = server)

