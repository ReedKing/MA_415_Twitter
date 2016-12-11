library(shiny)
library(leaflet)
library(twitteR)

ui = fluidPage(
  theme = "flatly.css",
  titlePanel("Twitter and Geographical Sentiment Analysis"),
  navbarPage(title = "Sections",
             tabPanel("Description of Project",
                      h1("Brief:"),
                      p("This tab contains more detailed discussion of each of the various moving parts
                        of this project than the code commentary on their respective tabs will contain, if at
                        any point you find yourself thinking, \"What the hell is this?\", the answer is probably here."),
                      br(),
                      h3("Data Import and Cleaning")
             ),
             tabPanel("Data Import", 
                      fluidRow(
                      column(4, textInput("searchkw", label = "Search For:", value = "Donald Trump"),
                      column(4, textInput("lat", label = "Latitude:", value = 42.36)),
                      column(4, textInput("long", label = "Longitude:", value = -71.06))),
                      p("Here you can define your search term and location, it will work
                        on any term in any location where it can find tweets, but I've provided
                        the Latitude and Longitude of a couple major cities."),
                      br(),
                      p("cities here"))),
             tabPanel("Mapping"),
             tabPanel("Other Visual Explorations"),
             tabPanel("Sentiment Analysis")
             ))



