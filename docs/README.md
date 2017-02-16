#JavaScript object notation for linked data patching

Greenall, Rurik T.  
Computas AS  
25 January 2017

##Abstract
JavaScript Object Notation for Linked-Data patching (JSON-LD-PATCH) defines a document structure for expressing a sequence of operations to apply to an existing linked data resource; it is suitable for use with the HTTP PATCH method. The "application/ldpatch+json" media type is used to identify such patch documents

##Status of this memo
This document has been prepared by Oslo public library. 

##Copyright notice
This document is provided with a CC0 licence, the full text of this licence can be found at https://creativecommons.org/publicdomain/zero/1.0/

##Table of contents

###Nothing doing

##Introduction
[IETF-RFC6902](https://tools.ietf.org/html/rfc6902) defines a JavaScript Object Notation (JSON) [IETF-RFC71599](https://tools.ietf.org/html/rfc7159) document structure that can be used with the PATCH extension of HTTP [IETF-RFC5789](https://tools.ietf.org/html/rfc5789) to apply partial modification of documents. Because linked data is typically expressed as [RDF](https://www.w3.org/TR/rdf11-primer/), it is inappropriate to use JSON-PATCH as defined in [IETF-RFC6902](https://tools.ietf.org/html/rfc6902) directly. 

JSON-PATCH informed the development of this format along with other resources, such as:

- [Linked data patch format](https://www.w3.org/TR/ldpatch/)
- [RDF patch](https://afs.github.io/rdf-patch/)
- [Turtle patch](https://www.w3.org/2001/sw/wiki/TurtlePatch)
- [SPARQL UPDATE](https://www.w3.org/TR/sparql11-update/)

In developing this format, we have moved away from the SPARQL-oriented approach and attempted to define a patch format similar to [RDF patch](https://afs.github.io/rdf-patch/) that would allow simple patching of RDF documents via named resource HTTP-URIs.

##Conventions
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [IETF-RFC2119](https://tools.ietf.org/html/rfc2119).

When refering to IRIs, it MUST be assumed that the IRI is fully qualified.

##Document structure
A JSON-LD-PATCH document is a JSON [IETF-RFC71599](https://tools.ietf.org/html/rfc7159) document that represents an array of objects; each object represents a single operation to be applied to a target linked data resource.

The following is an example JSON-LD-PATCH document, transferred in an HTTP PATCH request:

```
PATCH /my/resource HTTP/1.1
Host: example.org
Content-Length:858
Accept: application/ld+json

[
  {
    "op": "add",
    "s": "http://example.org/my/resource",
    "p": "http://example.org/ontology#title",
    "o": {
      "value": "New Title",
      "type": "http://www.w3.org/2001/XMLSchema#string"
    }
  },
  {
    "op": "del",
    "s": "http://example.org/my/resource",
    "p": "http://example.org/ontology#publicationYear",
    "o": {
      "value": "2013",
      "type": "http://www.w3.org/2001/XMLSchema#gYear"
    }
  },
  {
    "op": "add",
    "s": "http://example.org/my/resource",
    "p": "http://example.org/ontology#publicationYear",
    "o": {
      "value": "2017",
      "type": "http://www.w3.org/2001/XMLSchema#gYear"
    }
  },
  {
    "op": "add",
    "s": "http://example.org/my/resource",
    "p": "http://example.org/ontology#numberOfPages",
    "o": {
      "value": "89",
      "type": "http://www.w3.org/2001/XMLSchema#string"
    }
  }
]
``` 
Evaluation of a JSON-LD-PATCH document occurs as a single event. Operations are sorted and processed as groups of delete and then add operations until the opperations are applied or the entire patch fails.

##Operations
Operation objects MUST have exactly one "op" (operation) member; this value indicates which operation is to be performed. The value MUST be one of "add" or "del"; all other values result in an error.

Operations objects MUST have exactly one "s", subject, member. The value of this member MUST be one of [IRI](https://tools.ietf.org/html/rfc3987) or [blank node](https://www.w3.org/TR/2014/REC-rdf11-mt-20140225/#blank-nodes).

In cases where JSON-LD-PATCH is applied to a named REST resource, the resource that is patched SHOULD be the one identified as the target of the HTTP request. Thus, the HTTP-URI identifying the resource manifests itself as the "s" member; an explanation of how this works with blank nodes is provided below.

Operations objects MUST have exactly one "p", predicate, member. The value of this member MUST be an [IRI](https://tools.ietf.org/html/rfc3987).

Operations objects MUST have exactly one "o", object, member. The value of this member MUST be one of string or object. This object MUST be contain two members, a "value" and a "datatype".

In the case that the value of "o" is a string, this MUST interpreted as either an [IRI](https://tools.ietf.org/html/rfc3987) or a [blank node](https://www.w3.org/TR/2014/REC-rdf11-mt-20140225/#blank-nodes). 

**Note:** when a patch is applied with an IRI object, the existence of a resource with that identifier cannot be assumed; this contrasts strongly with blank nodes, which MUST exist and be fully defined in the patch in which they are referred to (see "Handling blank nodes" below).

In cases where the value is an object, the value of "datatype" must be a valid [XML Schema datatype](https://www.w3.org/TR/xmlschema-2/). The interpretation of "value" MUST be in accordance with the value of "datatype" so that the value passed as a patch to the document is meaningful in RDF.  

Note that early implementations provided support for objects where "datatypes" with values [http://www.w3.org/2001/XMLSchema#anyURI](https://www.w3.org/TR/xmlschema11-2/#anyURI) were provided with "values" IRI or a blank node. This latter usage is strongly discouraged; if a consistent syntax is required, an XML schema datatype for blank node MUST be used.

###add
Add has a very simple function, it always adds new sets of statements. If a pre-existing statement exists with similar or the same characteristics, it MUST NOT be overwritten. To overwrite, a delete and an add operation must be performed.

###del
Del also has a very simple function, it always removes sets of statements.

###Blank node handling
Blank nodes are anonymous resources that are referenced using the following syntax ```_:document_unique_id```. The ```document_unique_id``` is typically given as ```b + n``` where *n* is an integer, incrementing for each new blank node. 

In order for blank nodes to be added or deleted, it is necessary to define their relation to a named node. For example, the following MUST fail:

```
{
  "op": "del",
  "s": "_:b0",
  "p": "http://example.org/name",
  "o": {
    "value": "Nothing",
    "datatype": "http://www.w3.org/2001/XMLSchema#string"
  }
}
```
While the following is a valid request:

```
[
  {
    "op": "del", 
    "s": "http://example.org/aResource",
    "p": "http://example.org/ontology#someRelation",
    "o": "_:b0"
  },
  {
    "op": "del",
    "s": "_:b0",
    "p": "http://example.org/name",
    "o": {
      "value": "Nothing",
      "datatype": "http://www.w3.org/2001/XMLSchema#string"
    }
  }
]
```

In cases where further statements are attached to a blank node referenced in the patch, not only MUST these remain unaffected by the patch, but the relation between the fully qualified IRI and the blank node MUST remain intact. Thus, to fully remove a blank node, all properties of the node MUST be referenced in the patch. In this sense, adding data to a blank node is a matter of deleting the entire node (including all its statements) and inserting an amended copy. This, while tedious, removes the possibility of identity problems and ensures that empty nodes are not left when blank nodes are updated.

##Error handling
If a normative requirement is violated by a JSON-LD-PATCH document, or if an operation is unsuccessful, then processing of the patch MUST terminate and the entire patch be deemed unsuccessful.

See [IETF-RFC5789 section 2.2](https://tools.ietf.org/html/rfc5789#section-2.2) for details concerning errors in HTTP PATCH.
##MIME-type

application/ldpatch+json

##Examples
Note that each example assumes a new resource with no data, unless otherwise stated.

###Adding a statement to an existing resource

```
{
  "op": "add", 
  "s": "http://example.org/myResource", 
  "p": "http://example.org/ontology#name", 
  "o": {
    "value": "Herbjørg", 
    "datatype": "http://www.w3.org/2001/XMLSchema#string"
  }
}
```
Result:

```<http://example.org/myResource> <http://example.org/ontology#name> "Herbjørg"^^<http://www.w3.org/2001/XMLSchema#string> . ```

###Adding multiple statements to a resource

```
[
  {
    "op": "add", 
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#birthDate", 
    "o": {
      "value": "1962-12-02", 
      "datatype": "http://www.w3.org/2001/XMLSchema#date"
    }
  },
  {
    "op": "add", 
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#namePrefix", 
    "o": {
      "value": "HRH", 
      "datatype": "http://www.w3.org/2001/XMLSchema#string"
    }
  }
]
```
Result:

```
<http://example.org/myResource> <http://example.org/ontology#birthDate> "1962-12-02"^^<http://www.w3.org/2001/XMLSchema#date> .
<http://example.org/myResource> <http://example.org/ontology#namePrefix> "HRH"^^<http://www.w3.org/2001/XMLSchema#string> .
```
###Deleting a statement from a resource

Assuming a resource:

```
<http://example.org/myResource> <http://example.org/ontology#birthDate> "1962-12-02"^^<http://www.w3.org/2001/XMLSchema#date> .
<http://example.org/myResource> <http://example.org/ontology#namePrefix> "HRH"^^<http://www.w3.org/2001/XMLSchema#string> .
```
Patch:

```
{
  "op": "del", 
  "s": "http://example.org/myResource", 
  "p": "http://example.org/ontology#namePrefix", 
  "o": {
    "value": "HRH", 
    "datatype": "http://www.w3.org/2001/XMLSchema#string"
  }
}
```
Result:

```
<http://example.org/myResource> <http://example.org/ontology#birthDate> "1962-12-02"^^<http://www.w3.org/2001/XMLSchema#date> .
```

###Deleting multiple statements from a resource

Assuming a resource:

```
<http://example.org/myResource> <http://example.org/ontology#id> "id_seumas"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://example.org/myResource> <http://example.org/ontology#birthDate> "1980-01-22"^^<http://www.w3.org/2001/XMLSchema#date> .
<http://example.org/myResource> <http://example.org/ontology#name> "Seumas"^^<http://www.w3.org/2001/XMLSchema#string> .
```
Patch:

```
[
  {
    "op": "del", 
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#name", 
    "o": {
      "value": "Seumas", 
      "datatype": "http://www.w3.org/2001/XMLSchema#string"
    }
  },
  {
    "op": "del", 
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#birthDate", 
    "o": {
      "value": "1980-01-22", 
      "datatype": "http://www.w3.org/2001/XMLSchema#date"
    }
  }
]
```
Result:

```
<http://example.org/myResource> <http://example.org/ontology#id> "id_seumas"^^<http://www.w3.org/2001/XMLSchema#string> .
```
###Deleting and adding statements
Assuming a resource:

```
<http://example.org/myResource> <http://example.org/ontology#id> "id_livia"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://example.org/myResource> <http://example.org/ontology#name> "Livia"^^<http://www.w3.org/2001/XMLSchema#string> .
```
Patch:

```
[
  {
    "op": "del", 
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#name", 
    "o": {
      "value": "Livia", 
      "datatype": "http://www.w3.org/2001/XMLSchema#string"
    }
  },
  {
    "op": "add", 
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#birthDate", 
    "o": {
      "value": "1972-08-18", 
      "datatype": "http://www.w3.org/2001/XMLSchema#date"
    }
  }
]
```
Result:

```
<http://example.org/myResource> <http://example.org/ontology#id> "id_livia"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://example.org/myResource> <http://example.org/ontology#birthDate> "1972-08-18"^^<http://www.w3.org/2001/XMLSchema#date> .
```
###Replacing values
```
<http://example.org/myResource> <http://example.org/ontology#id> "id_max"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://example.org/myResource> <http://example.org/ontology#birthDate> "1999-02-23"^^<http://www.w3.org/2001/XMLSchema#date> .
```
Patch:

```
[
  {
    "op": "del", 
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#birthDate", 
    "o": {
      "value": "1999-02-23", 
      "datatype": "http://www.w3.org/2001/XMLSchema#date"
    }
  },
  {
    "op": "add", 
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#birthDate", 
    "o": {
      "value": "1999-02-21", 
      "datatype": "http://www.w3.org/2001/XMLSchema#date"
    }
  }
]
```
Result:

```
<http://example.org/myResource> <http://example.org/ontology#id> "id_max"^^<http://www.w3.org/2001/XMLSchema#string> .
<http://example.org/myResource> <http://example.org/ontology#birthDate> "1972-02-21"^^<http://www.w3.org/2001/XMLSchema#date> .
```

###Adding relationships to other resources

```
{
  "op": "add",
  "s": "http://example.org/myResource", 
  "p": "http://example.org/ontology#sameAs", 
  "o": "http://example.org/otherResource"
}
```
Result:

```
<http://example.org/myResource> <http://example.org/ontology#sameAs> <http://example.org/otherResource> .
```

###Adding blank nodes to a resource

```
[
  {
    "op": "add",
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#hasPet", 
    "o": "_:b0"
  },
  {
    "op": "add",
    "s": "_:0", 
    "p": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", 
    "o": "http://example.org/ontology#Horse"
  },
  {
    "op": "add", 
    "s": "_:b0", 
    "p": "http://example.org/ontology#name", 
    "o": {
      "value": "Dobbin", 
      "datatype": "http://www.w3.org/2001/XMLSchema#string"
    }
  }
]
```
Result:

```
<http://example.org/myResource> <http://example.org/ontology#hasPet> _:b01231123123 .
_:b01231123123 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/ontology#Horse>  .
_:b01231123123 <http://example.org/ontology#name> "Dobbin"^^<http://www.w3.org/2001/XMLSchema#string> .
```

###Deleting blank nodes
For a resource:

```
<http://example.org/myResource> <http://example.org/ontology#hasPet> _:b01231123123 .
_:b01231123123 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/ontology#Horse>  .
_:b01231123123 <http://example.org/ontology#name> "Dobbin"^^<http://www.w3.org/2001/XMLSchema#string> .
```
Patch:

```
[
  {
    "op": "del",
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#hasPet", 
    "o": "_:b0"
  },
  {
    "op": "del",
    "s": "_:0", 
    "p": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", 
    "o": "http://example.org/ontology#Horse"
  }
]
```
Result:

```
<http://example.org/myResource> <http://example.org/ontology#hasPet> _:b01231123123 .
_:b01231123123 <http://example.org/ontology#name> "Dobbin"^^<http://www.w3.org/2001/XMLSchema#string> .
```
To fully remove the original blank node, the following patch would have to be given:

```
[
  {
    "op": "del",
    "s": "http://example.org/myResource", 
    "p": "http://example.org/ontology#hasPet", 
    "o": "_:b0"
  },
  {
    "op": "del",
    "s": "_:0", 
    "p": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", 
    "o": "http://example.org/ontology#Horse"
  },
  {
    "op": "del",
    "s": "_:0", 
    "p": "http://example.org/ontology#name", 
    "o": {
      "value": "Dobbin",
      "datatype": "http://www.w3.org/2001/XMLSchema#string"
  }
]
```
##EBNF for JSON-LD-PATCH

