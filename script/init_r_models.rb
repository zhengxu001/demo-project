# Spira.repository = RDF::Repository.load("#{Rails.root}/config/initializers/r-ontology.ttl")

require 'spira'
require "rdf/vocab"
require 'rdf/rdfxml'
require 'rdf/ntriples'
require 'rdf/nquads'
require 'rubygems'
require 'sparql'
require 'csv'

Spira.repository = RDF::Repository.load("output-owl/r-ontology.ttl")
query = "PREFIX ronto: <http://r-ontology.com/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#> 
select ?villages ?num where { 
	?a ronto:PercHighLvlDeg2011 ?edu . 
	FILTER (?edu < 20) 
	?a ronto:forArea ?b . 
	?c rdfs:label \"DUBLIN\" . 
	?b geosparql:ehInside ?c . 
	?e ronto:PercPopCatholic2011 ?num . 
	?e ronto:forArea ?b . 
	?b rdfs:label ?villages . }"
solutions = SPARQL.execute(query, Spira.repository)
solutions.each do |solution|
    p solution.villages
end
# In 2011, which villages of Carlow have more than %90 Irish population and more than %5 of the people have a post-graduate degree.
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# select ?villages where {
# ?b ronto:PercPostGrad2011 ?postrate . 
# FILTER (?postrate > 2) 
# ?e ronto:PercPopIrish2011 ?irish . 
# FILTER (?irish > 80)
# ?e ronto:forArea ?a .  
# ?b ronto:forArea ?a . 
# ?c rdfs:label \"CARLOW\" . 
# ?a geosparql:ehInside ?c . 
# ?a rdfs:label ?villages
# }"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
#     p solution.villages
# end

# Which villages of Dublin have less than %89 Catholic population and less than %20 of the people have the highest level of education degree in 2011.
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# select ?villages where {
# ?b ronto:PercPopCatholic2011 ?catholic . 
# FILTER (?catholic < 89) 
# ?e ronto:PercHighLvlDeg2011 ?edu . 
# FILTER (?edu < 20)
# ?e ronto:forArea ?a . 
# ?b ronto:forArea ?a . 
# ?c rdfs:label \"DUBLIN\" . 
# ?a geosparql:ehInside ?c . 
# ?a rdfs:label ?villages
# }"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
#     p solution.villages
# end

# In 2011, how much people have studied art in the villages of Carlow which have more than 750 people who were born in Ireland.
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# select ?villages ?num where {
# ?a ronto:PopIEBirth2011 ?pop
# FILTER (?pop > 750) 
# ?a ronto:forArea ?b . 
# ?c rdfs:label \"CARLOW\" . 
# ?b geosparql:ehInside ?c . 
# ?e ronto:PopStudiedArt2011 ?num . 
# ?e ronto:forArea ?b .
# ?b rdfs:label ?villages
# }"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
# 	p solution.villages
#     p solution.num
# end

# In 2011, what are the percentages of people who have a degree in humanities in the villages of Dublin City which have more than %85 of the population were born in Ireland.
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# select ?villages ?num where {
# ?a ronto:PercPopIEBirth2011 ?pop
# FILTER (?pop > 85) 
# ?a ronto:forArea ?b . 
# ?c rdfs:label \"DUBLIN\" . 
# ?b geosparql:ehInside ?c . 
# ?e ronto:PercPopStudiedHum2011 ?num . 
# ?e ronto:forArea ?b . 
# ?b rdfs:label ?villages .
# }"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
# 	p solution.villages
#     p solution.num
# end

# Question 5: Which villages of Ireland have more than %1 Polish population and more than %5 of the people have a post-graduate degree in 2011. (Classes: Location – Ethnicity – Education)
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# select ?villages where {
# ?a ronto:PercPopPolish2011 ?pop
# FILTER (?pop > 1) 
# ?e ronto:PercPostGrad2011 ?num . 
# FILTER (?num > 5) 
# ?a ronto:forArea ?b . 
# ?e ronto:forArea ?b . 
# ?b rdfs:label ?villages .
# }"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
# 	p solution.villages
# end

# Question 6: In 2011, which villages have a population that more than %1 of the people cannot speak English and less than %21 of the people have the highest level of education degree in 2011. (Classes: Location – Language – Education)
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# select ?g where {
# ?a ronto:PercNonEnSpeakers2011 ?pop
# FILTER (?pop > 5) 
# ?a ronto:forArea ?b . 
# ?b geosparql:ehInside ?c .
# ?c rdfs:label ?county
# ?county geosparql:defaultGeometry ?g . 
# }"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
# 	p solution.county
# end

# Question 7: Which county has the shcool that has most male student, show the geometry
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# SELECT ?num ?g
# WHERE { 
# 	?s ronto:maleNum ?num .
# 	?s ronto:hasScoordinate ?sl .
# 	?sl geosparql:ehInside ?county .
# 	?county geosparql:defaultGeometry ?g . 
# }
# ORDER BY DESC(?num) LIMIT 1"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
# 	p solution.num
# 	p solution.g
# end

# Question 8: Show the county has the shcools that femal are more than male, show the geometry
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# select ?g where {
# ?s ronto:maleNum ?male .
# ?s ronto:femaleNum ?female . 
# FILTER (?female < ?male) 
# ?s ronto:hasScoordinate ?sl .
# ?sl geosparql:ehInside ?county .
# ?county geosparql:defaultGeometry ?g . 
# }"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
# 	p solution.g
# end

# Question 9: Show the county has the schools only have female students, show the geometry
# query = "PREFIX ronto: <http://r-ontology.com/>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
# select ?g where {
# ?s ronto:maleNum ?male .
# FILTER (?male = 0) 
# ?s ronto:hasScoordinate ?sl .
# ?sl geosparql:ehInside ?county .
# ?county geosparql:defaultGeometry ?g . 
# }"
# solutions = SPARQL.execute(query, Spira.repository)
# solutions.each do |solution|
# 	p solution.g
# end
