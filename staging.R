consumer_key <- "eofYOEKWlkufkIMh85PuXYYkm"
consumer_secret <- "LCn43w0Jsk4dbXxn6WKKJTfiwZ8pn807hy6gkM3b3FR5Otq84U"
access_token <- "807917512415440896-aoOUbyZJFyaKHPTBEtsLPI9lel6sytD"
access_secret <- "2mPrTaM39pGdh3JAM97dUYO2HHh9PQRJ9Vvwe2kMP5bsm"
options(httr_oauth_cache = TRUE)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets <- searchTwitter("#Trump", n = )
tweets <- twListToDF(tweets)

searchTwitter('fenway')

tweets_geolocated <- searchTwitter("Obamacare OR ACA OR 'Affordable Care Act' OR #ACA", n=100, lang="en", geocode='34.04993,-118.24084,50mi', since="2014-08-20")
tweets_geoolocated.df <- twListToDF(tweets_geolocated)


  users <- lookupUsers(tweets$screenName)
  usersDF <- twListToDF(users)
  usersLocation <- !is.na(usersDF$location)
  located <- geocode(usersDF$location[usersLocation])
  