SELECT ?idAttribute ?value ?labelLg1 ?labelLg2 ?codeList ?rangeType ?hasDocLg1 ?hasDocLg2 ?maxOccurs
	FROM <${DOCUMENTATIONS_GRAPH}/${idSims}>
	FROM <${CODELIST_GRAPH}> 
	FROM <${ORGANIZATIONS_GRAPH}>
	FROM <${ORG_INSEE_GRAPH}>

    FROM NAMED  <${MSD_GRAPH}> 
 	FROM NAMED  <${COG_GRAPH}>
	FROM NAMED  <${GEO_SIMS_GRAPH}>
WHERE { 
 		<#-- RangeType.DATE : value -->
		{
			?report rdf:type sdmx-mm:MetadataReport .
			?reportAttr sdmx-mm:metadataReport ?report .
			BIND(REPLACE( STR(?attr) , '(.*/)(\\w.+$)', '$2' ) AS ?idAttribute) . 
			?reportAttr ?attr ?value . 
			FILTER ( datatype(?value) = <${DATE.rdfType}> ) 
			BIND('${DATE.jsonType}' AS ?rangeType) .
		} 
			
		<#-- RangeType.RICHTEXT : label, hasDoc -->
		UNION {
			 ?report rdf:type sdmx-mm:MetadataReport .
			 ?reportAttr sdmx-mm:metadataReport ?report .
			 
			 ?reportAttr ?attr ?textLg1 .
			 ?textLg1 rdf:type dcmitype:Text .
			 FILTER(EXISTS{?textLg1 dcterms:language <${LG1_CL}>})

			 OPTIONAL{ 
				?textLg1 rdf:value ?labelLg1 
			}
			 BIND(EXISTS{?textLg1 insee:additionalMaterial ?docLg1} AS ?hasDocLg1)

			 OPTIONAL {
				 ?reportAttr ?attr ?textLg2 .
				 ?textLg2 rdf:type dcmitype:Text .
				 FILTER(EXISTS{?textLg2 dcterms:language <${LG2_CL}>})

						OPTIONAL{ 
							?textLg2 rdf:value ?labelLg2 
						}
						BIND(EXISTS{?textLg2 insee:additionalMaterial ?docLg2} AS ?hasDocLg2)
			 }
			 
			 BIND(REPLACE( STR(?attr) , '(.*/)(\\w.+$)', '$2' ) AS ?idAttribute) . 


			 BIND('${RICHTEXT.jsonType}' AS ?rangeType) . 
		} 
		
		<#-- RangeType.STRING : label -->
		UNION {
			 ?report rdf:type sdmx-mm:MetadataReport .
			 ?reportAttr sdmx-mm:metadataReport ?report .
			BIND(REPLACE( STR(?attr) , '(.*/)(\\w.+$)', '$2' ) AS ?idAttribute) . 
			 ?reportAttr ?attr ?labelLg1 .
			 FILTER(lang(?labelLg1) = '${LG1}') 
			 OPTIONAL{?reportAttr ?attr ?labelLg2 .
			 FILTER(lang(?labelLg2) = '${LG2}') } 
			 BIND('${STRING.jsonType}' AS ?rangeType) . 
		} 
			
		<#-- RangeType.CODELIST : value, codelist, maxoccurs -->
		UNION {
			?report rdf:type sdmx-mm:MetadataReport .
			?reportAttr sdmx-mm:metadataReport ?report .
			BIND(REPLACE( STR(?attr) , '(.*/)(\\w.+$)', '$2' ) AS ?idAttribute) . 
			?reportAttr ?attr ?codeUri . 
			?codeUri skos:notation ?value .
			?codeUri skos:inScheme ?listUri .
			?listUri skos:notation ?codeList .
			BIND('${CODELIST.jsonType}' AS ?rangeType) .
						
			OPTIONAL {
				GRAPH  <${MSD_GRAPH}>  {
					?mas sdmx-mm:metadataAttributeProperty ?attr . 
					?mas sdmx-mm:maxOccurs ?maxOccurs
				}
			} .
		} 
		<#-- RangeType.ORGANIZATION : value -->
		UNION {
			?report rdf:type sdmx-mm:MetadataReport .
			?reportAttr sdmx-mm:metadataReport ?report .
			?reportAttr ?attr ?organisationUri . 
			BIND(REPLACE( STR(?attr) , '(.*/)(\\w.+$)', '$2' ) AS ?idAttribute) . 
			?organisationUri dcterms:identifier ?value .
			BIND('${ORGANIZATION.jsonType}' AS ?rangeType) .
		} 
		
		<#-- RangeType.GEOGRAPHY : value (uri), label -->
		UNION {
			?report rdf:type sdmx-mm:MetadataReport .
			?reportAttr sdmx-mm:metadataReport ?report .
			?reportAttr ?attr ?value . 
			GRAPH  <${MSD_GRAPH}>  {
					?attr rdfs:range geo:Feature .
				}
			BIND(REPLACE( STR(?attr) , '(.*/)(\\w.+$)', '$2' ) AS ?idAttribute) .
			GRAPH  ?g {
				?value skos:prefLabel|igeo:name|rdfs:label ?labelLg1 .
			}
			BIND('${GEOGRAPHY.jsonType}' AS ?rangeType) .
		} 
			
}