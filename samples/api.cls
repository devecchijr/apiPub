Class apiPub.samples.api Extends %RegisteredObject [ ProcedureBlock ]
{

/// Add a new pet to the store
/// @apiPub[operationId="addPet"]
/// @apiPub[tag.name="pet"]
/// @apiPub[path="/pet"]
/// @apiPub[params.pPet.name="Body"]
/// @apiPub[params.description="Pet object that needs to be added to the store (sample)"]
/// @apiPub[params.required="true"]
Method addPet(pPet As apiPub.samples.Pet) As %Status [ WebMethod ]
{
    Quit $$$OK
}

/// @apiPub[params.description="Test 2"]
/// @apiPub[params.required="true"]
Method addPet2(pPet As apiPub.samples.Pet, pPet2 As apiPub.samples.Pet) As %Status [ WebMethod ]
{
}

/// @apiPub[params.pPet.schema="MeuCachorro"]
Method addPet3(pPet As %Library.DynamicObject) As %Status [ WebMethod ]
{
}

XData apiPub [ MimeType = application/json ]
{
{
        "schemas": {
            "MeuCachorro": {
                "type" : "object",
                "properties" : {
                    "id" : {
                        "type" : "integer",
                        "format" : "int64"
                    },
                    "nomeDoCao": {
                        "type":"string"
                    }
                }
            }
        },
        "info": {
                "description": "O titulo que eu achar melhor",
                "version": "1.0.0-oas3",
                "title": "Minha API",
                "termsOfService": "http://swagger.io/terms/",
                "contact": {
                    "email": "apiteam@swagger.io",
                    "url": ""
                },
                "license": {
                    "name": "Apache 2.0",
                    "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
                }
        },
        "tags": [
            {
                "name": "pet",
                "description": "Pet Services"
            }
        ]
    }
}

}
