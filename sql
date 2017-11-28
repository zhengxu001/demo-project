county	PREFIX root: <http://kdetask.com#> select ?a where {?a a root:County}

all schools PREFIX root: <http://kdetask.com#> select ?a where {?a a root:School}

PREFIX kde: <http://kdetask.com#>  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#> select ?location where { ?a kde:male ?num . FILTER (?num > 100) ?a kde:location ?location .}

PREFIX kde: <http://kdetask.com#>  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#> select DISTINCT ?c where { ?b a kde:County .  ?b rdfs:label ?name . ?a kde:male ?num . FILTER (?num > 100) ?a kde:location ?location . FILTER(?name = ?location) ?b geosparql:geometry ?c}

county	PREFIX kde: <http://kdetask.com#>  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX geosparql: <http://schemas.opengis.net/geosparql/1.0/geosparql_vocab_all.rdf#> select ?coordinate where { ?a kde:male ?num . FILTER (?num > 100) ?a kde:location ?location . ?b rdfs:label ?county . FILTER(?label = ?location) ?b geosparql:geomety ?coordinate . }
