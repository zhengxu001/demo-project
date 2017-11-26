class Country
  property :label, :predicate => RDF::RDFS.label, :type => String
  property :type, predicate: RDF::RDFV.type
  property :default_geometry, predicate: RDF::URI.new("http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#defaultGeometry")

  def initialize(paramas)
  end
end

