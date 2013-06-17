#Socrada

Socrada's aim is to enable a user to visualize their social connections and then strategize their networking based on this information. Challenging aspects overcome in this project included the substitution of a traditional ActiveRecord based relational database to using a node based graph database called Neo4j. As well as this I learned about Cypher the query language for Neo4j, implemented the VivaGraph JS graphing library to visualize the node relationships and constructed trenched background workers that mitigate Twitter rate limiting issues. This project was created as apart of an individual gSchool project. Max DeMarzi the creator of the Neography Ruby gem was nice enough to collaborate with me and teach me a thing or two about Neo4j so many thanks to him.

###What to look for
* Neo4j implementation
* VivaGraph JS Visualisation
* Tranched Background Workers

****

####The live hosted heroku app can be found at
* http://socrada2.herokuapp.com
* To login use your twitter login details
  * As twitter has some rate limiting issues to deal with, upon login, it may take a few moments for the background workers to fire off and retrieve your Twitter "follower" nodes
  * If you have many followers the graph may become quite condensed, I have yet to imlement some limitations on the node queries - this is an ongoing project and hopefully over the next few weeks I can implement some more node filtering and structured node traversals to show the shortest path to a target Twitter member within the network

****

###Getting started locally with Socrada
* In order to run Socrada locally you will have to install Neo4j and run the Neo4j server instance
* Redis is also required
* As is a Twitter developer application, from which you can access your
  * Twitter consumer access key &
  * Twitter consumer secret key
* These steps will help you get started
  * Install Neo4j
    * rake neo4j:install
  * Start the Neo4j server
    * rake neo4j:start
    * visit http://localhost:7474/webadmin/ to see the Neo4j admin interface
      * There are issues with viewing this interface in Chrome so you may have to use Firefox :)
  * Create Neo4j database
    * rake neo4j:create
  * Install Redis
    * brew install redis
  * Start the Redis server
    * redis-server
  * Set your Twitter Keys (if you have any problems with this I suggest using Figaro - https://github.com/laserlemon/figaro)
    * export CONSUMER_KEY="your twitter consumer key"
    * export CONSUMER_SECRET="your twitter consumer secret"
  * Bundle the gems
    * bundle install
  * Run the server & visit the page
    * foreman start
    * http://localhost:5100

****

###Deploying to Heroku
  * Create a heroku app from the command line
    * heroku create socrada
  * Add the neo4j addon
    * heroku addons:add neo4j
  * Add the Redis-to-go addon
    * heroku addons:add redistogo
  * Set your Twitter keys in the Heroku config
    * heroku config:add CONSUMER_KEY="your twitter consumer key"
    * heroku config:add CONSUMER_SECRET="your twitter consumer secret"
  * Deploy the app to Heroku
    * git push heroku master
  * Scale up your workers so that the background processes can run in order to fetch the user Twitter data
    * heroku ps:scale worker=1
  * Create the Neo4j database
    * heroku run rake neo4j:create