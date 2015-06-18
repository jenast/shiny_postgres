require(leaflet)
require(maps)
require(shiny)
require(RPostgreSQL)

shinyServer(function(input, output, session) {
  
  
drv<-("PostgreSQL")


fields<-reactive({
    if (is.null(input$field.type))
    return(NULL)
  
  if (input$field.type=="All"){
    group.sub=""
  } else {
    group.sub<-paste("\n WHERE type = '",input$field.type,"'",sep="")
  }
    
    for(con in dbListConnections(PostgreSQL())){ dbDisconnect(con)} 
  
    conn<-dbConnect(drv,dbname="gisdata",host="ninsrv16.nina.no",user="postgjest",password="gjestpost")  
  
  
  limit<-"\n LIMIT 1001"
  
  fetch.q<-paste("SELECT name, ST_Y(ST_Transform(geom,4326)) as lat, ST_X(ST_Transform(geom,4326)) as lon 
  FROM ninjea.shiny_table"
  ,group.sub,limit,sep="")
  
  conn<-dbConnect(drv,dbname="gisdata",host="ninsrv16.nina.no",user="postgjest",password="gjestpost")
  
  res<-dbSendQuery(conn,fetch.q)
  
  post.fields<-fetch(res,-1)
  dbClearResult(res)
  
 #dbCloseConnection("conn")
  
  post.fields
  
  
  
})

  
  output$mymap<-renderLeaflet({
    if (nrow(fields())>30){
      #return(NULL)
      my.fields<-fields()[1,]
      my.fields$name<-"Too many fields! Limit your search criteria!"
      
       leaflet() %>%
       addTiles() %>%  # Add default OpenStreetMap map tiles
            addPopups(lng=my.fields$lon, lat=my.fields$lat
                 , popup=paste("Field",as.character(my.fields$name)))
                    } else
    {
      leaflet() %>%
        addTiles() %>%  # Add default OpenStreetMap map tiles
        addMarkers(lng=fields()$lon, lat=fields()$lat
                  , popup=paste("Field",as.character(fields()$name))
        )
      
    }
  
  
  
  })

observe({
  click<-input$mymap_click
  if(is.null(click))
    return()
  output$click_map_lat<-renderText(click$lat)
  output$click_map_lng<-renderText(click$lng)
  })

  
ntext <- eventReactive(input$goButton, {
  for(con in dbListConnections(PostgreSQL())){ dbDisconnect(con)} 
  
  conn<-dbConnect(drv,dbname="gisdata",host="ninsrv16.nina.no",user="postgjest",password="gjestpost")  
  
 point.sub<-paste("ST_Transform(ST_SetSRID(ST_Makepoint(",input$mymap_click$lng,",",input$mymap_click$lat,"),4326),25833)")
  name.sub<-paste(input$name)
  type.sub<-paste(input$type)
  
  insert.q<-paste("INSERT INTO ninjea.shiny_table (geom,name,type) VALUES (",point.sub,",'",name.sub,"','",type.sub,"')",sep="")
  
  conn<-dbConnect(drv,dbname="gisdata",host="ninsrv16.nina.no",user="postgjest",password="gjestpost")
  
  res<-dbSendQuery(conn,insert.q)
  
  #post.fields<-fetch(res,-1)
  #dbClearResult(res)
  insert.q
  
})


output$nText <- renderText({
  ntext()
})

  
})