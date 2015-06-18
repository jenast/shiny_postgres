library(leaflet)
library(ShinyDash)
require(magrittr)
shinyUI(fluidPage( tags$head(tags$link(rel='stylesheet', type='text/css', href='styles.css')), titlePanel('Insektdatabasen - interface'),
  
  fluidRow(column(8,leafletOutput("mymap")),
      column(2,offset=0,
  selectInput('field.type', 'Display fieldtype', c("All","Apple","Control","Clover","PolliClover"),selected="Apple")
      )),
  fluidRow(column(5,offset=2,strong("Make a new point"))),
  fluidRow(column(3,offset=2,"Latitude of marked position:"),column(2,textOutput("click_map_lat"))),
  fluidRow(column(3,offset=2,"Longitude of marked position:"),column(2,textOutput("click_map_lng"))),
  fluidRow(column(3,offset=2,"Name:"),column(2,textInput("name",label=NULL,value=""))),
  fluidRow(column(3,offset=2,"Fieldtype:"),column(2,selectInput("type",label=NULL,c("Apple","Clover","Control","PolliClover"),selected=NULL))),
  fluidRow(column(3,offset=2,actionButton("goButton", "Insert new point in database!"))),
  fluidRow(column(3,offset=2,"Database dialog:"),verbatimTextOutput("nText"))
  
  ))

  