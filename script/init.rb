require 'spira'
require "rdf/vocab"
require 'rdf/rdfxml'
require 'rdf/ntriples'
require 'rdf/nquads'
require 'rubygems'
require 'sparql'
require 'csv'

# REPO
Spira.repository = RDF::Repository.new

# PREFIX
RONTO = 'http://r-ontology.com/'
GEOSPARQL = 'http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#'
QGS84_POS = "http://www.w3.org/2003/01/geo/wgs84_pos#"
OPVO = 'http://open.vocab.org/terms/'

# OWL Description
Spira.repository << [RDF::URI.new("#{RONTO}r-ontology.owl"), RDF::RDFV.type, RDF::OWL.Ontology]
Spira.repository << [RDF::URI.new("#{RONTO}r-ontology.owl"), RDF::OWL.versionInfo, 'Demo for Trinity KDE Class']


# Geohive Class
class Geohive < Spira::Base
  type RDF::URI.new("#{RONTO}Geohive")
  property :label, :predicate => RDF::RDFS.label, type: String
  property :similar_to, :predicate => RDF::URI.new("#{OPVO}similarTo")
  property :geometry, :predicate => RDF::URI.new("#{GEOSPARQL}defaultGeometry"), type: String
end

county_graph = RDF::Repository.load("http://data.geohive.ie/dumps/county/default.ttl", format: :ttl)
wiki_graph = RDF::Repository.load("datasets/boundaries-links.ttl", format: :ttl)
solutions = SPARQL.execute("SELECT ?county ?label ?polygon
  WHERE { ?county a <http://ontologies.geohive.ie/osi#County> .
          ?county <http://www.w3.org/2000/01/rdf-schema#label> ?label .
          ?county <http://www.opengis.net/ont/geosparql#hasGeometry> ?geometry .
          ?geometry <http://www.opengis.net/ont/geosparql#asWKT> ?polygon.
          FILTER langMatches( lang(?label), 'en' )
          }", county_graph)
solutions.each do |solution|
  a = RDF::URI.new("#{solution.county}")
  similar = SPARQL.execute("PREFIX OPVO: <http://open.vocab.org/terms/> SELECT  ?wiki WHERE { <#{a}> OPVO:similarTo ?wiki}", wiki_graph)
  county = RDF::URI.new("#{solution.county}").as(Geohive)
  county.label = solution.label.to_s
  similar.each do |similar_wiki|
    county.similar_to = similar_wiki.wiki
  end
  county.geometry = solution.polygon
  county.save!
end

#Scoordinate Class
class Scoordinate < Spira::Base
  type RDF::URI.new("#{RONTO}Scoordinate")
  property :inCounty, :predicate => RDF::URI.new("#{GEOSPARQL}ehInside")
  property :belongsTo, :predicate => RDF::URI.new("#{RONTO}belongsTo")
  property :long, :predicate => RDF::URI.new("#{QGS84_POS}long")
  property :lat, :predicate => RDF::URI.new("#{QGS84_POS}lat")
end

#School Class
class School < Spira::Base
  type RDF::URI.new("#{RONTO}School")
  property :label, :predicate => RDF::RDFS.label
  property :hasScoordinate, :predicate => RDF::URI.new("#{RONTO}hasScoordinate")
  property :male, :predicate => RDF::URI.new("#{RONTO}maleNum")
  property :female, :predicate => RDF::URI.new("#{RONTO}femaleNum")
end

CSV.foreach("datasets/school.csv", encoding: 'iso-8859-1:UTF-8') do |row|
  school = RDF::URI.new("#{RONTO}School#{row[0]}").as(School)
  s_location = RDF::URI.new("#{RONTO}Scoordinate#{row[0]}").as(Scoordinate)
  school.label     = row[1]
  school.male      = row[3].to_i
  school.female    = row[4].to_i
  school.hasScoordinate  = s_location.subject
  county = SPARQL.execute("PREFIX ronto: <http://r-ontology.com/> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> SELECT ?county WHERE { ?county rdfs:label \"#{row[1].upcase}\" . ?county a ronto:Geohive . }", Spira.repository)
  county.each do |c|
    s_location.inCounty = c.county
  end
  s_location.belongsTo = school.subject
  s_location.long = row[5].to_i
  s_location.lat  = row[6].to_i
  school.save!
  s_location.save!
end

# Area Class
class Area < Spira::Base
  type RDF::URI.new("#{RONTO}Area")
  property :village, :predicate => RDF::RDFS.label
  property :region,  :predicate => RDF::URI.new("#{RONTO}region"), type: String
  property :inCounty, :predicate => RDF::URI.new("#{GEOSPARQL}ehInside")
end

# Migration Class
class Migration < Spira::Base
  type RDF::URI.new("#{RONTO}Migration")
  property :forArea, :predicate => RDF::URI.new("#{RONTO}forArea")
  property :PercPopIEBirth2011, :predicate => RDF::URI.new("#{RONTO}PercPopIEBirth2011")
  property :PopIEBirth2011, :predicate => RDF::URI.new("#{RONTO}PopIEBirth2011")
end

# Ethnicity Class
class Ethnicity < Spira::Base
  type RDF::URI.new("#{RONTO}Ethnicity")
  property :forArea, :predicate => RDF::URI.new("#{RONTO}forArea")
  property :PercPopIrish2011, :predicate => RDF::URI.new("#{RONTO}PercPopIrish2011")
  property :PercPopPolish2011, :predicate => RDF::URI.new("#{RONTO}PercPopPolish2011")
end

# Religion Class
class Religion < Spira::Base
  type RDF::URI.new("#{RONTO}Religion")
  property :forArea, :predicate => RDF::URI.new("#{RONTO}forArea")
  property :PercPopCatholic2011, :predicate => RDF::URI.new("#{RONTO}PercPopCatholic2011")
end

# Language Class
class Language < Spira::Base
  type RDF::URI.new("#{RONTO}Language")
  property :forArea, :predicate => RDF::URI.new("#{RONTO}forArea")
  property :PercNonEnSpeakers2011, :predicate => RDF::URI.new("#{RONTO}PercNonEnSpeakers2011")
end

# Education
class Education < Spira::Base
  type RDF::URI.new("#{RONTO}Education")
  property :forArea, :predicate => RDF::URI.new("#{RONTO}forArea")
  property :PercPostGrad2011, :predicate => RDF::URI.new("#{RONTO}PercPostGrad2011")
  property :PercHighLvlDeg2011, :predicate => RDF::URI.new("#{RONTO}PercHighLvlDeg2011")
  property :PopStudiedArt2011, :predicate => RDF::URI.new("#{RONTO}PopStudiedArt2011")
  property :PercPopStudiedHum2011, :predicate => RDF::URI.new("#{RONTO}PercPopStudiedHum2011")
end

county_match = {
  "Dublin City" => "Dublin",
  "South Dublin" => "Dublin",
  "Cork City" => "Cork",
  "Cork County" => "Cork",
  "Limerick City" => "Limerick",
  "Waterford City" => "Waterford",
  "Galway County" => "Galway"
}
CSV.foreach("datasets/education.csv", encoding: 'iso-8859-1:UTF-8') do |row|
  area = RDF::URI.new("#{RONTO}Area#{row[0]}").as(Area)
  area.village = row[1]
  county_name = county_match[row[2]] || row[2]
  county_name = county_name.upcase
  area.region  = row[3]
  query = "PREFIX ronto: <http://r-ontology.com/> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> select ?a where { ?a rdfs:label \"#{county_name}\" .  ?a a ronto:Geohive . }"
  solutions = SPARQL.execute(query, Spira.repository)
  solutions.each do |solution|
    area.inCounty = solution.a
  end
  area.save!
  migration = RDF::URI.new("#{RONTO}Migration#{row[0]}").as(Migration)
  migration.PopIEBirth2011 = row[8].to_i
  migration.PercPopIEBirth2011 = row[9].to_i
  migration.forArea = area.subject
  migration.save!
  ethnicity = RDF::URI.new("#{RONTO}Ethnicity#{row[0]}").as(Ethnicity)
  ethnicity.PercPopIrish2011 = row[10].to_i
  ethnicity.PercPopPolish2011 = row[11].to_i
  ethnicity.forArea = area.subject
  ethnicity.save!
  religion = RDF::URI.new("#{RONTO}Religion#{row[0]}").as(Religion)
  religion.PercPopCatholic2011 = row[12].to_i
  religion.forArea = area.subject
  religion.save!
  language = RDF::URI.new("#{RONTO}Language#{row[0]}").as(Language)
  language.PercNonEnSpeakers2011 = row[13].to_i
  language.forArea = area.subject
  language.save!
  education = RDF::URI.new("#{RONTO}Education#{row[0]}").as(Education)
  education.PercPostGrad2011 = row[7].to_i
  education.PercHighLvlDeg2011 = row[6].to_i
  education.PopStudiedArt2011 = row[4].to_i
  education.PercPopStudiedHum2011 = row[5].to_i
  education.forArea = area.subject
  education.save!
end


# Annotations
county_comment = "A county is a geographical region of a country used for administrative"
Spira.repository << [RDF::URI.new("#{RONTO}Geohive"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}Geohive"), RDF::RDFS.subClassOf, RDF::OWL.Thing]
Spira.repository << [RDF::URI.new("#{RONTO}Geohive"), RDF::RDFS.comment, county_comment]
Spira.repository << [RDF::URI.new("#{GEOSPARQL}defaultGeometry"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{GEOSPARQL}defaultGeometry"), RDF::RDFS.domain, RDF::URI("#{RONTO}Geohive")]
Spira.repository << [RDF::URI.new("#{GEOSPARQL}defaultGeometry"), RDF::RDFS.range, RDF::XSD.String]
Spira.repository << [RDF::URI.new("#{OPVO}similarTo"), RDF::RDFV.type, RDF::OWL.ObjectProperty]
Spira.repository << [RDF::URI.new("#{OPVO}similarTo"), RDF::RDFV.type, RDF::OWL.SymmetricProperty]

scoordinate_comment = 'Scoordinate enables every location on Earth to be specified by a set of numbers with coordinates latitude and longitude. Besides, Scoordinate also contains the county information'
Spira.repository << [RDF::URI.new("#{RONTO}Scoordinate"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}Scoordinate"), RDF::RDFS.subClassOf, RDF::OWL.Thing]
Spira.repository << [RDF::URI.new("#{RONTO}Scoordinate"), RDF::RDFS.comment, scoordinate_comment]
Spira.repository << [RDF::URI.new("#{RONTO}belongsTo"), RDF::OWL.inverseOf, RDF::URI.new("#{RONTO}hasScoordinate")]
Spira.repository << [RDF::URI.new("#{GEOSPARQL}ehInside"), RDF::RDFV.type, RDF::OWL.ObjectProperty]
Spira.repository << [RDF::URI.new("#{GEOSPARQL}ehInside"), RDF::RDFV.type, RDF::OWL.TransitiveProperty]
Spira.repository << [RDF::URI.new("#{GEOSPARQL}ehInside"), RDF::RDFS.domain, RDF::URI("#{RONTO}Scoordinate")]
Spira.repository << [RDF::URI.new("#{RONTO}belongsTo"), RDF::RDFS.domain, RDF::URI("#{RONTO}Scoordinate")]
Spira.repository << [RDF::URI.new("#{RONTO}belongsTo"), RDF::RDFV.type, RDF::OWL.ObjectProperty]
Spira.repository << [RDF::URI.new("#{RONTO}belongsTo"), RDF::RDFV.type, RDF::OWL.TransitiveProperty]
Spira.repository << [RDF::URI.new("#{RONTO}belongsTo"), RDF::RDFS.range, RDF::URI.new("#{RONTO}School")]
Spira.repository << [RDF::URI.new("#{RONTO}belongsTo"), RDF::RDFS.comment, 'The belongsTo property shows the owner of this instance']
Spira.repository << [RDF::URI.new("#{QGS84_POS}long"), RDF::RDFS.domain, RDF::URI("#{RONTO}Scoordinate")]
Spira.repository << [RDF::URI.new("#{QGS84_POS}long"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{QGS84_POS}long"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{QGS84_POS}long"), RDF::RDFS.label, 'longitude']
Spira.repository << [RDF::URI.new("#{QGS84_POS}long"), RDF::RDFS.comment, 'The WGS84 longitude of a SpatialThing (decimal degrees).']
Spira.repository << [RDF::URI.new("#{QGS84_POS}lat"), RDF::RDFS.domain, RDF::URI("#{RONTO}Scoordinate")]
Spira.repository << [RDF::URI.new("#{QGS84_POS}lat"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{QGS84_POS}lat"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{QGS84_POS}lat"), RDF::RDFS.label, 'latitude']
Spira.repository << [RDF::URI.new("#{QGS84_POS}lat"), RDF::RDFS.comment, 'The WGS84 latitude of a SpatialThing (decimal degrees).']

school_comment = 'The school class contains the male number, female number and the location information in Ireland from 2013-2014'
Spira.repository << [RDF::URI.new("#{RONTO}School"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}School"), RDF::RDFS.subClassOf, RDF::OWL.Thing]
Spira.repository << [RDF::URI.new("#{RONTO}School"), RDF::RDFS.comment, school_comment]
Spira.repository << [RDF::URI.new("#{RONTO}maleNum"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}maleNum"), RDF::RDFS.domain, RDF::URI("#{RONTO}School")]
Spira.repository << [RDF::URI.new("#{RONTO}maleNum"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}maleNum"), RDF::RDFS.label, 'maleNumber']
Spira.repository << [RDF::URI.new("#{RONTO}femaleNum"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}femaleNum"), RDF::RDFS.domain, RDF::URI("#{RONTO}School")]
Spira.repository << [RDF::URI.new("#{RONTO}femaleNum"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}femaleNum"), RDF::RDFS.label, 'femaleNumber']
Spira.repository << [RDF::URI.new("#{RONTO}hasScoordinate"), RDF::RDFS.range, RDF::URI.new("#{RONTO}Scoordinate")]
Spira.repository << [RDF::URI.new("#{RONTO}hasScoordinate"), RDF::RDFS.domain, RDF::URI("#{RONTO}School")]
Spira.repository << [RDF::URI.new("#{RONTO}hasScoordinate"), RDF::RDFV.type, RDF::OWL.ObjectProperty]
Spira.repository << [RDF::URI.new("#{RONTO}hasScoordinate"), RDF::RDFS.label, 'schoolCoordinates']

area_comment = 'Area class contains village name and its county and planing region information, and it is the subclass of geohive, so it also contains the coordinates information of its county'
Spira.repository << [RDF::URI.new("#{RONTO}Area"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}Area"), RDF::RDFS.comment, area_comment]
Spira.repository << [RDF::URI.new("#{RONTO}region"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}region"), RDF::RDFS.domain, RDF::URI("#{RONTO}Area")]
Spira.repository << [RDF::URI.new("#{RONTO}region"), RDF::RDFS.range, RDF::XSD.String]
Spira.repository << [RDF::URI.new("#{RONTO}region"), RDF::RDFS.label, 'areaRegion']

migration_comment = "Migration class shows information about the birthplace of the people in Ireland."
Spira.repository << [RDF::URI.new("#{RONTO}Migration"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}Migration"), RDF::RDFS.comment, migration_comment]
Spira.repository << [RDF::URI.new("#{RONTO}forArea"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}forArea"), RDF::RDFS.range, RDF::URI.new("#{RONTO}Area")]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopIEBirth2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopIEBirth2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Migration")]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopIEBirth2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopIEBirth2011"), RDF::RDFS.label, "Perc_Pop_By_Place_Of_Birth_Ireland_2011"]
Spira.repository << [RDF::URI.new("#{RONTO}PopIEBirth2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PopIEBirth2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Migration")]
Spira.repository << [RDF::URI.new("#{RONTO}PopIEBirth2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PopIEBirth2011"), RDF::RDFS.label, "Pop_By_Place_Of_Birth_Ireland_2011"]

ethnicity_comment = "Ethnicity class contains information about the ethnicity of the people in Ireland."
Spira.repository << [RDF::URI.new("#{RONTO}Ethnicity"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}Ethnicity"), RDF::RDFS.comment, ethnicity_comment]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopIrish2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopIrish2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Ethnicity")]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopIrish2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopIrish2011"), RDF::RDFS.label, "Perc_Pop_By_Nationality_Ireland_2011"]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopPolish2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopPolish2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Migration")]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopPolish2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopPolish2011"), RDF::RDFS.label, "Perc_Pop_By_Nationality_Poland_2011"]

religion_comment = "Religion class contains information about the religion and belief of the people in Ireland."
Spira.repository << [RDF::URI.new("#{RONTO}Religion"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}Religion"), RDF::RDFS.comment, ethnicity_comment]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopCatholic2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopCatholic2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Religion")]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopCatholic2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopCatholic2011"), RDF::RDFS.label, "Perc_Pop_By_Religion_Catholic_2011"]

language_comment = "This class contains information about the languages that people speak in Ireland."
Spira.repository << [RDF::URI.new("#{RONTO}Language"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}Language"), RDF::RDFS.comment, language_comment]
Spira.repository << [RDF::URI.new("#{RONTO}PercNonEnSpeakers2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PercNonEnSpeakers2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Language")]
Spira.repository << [RDF::URI.new("#{RONTO}PercNonEnSpeakers2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PercNonEnSpeakers2011"), RDF::RDFS.label, "Perc_Speakers_Of_Foreign_Languages_Ability_To_Speak_English_Not_At_All_2011"]

education_comment = "Education class contains information about the educational attainment of the people in Ireland."
Spira.repository << [RDF::URI.new("#{RONTO}Education"), RDF::RDFV.type, RDF::OWL.Class]
Spira.repository << [RDF::URI.new("#{RONTO}Education"), RDF::RDFS.comment, education_comment]
Spira.repository << [RDF::URI.new("#{RONTO}PercPostGrad2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PercPostGrad2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Education")]
Spira.repository << [RDF::URI.new("#{RONTO}PercPostGrad2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PercPostGrad2011"), RDF::RDFS.label, "Perc_Persons_15_Plus_By_Highest_Level_Of_Edu_Post_Grad_Level_2011"]
Spira.repository << [RDF::URI.new("#{RONTO}PercHighLvlDeg2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PercHighLvlDeg2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Education")]
Spira.repository << [RDF::URI.new("#{RONTO}PercHighLvlDeg2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PercHighLvlDeg2011"), RDF::RDFS.label, "Perc_Persons_15_Plus_By_Highest_Level_Of_Edu_Degree_Level_2011"]
Spira.repository << [RDF::URI.new("#{RONTO}PopStudiedArt2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PopStudiedArt2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Education")]
Spira.repository << [RDF::URI.new("#{RONTO}PopStudiedArt2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PopStudiedArt2011"), RDF::RDFS.label, "Persons_Aged_15_And_Over_By_Field_Of_Study_Arts_2011"]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopStudiedHum2011"), RDF::RDFV.type, RDF::OWL.DatatypeProperty]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopStudiedHum2011"), RDF::RDFS.domain, RDF::URI("#{RONTO}Education")]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopStudiedHum2011"), RDF::RDFS.range, RDF::XSD.Float]
Spira.repository << [RDF::URI.new("#{RONTO}PercPopStudiedHum2011"), RDF::RDFS.label, "Perc_Persons_Aged_15_And_Over_By_Field_Of_Study_Humanities_2011"]

RDF::Turtle::Writer.open(
  'output-owl/r-ontology.ttl',
  prefixes:  {
      rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
      geohive: "http://data.geohive.ie/resource/county/",
      owl: "http://www.w3.org/2002/07/owl#",
      opov: OPVO,
      ronto:  RONTO,
      geosparql: GEOSPARQL
    }
) do |writer|
  writer << Spira.repository
end
