Class apiPub.samples.api Extends %RegisteredObject [ ProcedureBlock ]
{

Parameter ImagePath = "/tmp";

/// Add a new pet to the store
/// @apiPub[path="/pet"]
/// @apiPub[params.description="Pet object that needs to be added to the store"]
Method addPet(pPet As apiPub.samples.Pet) As apiPub.samples.Pet [ WebMethod ]
{
    Do ..validatePet(pPet,0)
    Do pPet.%Save()
    Quit pPet
}

/// Update an existing pet
/// @apiPub[path="/pet"]
/// @apiPub[params.description="Pet object that needs to be added/updated to the store"]
/// @apiPub[verb="put"]
Method updatePet(pPet As apiPub.samples.Pet) As apiPub.samples.Pet [ WebMethod ]
{
    Do ..validatePet(pPet,1)
    Do pPet.%Save()
    Quit pPet
}

Method validatePet(pPet As apiPub.samples.Pet, update As %Boolean = 0)
{
    If (update) {
        If pPet.%Id()="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<404> Pet (id) doesn't Exist"))
        //Removes not updated tags (IsModified()=0)
        For i=1:1:pPet.tags.Count() {
            Set tTag=pPet.tags.GetAt(i)
            If tTag.%Id()'="",tTag.%IsModified()=0 Do pPet.tags.RemoveAt(i)
        }
    } Else {
        If pPet.%Id()'="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<404> Pet (id) already exists"))
    }
}

/// Deletes a Pet
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[verb="delete"]
/// @apiPub[params.id.description="Pet id to delete"]
/// @apiPub[params.id.name="petId"]
/// @apiPub[params.apikey.inputType="header"]
/// @apiPub[params.apikey.name="api_key"]
Method deletePet(apikey As %String, id As %String) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set pPet = ##class(apiPub.samples.Pet).%OpenId(id)
        If '$IsObject(pPet) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
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

/// Updates a pet in the store with form data
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[operationId="updatePetWithForm"]
/// @apiPub[params.petId.description="ID of pet that needs to be updated"]
/// @apiPub[params.name.description="Updated name of the pet"]
/// @apiPub[params.name.inputType="application/x-www-form-urlencoded"]
/// @apiPub[params.status.description="Updated status of the pet"]
/// @apiPub[params.status.inputType="application/x-www-form-urlencoded"]
Method updatePetForm(petId As %String, name As %String, status As %String) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set pet = ##class(apiPub.samples.Pet).%OpenId(petId)
        If '$IsObject(pet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
        }
        Set pet.name = name
        Set pet.status = status
        Set tSC = pet.%Save()
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Finds Pets by status using pagination
/// @apiPub[path="/pet/findByStatus"]
/// @apiPub[params.description="Multiple status values can be provided with comma separated strings"]
/// @apiPub[params.pStatus.description="Status values that need to be considered for filter"]
/// @apiPub[params.pStatus.schema.items.enum=["available","pending","sold"]]
/// @apiPub[params.pStatus.schema.default="available"]
/// @apiPub[response.name="results"]
Method findByStatus(pStatus As %String, page As %String, pagesize As %String, Output maxResults As %Numeric = 0) As %ListOfObjects(ELEMENTTYPE="apiPub.samples.Pet") [ WebMethod ]
{
	Set sql = "SELECT ID FROM apiPub_samples.Pet WHERE status in ('"_$Replace(pStatus,",","','")_"')"
	Set stat = ##class(%SQL.Statement).%New()
	Set Status = stat.%Prepare(sql)
	Set rset = stat.%Execute()
    Set tPage=1
    Set ret = ##class(%ListOfObjects).%New()
	While rset.%Next() {
        set tPush=1
        Set maxResults=maxResults+1
        If +page'=0,+pagesize'=0 {
            Set tPush=(page=tPage)
            If maxResults#pagesize=0 Set tPage=tPage+1
        }
        If (tPush) Do ret.Insert(##class(apiPub.samples.Pet).%OpenId(rset.ID))
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
	Set sql = "SELECT ID FROM apiPub_samples.Pet WHERE ID1 in (SELECT pet FROM apiPub_samples.Tag WHERE name in ("_tags_"))"
    Set stat = ##class(%SQL.Statement).%New()
	Set Status = stat.%Prepare(sql)
	Set rset = stat.%Execute()
    Set ret = ##class(%ListOfObjects).%New()
	While rset.%Next() {
        Do ret.Insert(##class(apiPub.samples.Pet).%OpenId(rset.ID))
	}
    Return ret
}

/// Find pet by ID
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[params.pId.description="ID of pet to return"]
/// @apiPub[params.pId.name="petId"]
/// @apiPub[statusCodes=[
///     {"code":"400","description":"Invalid ID supplied"}
///     ,{"code":"404","description":"Pet not found"}]
/// ]
Method getPetById(pId As %String) As apiPub.samples.Pet [ WebMethod ]
{
    //If not numeric
    If pId'=+pId {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> Invalid ID supplied"))}
    Set tPet = ##class(apiPub.samples.Pet).%OpenId(pId)
    If '$IsObject(tPet) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<404> Pet not found"))
    Return tPet
}

/// uploads an image
/// @apiPub[path="/pet/{petId}/uploadImage"]
/// @apiPub[params.pId.name="petId"]
/// @apiPub[params.pContent.inputType="application/octet-stream"]
Method uploadImage(pId As %String, pContent As %Stream.GlobalBinary, httpReq As apiPub.service.message) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set tPet = ##class(apiPub.samples.Pet).%OpenId(pId)
        If '$IsObject(tPet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
        }
        If pContent.SizeGet()>0 {
            Set tFilename="petImage"_pId_"s"_$P($NOW(),".",*)_"."_..getMimeType(pContent)
            Set tSC = ..saveFile(pContent,..#ImagePath_"/"_tFilename)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tUrl = "http://"_httpReq.GetHeaders("HTTP_HOST")_$Piece(httpReq.GetHeaders("REQUEST_URI"),"/",1,2)_"/file/"_tFilename
            If tPet.photoUrls.Count()=0 {
                Set tPet.photoUrls=##class(%ListOfDataTypes).%New()
            }
            If tPet.photoUrls.Find(tUrl,1)="" Do tPet.photoUrls.Insert(tUrl)
            Set tSC = tPet.%Save()
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        }
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// show pet images
/// @apiPub[path="/pet/images/{petId}"]
/// @apiPub[response.outputType="text/html"]
Method showPetImages(petId As %String, httpReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    Set tPet = ##class(apiPub.samples.Pet).%OpenId(petId)
    If '$IsObject(tPet) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<404> Pet not found"))
    Set tOutput = ##class(%Stream.GlobalCharacter).%New()
    For i=1:1:tPet.photoUrls.Count() {
        Set tFileName=$Piece(tPet.photoUrls.GetAt(i),"/",*)
        Set tImageStream=..showImage(tFileName,httpReq).Read()
        Do tOutput.Write(tImageStream)
    }
    Quit tOutput
}

/// upload multiple files
/// - param1 and param2 are examples that is possible to work with other types all togheter
/// @apiPub[params.param2.inputType="multipart/form-data"]
/// @apiPub[params.pImage1.inputType="multipart/form-data"]
/// @apiPub[params.pImage2.inputType="multipart/form-data"]
/// @apiPub[response.outputType="text/html"] 
Method uploadMultipleFiles(param1 As %String, param2 As %String, pImage1 As %Stream.GlobalBinary, pImage2 As %Stream.GlobalBinary) As %String [ WebMethod ]
{
    Set tFileContent1=##class(%Stream.FileBinary).%New()
    Set tSC=tFileContent1.LinkToFile(..#ImagePath_"/image1.png")
    Do tFileContent1.CopyFrom(pImage1)
    Do tFileContent1.%Save()

    Set tFileContent2=##class(%Stream.FileBinary).%New()
    Set tSC=tFileContent2.LinkToFile(..#ImagePath_"/image2.jpeg")
    Do tFileContent2.CopyFrom(pImage2)
    Do tFileContent2.%Save()

    Quit "images uploaded"
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
    If pOrder.%Id()'="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Order (id) Already Exists"))
    If '$IsObject(pOrder.petId) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Invalid petId"))
    Quit pOrder.%Save()
}

/// Find purchase order by ID
/// @apiPub[path="/store/order/{orderId}"]
/// @apiPub[tag="store"]
/// @apiPub[params.description="For valid response try integer IDs with value >\= 1 and <\= 10. Other values will generated exceptions"]
/// @apiPub[params.orderId.description="ID of the order that needs to be fetched"]
Method getOrderById(orderId As %Integer(MINVAL=1,MAXVAL=10)) As apiPub.samples.Order [ WebMethod ]
{
    Set order = ##class(apiPub.samples.Order).%OpenId(orderId)
    If '$IsObject(order) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> Order (id) doesn't Exist"))
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
        Set order = ##class(apiPub.samples.Order).%OpenId(orderId)
        If '$IsObject(order) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Order (id) doesn't Exist"))
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
/// @apiPub[successfulCode="201"]
Method createUser(pUser As apiPub.samples.User) As apiPub.samples.User [ WebMethod ]
{
    If pUser.%Id()'="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User (id) Already Exists"))
    Set tSC = pUser.%Save()
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    Quit pUser
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
            Set tExUser = ##class(apiPub.samples.User).usernameIDXOpen(tUser.username)
            If $IsObject(tExUser) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User ("_tExUser.username_") Already Exists"))
        }
        //Save
        For i=1: 1: pArrayOfUsers.Count() {
            Set tUser=pArrayOfUsers.GetAt(i)
            Set tSC = tUser.%Save()
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
            Set tExUser = ##class(apiPub.samples.User).usernameIDXOpen(tUser.username)
            If $IsObject(tExUser) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User ("_tExUser.username_") Already Exists"))
        }
        //Save
        For i=1: 1: pListOfUsers.Count() {
            Set tUser=pListOfUsers.GetAt(i)
            Set tSC = tUser.%Save()
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
        If pUser.%Id()'="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User Id can't be informed"))
        Set tUser = ##class(apiPub.samples.User).usernameIDXOpen(pUserName)
        If '$IsObject(tUser) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "User (username) doesn't Exist"))
        Set tSC = ..saveUser(tUser.%Id(),pUser)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Update user using OAS schema
/// @apiPub[path="/user"]
/// @apiPub[verb="put"]
/// @apiPub[tag="user"]
/// @apiPub[params.description="This can only be done by the logged in user."]
/// @apiPub[params.user.schema="User"]
Method updateUserUsingOASSchema(username As %String, user As %Library.DynamicObject) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set tSC = ##class(apiPub.core.converter).JSONToObj(user, "apiPub.samples.User", .pUser)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tSC = ..updateUser(username,pUser)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

Method saveUser(id As %String, pUser As apiPub.samples.User) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$IsObject(pUser) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> Invalid Object"))
        }
        Set tExUser = ##class(apiPub.samples.User).%OpenId(id)
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
/// @apiPub[params.expiresAfter.outputType="header"]
/// @apiPub[params.expiresAfter.description="date in UTC when token expires"]
/// @apiPub[params.expiresAfter.name="X-Expires-After"]
/// @apiPub[params.rateLimit.outputType="header"]
/// @apiPub[params.rateLimit.description="calls per hour allowed by the user"]
/// @apiPub[params.rateLimit.name="X-Rate-Limit"]
/// @apiPub[response.outputType="text/plain"]
Method loginUser(username As %String, password As %String, Output expiresAfter As %DateTime, Output rateLimit As %BigInt) As %String [ WebMethod ]
{
    Set expiresAfter=$ZDT($H,3)
    Set rateLimit=5
    Quit $Horolog
}

/// show an image
/// @apiPub[path="/image/{fileName}"]
/// @apiPub[response.outputType="text/html"]
Method showImage(fileName As %String, httpReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    //only validate a file
    Set tFileStream=..getFile(fileName)
    Set type=..getMimeType(tFileStream)
    Set tOutput=##class(%Stream.GlobalCharacter).%New()
    Do tOutput.Write("<img alt="""" src=""http://"_httpReq.GetHeaders("HTTP_HOST")_$Piece(httpReq.GetHeaders("REQUEST_URI"),"/",1,2)_"/file/"_fileName_"""/>")
    Quit tOutput
}

/// get a file or image
/// @apiPub[path="/file/{fileName}"]
/// @apiPub[response.outputType="application/octet-stream"]
Method getFile(fileName As %String) As %Stream.FileBinary [ WebMethod ]
{
    Set tFileName = ..#ImagePath_"/"_fileName
    Set tFileStream=##class(%Stream.FileBinary).%New()
    Set tSC=tFileStream.LinkToFile(tFileName)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    If tFileStream.SizeGet()=0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<404> file doesn't exist"))
    Quit tFileStream
}

ClassMethod getMimeType(image As %Stream.GlobalBinary) As %String
{
    Do image.Rewind()
    //first characters
    Set tstr = $E(image.ReadLine(),1,16)
    Do image.Rewind()
    Set fc = $SYSTEM.Encryption.Base64Encode(tstr)
    If fc["iVBOR" Quit "png"
    If fc["/9j/4AAQ" Quit "jpeg"
    If fc["R0lGODlh" Quit "gif"
    If fc["SUkq" Quit "tiff"
    If (fc["UklGR")||($E(fc,1,3)["Qk2") Quit "bmp"
    Quit ""
}

ClassMethod saveFile(image As %Stream.GlobalBinary, fileName As %String) As %Status
{
    Set timg=##class(%Stream.FileBinary).%New()
    Set tSC=timg.LinkToFile(fileName)
    Do timg.CopyFrom(image)
    Do timg.%Save()
    Quit $$$OK
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
            "title" : "IRIS Petstore (Dev First)",
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
            },
            "User": {
                "type": "object",
                "required": [
                    "username"
                ],
                "properties": {
                    "id": {
                        "type": "integer",
                        "format": "int64"
                    },
                    "username": {
                        "type": "string"
                    },
                    "firstName": {
                        "type": "string"
                    },
                    "lastName": {
                        "type": "string"
                    },
                    "email": {
                        "type": "string"
                    },
                    "password": {
                        "type": "string"
                    },
                    "phone": {
                        "type": "string"
                    },
                    "userStatus": {
                        "type": "integer",
                        "description": "(short) User Status"
                    }
                }
            }            
        }
    }
}

}
