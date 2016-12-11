library(shiny)
library(leaflet)
library(twitteR)
library(DT)

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
                      column(6, textInput("searchkw", label = "Search For:", value = "trump")),
                      column(4, textInput("lat", label = "Latitude:", value = 40.71)),
                      column(4, textInput("long", label = "Longitude:", value = -74)),
                      column(12, tableOutput("tweettable"))),
                      p("Here you can define your search term and location, it will work
                        on any term in any location where it can find tweets, but I've provided
                        the Latitude and Longitude of a couple major cities."),
                      h3("Cities:"),
                      p("New York = 40.71, -74"),
                      p("Chicago = 41.87, -87.63"),
                      p("LA = 34.05, -118.24"),
                      p("Boston = 42.36, -71.05"),
                      br(),
                      p("Additionally, feeding multiple terms seperated by OR should also work, as
                        this is simply a string fed to searchTwitter")),
             tabPanel("Mapping"),
             tabPanel("Other Visual Explorations"),
             tabPanel("Sentiment Analysis")
             )
)



