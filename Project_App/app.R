#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggmap)
library(leaflet)
library(twitteR)
library(DT)

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
                        topic, pulled a bunch of data and one thing I kept asking myself
                        was 'why the [expletive] would I use Shiny for this?'. After all, if I'm analyzing static
                        data, aren't dynamic visualizations and model parameters just window dressing? Finally, I realized
                        that the problem was with my question, not the format of the answer. So, what we have in this section
                        is a tool that passes off a search term to a reactive version of the twitteR import function. It also cleans the 
                        data but you'll have to check out the server.R for specifics"),
                      p("Choose whatever
                        topic you want to search for, you could do Trump, Obamacare or whatever, but I bet by the time you're grading this
                        I bet you'll have seen a dozen of those already. So try 'Frosted Flakes', 'Spinoza', or 'Ubuntu', it's your call really. To me, 
                        what this project ended up being about was making the jump from using tools, to making one."),
                      br(),
                      h3("Mapping"),
                      p("Placeholder")
                      ),
             tabPanel("Data Import",
                      textInput("searchkw", label = "Search For:", value = "#Trump"),
                      p("Enter your search here. This will feed to a reactive version of searchTwitter().
                        Remember, you can use 'OR' and 'from:' to query multiple terms or specific tweeters respectively"),
                      h4("LET IT SIT UNTIL THE #TRUMP TWEETS RETURN, IT WILL BREAK OTHERWISE"),
                      br(),
                      h2("5 most recent tweets"),
                      p("(if this doesn't populate your query did not return results)"),
                      tableOutput("table")),
             tabPanel("Word Cloud"),
             tabPanel("User Location Map"),
             tabPanel("Sentiment Analysis")
             ))
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
  
  twitterData <- (function(){
    tweets <- searchTwitter(input$searchkw, n = 250, lang = "en")
    twListToDF(tweets)
  })
  
  # Dynamic Table of Query
  
  output$table <- renderTable({
    head(twitterData()[,c("text", "screenName", "retweetCount")],n=5)
  })
})

 # Associate Tweets with User Location

 twitterUserData <- (function(){
   users <- lookupUsers(twitterData$screenName)
   usersDF <- twListToDF(users)
   usersLocation <- !is.na(userDF$location)
   located <- geocode(usersDF$location[usersLocation])
 })

# Run the application 
shinyApp(ui = ui, server = server)

