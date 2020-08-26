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
	Set sql = "SELECT ID1 FROM apiPub_samples.Pet WHERE status in ('"_$Replace(pStatus,",","','")_"')"
	Set stat = ##class(%SQL.Statement).%New()
	Set Status = stat.%Prepare(sql)
	Set rset = stat.%Execute()
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
    set tags=""
    Set tIter = pTags.%GetIterator()
    While tIter.%GetNext(.key,.value) {
        Set tags = tags_$Select(key=0:"",1:",")_"'"_value_"'"
    }
	Set sql = "SELECT ID1 FROM apiPub_samples.Pet WHERE ID1 in (SELECT pet FROM apiPub_samples.Tag WHERE name in ("_tags_"))"
    Set stat = ##class(%SQL.Statement).%New()
	Set Status = stat.%Prepare(sql)
	Set rset = stat.%Execute()
    Set ret = ##class(%ListOfObjects).%New()
	While rset.%Next() {
        Do ret.Insert(##class(apiPub.samples.Pet).%OpenId(rset.ID1))
	}
    Return ret
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
        Set pet = ##class(apiPub.samples.Pet).idIDXOpen(petId)
        If '$IsObject(pet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
        }
        Set pet.name = name
        Set pet.status = status
        Set tSC = ..savePet(pet)
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
/// @apiPub[params.id.name="petId"]
/// @apiPub[params.apikey.input="header"]
/// @apiPub[params.apikey.name="api_key"]
Method deletePet(apikey As %String, id As %Integer) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set pPet = ##class(apiPub.samples.Pet).idIDXOpen(id)
        If '$IsObject(pPet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
        }
        Set sql = "Delete FROM apiPub_samples.Tag WHERE pet = ?"
        Set stat = ##class(%SQL.Statement).%New()
        Set tSC = stat.%Prepare(sql)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set rset = stat.%Execute(pPet.%Id())
        Set tSC = ##class(apiPub.samples.Pet).%DeleteId(pPet.%Id())
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Returns pet inventories by status
/// @apiPub[tag="store"]
/// @apiPub[path="/store/inventory"]
/// @apiPub[params.description="Returns a map of status codes to quantities"]
/// @apiPub[response.schema="Inventory"]
Method getInventory() As %Library.DynamicObject [ WebMethod ]
{
	Set sql = "SELECT LOWER(status) status,count(*) ct FROM apiPub_samples.Pet GROUP BY LOWER(status)"
    Set stat = ##class(%SQL.Statement).%New()
	Set Status = stat.%Prepare(sql)
	Set rset = stat.%Execute()
    Set ret = {}
	While rset.%Next() {
        do ret.%Set(rset.status,rset.ct)
	}
    Return ret
}

/// Place an order for a pet
/// @apiPub[path="/store/order"]
/// @apiPub[tag="store"]
/// @apiPub[params.description="order placed for purchasing the pet"]
Method placeOrder(pOrder As apiPub.samples.Order) As %Status [ WebMethod ]
{
    If $IsObject(##class(apiPub.samples.Order).idIDXOpen(pOrder.id)) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Order (id) Already Exists"))
    }
    If '$IsObject(pOrder.pet) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Invalid Pet (id)"))
    Quit pOrder.%Save()
}

/// Find purchase order by ID
/// @apiPub[path="/store/order/{orderId}"]
/// @apiPub[tag="store"]
/// @apiPub[params.description="For valid response try integer IDs with value >\= 1 and <\= 10. Other values will generated exceptions"]
/// @apiPub[params.orderId.description="ID of pet that needs to be fetched"]
Method getOrderById(orderId As %Integer(MINVAL=1,MAXVAL=10)) As apiPub.samples.Order [ WebMethod ]
{
    Set order = ##class(apiPub.samples.Order).idIDXOpen(orderId)
    If '$IsObject(order) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> Order (id) doesn't Exist"))
    }
    Quit order
}

/// Delete purchase order by ID
/// @apiPub[path="/store/order/{orderId}"]
/// @apiPub[tag="store"]
/// @apiPub[verb="delete"]
/// @apiPub[params.description="For valid response try integer IDs with positive integer value. Negative or non-integer values will generate API errors"]
/// @apiPub[params.orderId.description="ID of the order that needs to be deleted"]
Method deleteOrder(orderId As %Integer(MINVAL=1)) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set order = ##class(apiPub.samples.Order).idIDXOpen(orderId)
        If '$IsObject(order) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Order (id) doesn't Exist"))
        }
        Set tSC = ##class(apiPub.samples.Order).%DeleteId(order.%Id())
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Create user
/// @apiPub[path="/user"]
/// @apiPub[tag="user"]
/// @apiPub[params.description="This can only be done by the logged in user."]
Method createUser(pUser As apiPub.samples.User) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        If $IsObject(##class(apiPub.samples.User).idIDXOpen(pUser.id)) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User (id) Already Exists"))
        }
        Set tSC = ..saveUser(pUser)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Creates list of users with given input array
/// @apiPub[path="/user/createWithArray"]
/// @apiPub[tag="user"]
/// @apiPub[params.description="List of user object"]
Method createUsersWithArrayInput(pArrayOfUsers As %ArrayOfObjects(ELEMENTTYPE="apiPub.samples.User")) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //Validate Array
        For i=1: 1: pArrayOfUsers.Count() {
            Set tUser=pArrayOfUsers.GetAt(i)
            If $IsObject(##class(apiPub.samples.User).idIDXOpen(tUser.id)) {
                Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User (id) Already Exists"))
            }
        }
        //Save
        For i=1: 1: pArrayOfUsers.Count() {
            Set tUser=pArrayOfUsers.GetAt(i)
            Set tSC = ..saveUser(tUser)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        }
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Creates list of users with given input array
/// @apiPub[path="/user/createWithList"]
/// @apiPub[tag="user"]
/// @apiPub[params.description="List of user object"]
Method createUsersWithListInput(pListOfUsers As %ListOfObjects(ELEMENTTYPE="apiPub.samples.User")) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //Validate List
        For i=1: 1: pListOfUsers.Count() {
            Set tUser=pListOfUsers.GetAt(i)
            If $IsObject(##class(apiPub.samples.User).idIDXOpen(tUser.id)) {
                Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User (id) Already Exists"))
            }
        }
        //Save
        For i=1: 1: pListOfUsers.Count() {
            Set tUser=pListOfUsers.GetAt(i)
            Set tSC = ..saveUser(tUser)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        }
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Update user
/// @apiPub[path="/user/{username}"]
/// @apiPub[verb="put"]
/// @apiPub[tag="user"]
/// @apiPub[params.description="This can only be done by the logged in user."]
/// @apiPub[params.pUserName.name="username"]
Method updateUser(pUserName As %String, pUser As apiPub.samples.User) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        If '$IsObject(##class(apiPub.samples.User).usernameIDXOpen(pUserName)) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User (username) doesn't Exist"))
        }
        Set tSC = ..saveUser(pUser)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

Method saveUser(pUser As apiPub.samples.User) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$IsObject(pUser) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> Invalid Object"))
        }
        Set tExUser = ##class(apiPub.samples.User).idIDXOpen(pUser.id)
        If $IsObject(tExUser) {
            Set tExUser.username=pUser.username
            Set tExUser.firstName=pUser.firstName
            Set tExUser.lastName=pUser.lastName
            Set tExUser.email=pUser.email
            Set tExUser.password=pUser.password
            Set tExUser.phone=pUser.phone
            Set tSC = tExUser.%Save()
        } Else {
            Set tSC = pUser.%Save()
        }
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Get user by user name
/// @apiPub[tag="user"]
/// @apiPub[path="/user/{username}"]
/// @apiPub[params.pUserName.description="The name that needs to be fetched"]
/// @apiPub[params.pUserName.name="username"]
Method getUserByName(pUserName As %String) As apiPub.samples.User [ WebMethod ]
{
    Set tUser = ##class(apiPub.samples.User).usernameIDXOpen(pUserName)
    If '$IsObject(tUser) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "username doesn't Exist"))
    }
    Return tUser
}

/// Delete user
/// @apiPub[tag="user"]
/// @apiPub[verb="delete"]
/// @apiPub[path="/user/{username}"]
/// @apiPub[params.pUserName.description="The name that needs to be deleted"]
/// @apiPub[params.pUserName.name="username"]
Method deleteUser(pUserName As %String) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set tUser = ##class(apiPub.samples.User).usernameIDXOpen(pUserName)
        If '$IsObject(tUser) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "username doesn't Exist"))
        }
        Set tSC = ##class(apiPub.samples.User).%DeleteId(tUser.%Id())
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Logs user into the system
/// @apiPub[tag="user"]
/// @apiPub[path="/user/login"]
/// @apiPub[params.username.required="true"]
/// @apiPub[params.username.description="The user name for login"]
/// @apiPub[params.password.required="true"]
/// @apiPub[params.password.description="The password for login in clear text"]
/// @apiPub[params.expiresAfter.output="header"]
/// @apiPub[params.expiresAfter.description="date in UTC when token expires"]
/// @apiPub[params.expiresAfter.name="X-Expires-After"]
/// @apiPub[params.rateLimit.output="header"]
/// @apiPub[params.rateLimit.description="calls per hour allowed by the user"]
/// @apiPub[params.rateLimit.name="X-Rate-Limit"]
Method loginUser(username As %String, password As %String, Output expiresAfter As %DateTime, ByRef rateLimit As %BigInt) As %String [ WebMethod ]
{
    Set expiresAfter = $ZDateTime($Horolog, 3)
    Quit "sessionId 1234"
}

/// Logs out current logged in user session
/// @apiPub[path="/user/logout"]
/// @apiPub[tag="user"]
Method logoutUser() [ WebMethod ]
{
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
        } ],
        "schemas": {
            "Inventory": {
                "type" : "object",
                "additionalProperties" : {
                    "type" : "integer",
                    "format" : "int32"
                }
            }
        }        
    }
}

}
