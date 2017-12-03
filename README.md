###Question 1: 
+ In 2011, which villages of Carlow have more than %90 Irish population and more than %5 of the people have a post-graduate degree. (Classes: Location – Ethnicity – Education)

PREFIX ronto: <http://www.r-ontology.com#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
select ?villages where {
?b ronto:PercPostGrad2011 ?postrate . 
FILTER (?postrate > 5) 
?b ronto:forArea ?a . 
?e ronto:PercPopIrish2011 ?irish . 
FILTER (?postrate > 90) 
?e ronto:forArea ?a . 
?c a ronto:Geohive . 
?c rdfs:label "CARLOW" . 
?a geosparql:ehInside ?c . 
?a rdfs:label ?villages . 
}

###Question 2:
+ In 2011, which villages of Carlow have more than %90 Irish population and more than %5 of the people have a post-graduate degree. (Classes: Location – Ethnicity – Education)

PREFIX ronto: <http://www.r-ontology.com#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#>
select ?villages where {
?b ronto:PercPostGrad2011 ?postrate . 
FILTER (?postrate > 5) 
?b ronto:forArea ?a . 
?e ronto:PercPopIrish2011 ?irish . 
FILTER (?postrate > 90) 
?e ronto:forArea ?a . 
?c a ronto:Geohive . 
?c rdfs:label "CARLOW" . 
?a geosparql:ehInside ?c . 
?a rdfs:label ?villages . 
}
