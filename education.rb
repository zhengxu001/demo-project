require 'spira'
require "rdf/vocab"
require 'rdf/rdfxml'
require 'rdf/ntriples'
require 'rdf/nquads'
require 'rubygems'
require 'sparql'
require 'csv'

Spira.repository = RDF::Repository.new

OWL_ROOT = 'http://www.r-ontology.com#'
class PeopleInfo < Spira::Base
  type RDF::URI.new("#{OWL_ROOT}BasicInfo")
  property :village, :predicate => RDF::RDFS.label
  property :county, :predicate => RDF::URI.new("#{OWL_ROOT}location")
  property :region, :predicate => RDF::URI.new("#{OWL_ROOT}region"), type: String
end

class Migration < Spira::Base
  type RDF::URI.new("#{OWL_ROOT}Migration")
  property :people_info, :predicate => RDF::URI.new("#{OWL_ROOT}BasicInfo")
  property :PercPopIEBirth2011, :predicate => RDF::URI.new("#{OWL_ROOT}PercPopIEBirth2011")
end

class Ethnicity < Spira::Base
  type RDF::URI.new("#{OWL_ROOT}Migration")
  property :people_info, :predicate => RDF::URI.new("#{OWL_ROOT}BasicInfo")
  property :PercPopIrish2011, :predicate => RDF::URI.new("#{OWL_ROOT}PercPopIrish2011")
end


class Religion < Spira::Base
  type RDF::URI.new("#{OWL_ROOT}Migration")
  property :people_info, :predicate => RDF::URI.new("#{OWL_ROOT}BasicInfo")
  property :PercPopCatholic2011, :predicate => RDF::URI.new("#{OWL_ROOT}PercPopCatholic2011")
end


CSV.foreach("Migration-Ethnicity-Religion.csv", encoding: 'iso-8859-1:UTF-8') do |row|
  basic_info = RDF::URI.new("#{OWL_ROOT}BasicInfo#{row[0]}").as(PeopleInfo)
  basic_info.village = row[1]
  basic_info.county = row[2].upcase
  basic_info.region = row[5]
  basic_info.save!
  migration = RDF::URI.new("#{OWL_ROOT}Migration#{row[0]}").as(Migration)
  migration.PercPopIEBirth2011 = row[21]
  migration.people_info = RDF::URI.new("#{OWL_ROOT}BasicInfo#{row[0]}")
  migration.save!
  ethnicity = RDF::URI.new("#{OWL_ROOT}Ethnicity#{row[0]}").as(Ethnicity)
  ethnicity.PercPopIrish2011 = row[49]
  ethnicity.people_info = RDF::URI.new("#{OWL_ROOT}BasicInfo#{row[0]}")
  ethnicity.save!
  religion = RDF::URI.new("#{OWL_ROOT}Religion#{row[0]}").as(Religion)
  religion.PercPopCatholic2011 = row[103]
  religion.people_info = RDF::URI.new("#{OWL_ROOT}BasicInfo#{row[0]}")
  religion.save!
end

RDF::Turtle::Writer.open(
  'education.ttl',
  prefixes:  {
      rubytask: OWL_ROOT
    }
) do |writer|
  writer << Spira.repository
end