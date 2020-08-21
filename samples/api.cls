Class apiPub.samples.api Extends %RegisteredObject [ ProcedureBlock ]
{

/// Add a new pet to the store
/// @apiPub[path="/pet"]
/// @apiPub[params.description="Pet object that needs to be added to the store"]
Method addPet(pPet As apiPub.samples.Pet) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        If $IsObject(##class(apiPub.samples.Pet).idIDXOpen(pPet.id)) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) Already Exists"))
        }
        Set tSC = ..savePet(pPet)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Update an existing pet
/// @apiPub[path="/pet"]
/// @apiPub[params.description="Pet object that needs to be added/updated to the store"]
/// @apiPub[verb="put"]
Method updatePet(pPet As apiPub.samples.Pet) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        If '$IsObject(##class(apiPub.samples.Pet).idIDXOpen(pPet.id)) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
        }
        Set tSC = ..savePet(pPet)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

Method savePet(pPet As apiPub.samples.Pet) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$IsObject(pPet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> Invalid Object"))
        }
        Set tCat = ##class(apiPub.samples.Category).idIDXOpen(pPet.category.id)
        If $IsObject(pPet.category) {
            Set tCat = ##class(apiPub.samples.Category).idIDXOpen(pPet.category.id)
            If '$IsObject(tCat) {
                Set tCat = ##class(apiPub.samples.Category).%New()
                Set tCat.id = pPet.category.id
                Set tCat.name = pPet.category.name
                Set tSC = tCat.%Save()
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
            Set pPet.category=tCat
        }
        Set tExPet = ##class(apiPub.samples.Pet).idIDXOpen(pPet.id)
        If $IsObject(tExPet) {
            Set tExPet.name=pPet.name
            Set tExPet.tags=pPet.tags
            Set tExPet.category=pPet.category
            Set tExPet.photoUrls=pPet.photoUrls
            Set tExPet.status=pPet.status
            Set tSC = tExPet.%Save()
        } Else {
            Set tSC = pPet.%Save()
        }
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Finds Pets by status
/// @apiPub[path="/pet/findByStatus"]
/// @apiPub[params.description="Multiple status values can be provided with comma separated strings"]
/// @apiPub[params.pStatus.description="Status values that need to be considered for filter"]
/// @apiPub[params.pStatus.schema.items.enum=["available","pending","sold"]]
/// @apiPub[params.pStatus.schema.default="available"]
Method findByStatus(pStatus As %String) As %ListOfObjects(ELEMENTTYPE="apiPub.samples.Pet") [ WebMethod ]
{
	Set sql = "SELECT ID1 FROM apiPub_samples.Pet WHERE status = ?"
	Set stat = ##class(%SQL.Statement).%New()
	Set Status = stat.%Prepare(sql)
	Set rset = stat.%Execute(pStatus)
    Set ret = ##class(%ListOfObjects).%New()
	While rset.%Next() {
        Do ret.Insert(##class(apiPub.samples.Pet).%OpenId(rset.ID1))
	}
    Return ret
}

/// Finds Pets by tags
/// @apiPub[path="/pet/findByTags"]
/// @apiPub[params.description="Muliple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."]
/// @apiPub[params.pTags.description="Tags to filter by"]
/// @apiPub[deprecated="true"]
Method findByTags(pTags As %Library.DynamicArray) As %ListOfObjects(ELEMENTTYPE="apiPub.samples.Pet") [ WebMethod ]
{
    Set tPet = ##class(apiPub.samples.Pet).%New()
    Set tRet = ##class(%ListOfObjects).%New()
    Do tRet.Insert(tPet)
    Return tRet
}

/// Find pet by ID
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[params.pId.description="ID of pet to return"]
/// @apiPub[params.pId.name="petId"]
Method getPetById(pId As %Integer) As apiPub.samples.Pet [ WebMethod ]
{
    Set tPet = ##class(apiPub.samples.Pet).idIDXOpen(pId)
    If '$IsObject(tPet) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
    }
    Return tPet
}

/// Updates a pet in the store with query data
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[operationId="updatePetWithQuery"]
/// @apiPub[params.petId.description="ID of pet that needs to be updated"]
/// @apiPub[params.name.description="Updated name of the pet"]
/// @apiPub[params.status.description="Updated status of the pet"]
/// @apiPub[verb="post"]
Method updatePetQuery(petId As %Integer, name As %String, status As %String) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set pPet = ##class(apiPub.samples.Pet).idIDXOpen(petId)
        If '$IsObject(pPet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
        }
        Set pPet.name = name
        Set pPet.status = status
        Set tSC = ..savePet(pPet)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Deletes a Pet
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[verb="delete"]
/// @apiPub[params.petId.description="Pet id to delete"]
Method deletePet(petId As %Integer) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set pPet = ##class(apiPub.samples.Pet).idIDXOpen(petId)
        If '$IsObject(pPet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
        }
        Set tSC = ##class(apiPub.samples.Pet).%DeleteId(pPet.%Id())
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

XData apiPub [ MimeType = application/json ]
{
{
        "info" : {
            "description" : "This is a sample Petstore server.  You can find\nout more about Swagger at\n[http://swagger.io](http://swagger.io) or on\n[irc.freenode.net, #swagger](http://swagger.io/irc/).\n",
            "version" : "1.0.0",
            "title" : "Swagger Petstore",
            "termsOfService" : "http://swagger.io/terms/",
            "contact" : {
            "email" : "apiteam@swagger.io"
            },
            "license" : {
            "name" : "Apache 2.0",
            "url" : "http://www.apache.org/licenses/LICENSE-2.0.html"
            }
        },
        "tags" : [ {
            "name" : "pet",
            "description" : "Everything about your Pets",
            "externalDocs" : {
            "description" : "Find out more",
            "url" : "http://swagger.io"
            }
        }, {
            "name" : "store",
            "description" : "Access to Petstore orders"
        }, {
            "name" : "user",
            "description" : "Operations about user",
            "externalDocs" : {
            "description" : "Find out more about our store",
            "url" : "http://swagger.io"
            }
        } ]
    }
}

}
