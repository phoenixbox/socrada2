namespace :neo4j do
  task :create do
    neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
    neo.create_node_index("users", "fulltext")
    neo.create_node_index("follows", "exact")
  end
end