class School < Spira::Base
  type RDF::URI.new("#{OWL_ROOT}School")
  property :label, :predicate => RDF::RDFS.label, type: String
  property :location, :predicate => RDF::URI.new("#{OWL_ROOT}location"), type: String
  property :male, :predicate => RDF::URI.new("#{OWL_ROOT}male"), type: Integer
  property :female, :predicate => RDF::URI.new("#{OWL_ROOT}female"), type: Integer
end

school_comment = 'A school is an institution designed to provide learning spaces and learning environments for the teaching of students (or "pupils") under the direction of teachers'
REPO << [RDF::URI.new("#{OWL_ROOT}School"), RDF::RDFV.type, RDF::OWL.Class]
REPO << [RDF::URI.new("#{OWL_ROOT}School"), RDF::RDFS.subClassOf, RDF::OWL.Thing]
REPO << [RDF::URI.new("#{OWL_ROOT}School"), RDF::RDFS.comment, school_comment]
REPO << [RDF::RDFS.label, RDF::RDFV.type, RDF::OWL.DatatypeProperty]
REPO << [RDF::RDFS.label, RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}School")]
REPO << [RDF::URI.new("#{OWL_ROOT}location"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
REPO << [RDF::URI.new("#{OWL_ROOT}location"), RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}School")]
REPO << [RDF::URI.new("#{OWL_ROOT}male"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
REPO << [RDF::URI.new("#{OWL_ROOT}male"), RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}School")]
REPO << [RDF::URI.new("#{OWL_ROOT}female"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
REPO << [RDF::URI.new("#{OWL_ROOT}female"), RDF::RDFS.domain, RDF::URI("#{OWL_ROOT}School")]

CSV.foreach("#{Rails.root}/config/initializers/school.csv") do |row|
  county = RDF::URI.new("#{OWL_ROOT}#{row[0]}").as(School)
  county.label     = row[2]
  county.male      = row[8]
  county.female    = row[9]
  county.location  = row[3].upcase
  county.save!
end
