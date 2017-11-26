require 'spira'
require "rdf/vocab"
require 'rdf/rdfxml'
require 'rdf/ntriples'
require 'rdf/nquads'
require 'rubygems'
require 'sparql'

Spira.repository = RDF::Repository.new
OWL_ROOT = 'http://kdetask.com#'
GEOSPARQL = 'http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#'
class County < Spira::Base
  property :label, :predicate => RDF::RDFS.label
  property :geometry, :predicate => RDF::URI.new("#{GEOSPARQL}geometry")
end
Spira.repository << [RDF::URI.new("#{OWL_ROOT}County"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{OWL_ROOT}County"), RDF::RDFS.subClassOf, RDF::OWL.Thing]
# Spira.repository << [RDF::URI.new("#{OWL_ROOT}geometry"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
# Spira.repository << [RDF::URI("#{GEOSPARQL}geometry"), RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}County")]
Spira.repository << [RDF::RDFS.label, RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::RDFS.label, RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}County")]
Spira.repository << [RDF::URI.new("#{GEOSPARQL}geometry"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{GEOSPARQL}geometry"), RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}County")]

graph = RDF::Repository.load("http://data.geohive.ie/dumps/county/default.ttl", format: :ttl)

solutions = SPARQL.execute("SELECT ?county ?label ?polygon
  WHERE { ?county a <http://ontologies.geohive.ie/osi#County> .
          ?county <http://www.w3.org/2000/01/rdf-schema#label> ?label .
          ?county <http://www.opengis.net/ont/geosparql#hasGeometry> ?geometry .
          ?geometry <http://www.opengis.net/ont/geosparql#asWKT> ?polygon.
          FILTER langMatches( lang(?label), 'en' )
          }", graph)
# solutions = SPARQL.execute("SELECT ?county ?label
#   WHERE { ?county a <http://ontologies.geohive.ie/osi#County> . }", graph)

solutions.each do |solution|
  county = RDF::URI.new("#{solution.county}").as(County)
  county.label = solution.label
  county.geometry = solution.polygon
  county.save!
end
# solution = solutions.first
#   county = RDF::URI.new("#{solution.county}").as(County)
#   county.label = solution.label
#   county.geometry = solution.polygon
#   county.save!



RDF::Turtle::Writer.open(
  'conty.ttl',
  prefixes:  {
      rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
      geohive: "http://data.geohive.ie/resource/county/",
      foaf:  "http://xmlns.com/foaf/0.1/",
      kde:  "http://kdetask.com#",
      owl: "http://www.w3.org/2002/07/owl#",
      rubytask: "http://rubytask.org#",
      geosparql: GEOSPARQL
    }
) do |writer|
  writer << Spira.repository
end

# # class Person < Spira::Base

#   configure :base_uri => "http://example.org/example/people"

#   property :name, :predicate => RDF::Vocab::FOAF.name, :type => String
#   property :age,  :predicate => RDF::Vocab::FOAF.age,  :type => Integer

# end

# Spira.repository = RDF::Repository.new

# bob = RDF::URI("http://example.org/people/bob").as(Person)
# bob.age  = 15
# bob.name = "Bob Smith"
# bob.save!

# bob.each_statement {|s| puts s}

# repo = "http://datagraph.org/jhacker/foaf.nt"
# Spira.repository = RDF::Repository.new
# Spira.repository = 


# queryable = RDF::Repository.new << RDF::Statement.new(:hello, RDF::RDFS.label, "Hello, world!", graph_name: RDF::URI("http://datagraph.org/jhacker/foaf.nt"))
# queryable = RDF::Repository.new do |graph|
#   graph << DF::Graph.load("http://data.geohive.ie/dumps/boundaries-links.ttl", format: :ttl)
# end
# queryable = RDF::Repository.load("http://data.geohive.ie/dumps/boundaries-links.ttl", format: :ttl)
# Spira.repository = RDF::Repository.load("http://data.geohive.ie/dumps/boundaries-links.ttl")

# Spira.repository << [Ruta::Class.member, RDF::RDFS.subClassOf, RDF::FOAF.Member]
# Spira.repository << [Ruta::Class.memberinrole, RDF::RDFS.subClassOf, RDF::FOAF.Agent]
# Spira.repository << [Ruta::Class.project, RDF::RDFS.subClassOf, RDF::FOAF.Group]
# Spira.repository << [Ruta::Class.task, RDF::RDFS.subClassOf, RDF::OWL.Thing]
# Spira.repository << [Ruta::Class.taskstep, RDF::RDFS.subClassOf, RDF::OWL.Thing]
# Spira.repository << [Ruta::Class.role, RDF::RDFS.subClassOf, RDF::OWL.Thing]
# Spira.repository << [Ruta::Class.right, RDF::RDFS.subClassOf, RDF::OWL.Thing]
# Spira.repository << [Ruta::Class.milestone, RDF::RDFS.subClassOf, RDF::OWL.Thing]
# sse = SPARQL.parse(%(
#   PREFIX doap: <http://usefulinc.com/ns/doap#>
#   INSERT DATA { <http://rubygems.org/gems/sparql> doap:implements <http://www.w3.org/TR/sparql11-update/>}
# ), update: true)

# sse.execute(Spira.repository)
# foaf = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
# class Person < Spira::Base
#   # include Spira::Resource
#   type RDF::URI("http://rubytask.org#Person")
#   configure :default_vocabulary => RDF::URI.new('http://example.org/vocab'),
#             :base_uri => 'http://example.org/songs'
#   type RDF::URI.new('http://example.org/types/album')
#   property :name,  predicate: RDF::URI.new("http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#geometry"), type => String
#   property :title
# end
# Spira.repository << [RDF::URI("http://datagraph.org/jhacker/#People"), RDF::RDFS.subClassOf, RDF::Vocab::FOAF.Group]
# # Spira.repository << ['People', RDF::RDFS.subClassOf, '<http://www.w3.org/2002/07/owl#Class>']

# jhacker = RDF::URI("http://datagraph.org/jhacker/#self").as(Person)

# jhacker.name = 'Xu Zheng'
# jhacker.title = 'Manager'
# # p jhacker
# jhacker.save!

# class Rose < Person
#   configure :default_vocabulary => RDF::URI.new('http://example.org/vocab')
#   property :name,  :type => String
# end

# rose = RDF::URI("http://datagraph.org/rose/#self").as(Rose)
# rose.name = 'Xu Zheng'
# rose.save!

# Spira.repository.each_statement do |statement|
#   p statement
# end
# RDF::Turtle::Writer.open("test.ttl") do |writer|
#    writer << Spira.repository
# end

# RDF::Turtle::Writer.open(
# 	'test.ttl',
# 	base_uri:  "http://example.com/", 
# 	prefixes:  {
# 		  rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
#     	nil => "http://example.com/ns#",
#     	foaf:  "http://xmlns.com/foaf/0.1/",
#       owl: "http://www.w3.org/2002/07/owl#",
#       rubytask: "http://rubytask.org#"
#     }
# ) do |writer|
#   writer << Spira.repository
#   p writer.graph
# end


# p jhacker.name
# p Person.types
# Spira.repository << jhacker
# solutions = SPARQL.execute("SELECT * WHERE { ?s ?p ?o }", Spira.repository)
# p solutions.to_xml
# # Spira.repository = RDF::Repository.new
# Spira.repository = RDF::Repository.load('http://datagraph.org/jhacker/foaf.nt')
# sse = SPARQL.parse(%(
#   PREFIX doap: <http://usefulinc.com/ns/doap#>
#   INSERT DATA { <http://rubygems.org/gems/sparql> doap:implements <http://www.w3.org/TR/sparql11-update/>}
# ), update: true)
# sse.execute(Spira.repository)
# queryable = RDF::Repository.load("http://data.geohive.ie/dumps/boundaries-links.ttl", format: :ttl)
# queryable = RDF::Repository.load("etc/doap.ttl")

# sse = SPARQL.parse(%(
#   PREFIX doap: <http://usefulinc.com/ns/doap#>
#   INSERT DATA { <http://rubygems.org/gems/sparql> doap:implements <http://www.w3.org/TR/sparql11-update/>}
# ), update: true)

# solutions = SPARQL.execute("SELECT * WHERE { ?s ?p ?o }", queryable)
# solutions.to_json #to_xml #to_csv #to_tsv #to_html

# solutions = SPARQL.execute("SELECT * WHERE { ?s ?p ?o }", Spira.repository)
# p solutions #to_xml #to_csv #to_tsv #to_html

# sse = SPARQL.parse("SELECT * WHERE { <http://datagraph.org/jhacker/foaf> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?City }")
# Spira.add_repository(:default, RDF::Repository.load(repo))
# Spira.repository = RDF::Repository.new
# repo = "http://datagraph.org/jhacker/foaf.nt"
# Spira.add_repository(:default, RDF::Repository.load(repo))
# graph = RDF::Graph.load("http://data.geohive.ie/dumps/boundaries-links.ttl", format: :ttl)
# sse = SPARQL.parse("SELECT * WHERE {?a ?b ?c}")
# sse = SPARQL.parse("SELECT * WHERE { <http://data.geohive.ie/resource/county_council/2AE19629148D13A3E055000000000001> <http://open.vocab.org/terms/similarTo> ?City }")
# Spira.repository.query(sse) do |result|
#   p result.inspect
# end
# Sparql.select.where( [uri, RDF.type, Ruta::Class[cl.to_s.downcase]]
# class Person < Spira::Base
#   property :name,  :predicate => RDF::Vocab::FOAF.name
#   property :nick,  :predicate => RDF::Vocab::FOAF.nick
# end
# jhacker = Person.new
# jhacker.name #=> "J. Random Hacker"
# # jhacker.name = "Some Other Hacker"
# jhacker.save!

# p Person.all
# p Spira.repository


# graph = RDF::Graph.new << [:hello, RDF::RDFS.label, "Hello, world!"]
# graph.to_ttl


# Spira.repository = RDF::Repository.load('http://datagraph.org/jhacker/foaf.nt')
# class Person < Spira::Base
#   # include Spira::Resource

#   property :name,  :predicate => RDF::Vocab::FOAF.name
#   property :nick,  :predicate => RDF::Vocab::FOAF.nick
# end

# jhacker = RDF::URI("http://datagraph.org/jhacker/#self").as(Person)
# jhacker.name #=> "J. Random Hacker"
# jhacker.nick #=> "jhacker"
# jhacker.name = "Some Other Hacker"
# jhacker.save!
# p jhacker
# p Spira.repository