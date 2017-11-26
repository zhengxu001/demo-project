OWL_ROOT = 'http://kdetask.com#'
GEOSPARQL = 'http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#'
class County < Spira::Base
  type RDF::URI.new("#{OWL_ROOT}County")
  property :label, :predicate => RDF::RDFS.label
  property :geometry, :predicate => RDF::URI.new("#{GEOSPARQL}geometry")
end
REPO << [RDF::URI.new("#{OWL_ROOT}County"), RDF::RDFV.type, RDF::OWL.Class]
REPO << [RDF::URI.new("#{OWL_ROOT}County"), RDF::RDFS.subClassOf, RDF::OWL.Thing]
REPO << [RDF::RDFS.label, RDF::RDFV.type, RDF::OWL.DatatypeProperty]
REPO << [RDF::RDFS.label, RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}County")]
REPO << [RDF::URI.new("#{GEOSPARQL}geometry"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
REPO << [RDF::URI.new("#{GEOSPARQL}geometry"), RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}County")]

graph = RDF::Repository.load("http://data.geohive.ie/dumps/county/default.ttl", format: :ttl)

solutions = SPARQL.execute("SELECT ?county ?label ?polygon
  WHERE { ?county a <http://ontologies.geohive.ie/osi#County> .
          ?county <http://www.w3.org/2000/01/rdf-schema#label> ?label .
          ?county <http://www.opengis.net/ont/geosparql#hasGeometry> ?geometry .
          ?geometry <http://www.opengis.net/ont/geosparql#asWKT> ?polygon.
          FILTER langMatches( lang(?label), 'en' )
          }", graph)

solutions.each do |solution|
  county = RDF::URI.new("#{solution.county}").as(County)
  county.label = solution.label
  county.geometry = solution.polygon
  county.save!
end

