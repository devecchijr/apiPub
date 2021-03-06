Class apiPub.samples.apiBeforeCustom Extends %RegisteredObject [ ProcedureBlock ]
{

/// Add a new pet to the store
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
            Set tExPet.category=pPet.category
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
Method getPetById(pId As %Integer) As apiPub.samples.Pet [ WebMethod ]
{
    Set tPet = ##class(apiPub.samples.Pet).idIDXOpen(pId)
    If '$IsObject(tPet) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
    }
    Return tPet
}

/// uploads an image
Method uploadImage(pId As %Integer, pContent As %Stream.GlobalBinary) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        Set tPet = ##class(apiPub.samples.Pet).idIDXOpen(pId)
        If '$IsObject(tPet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) doesn't Exist"))
        }
        Set tFile = ##class(%Stream.FileBinary).%New()
        Set tSC = tFile.FilenameSet("/users/claudiodevecchi/downloads/petImage"_pId_".jpg")
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tSC = tFile.CopyFromAndSave(pContent)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tUrl = "file:///Users/claudiodevecchi/Downloads/petImage"_pId_".jpg"
	    Set photoUrl = ##class(%ListOfDataTypes).%New()
        Do photoUrl.Insert(tUrl)
        Set tPet.photoUrls=photoUrl
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tSC = tPet.%Save()
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Updates a pet in the store with form data
Method updatePetForm(petId As %Integer, name As %String, status As %String) As %Status [ WebMethod ]
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
Method placeOrder(pOrder As apiPub.samples.Order) As %Status [ WebMethod ]
{
    If $IsObject(##class(apiPub.samples.Order).idIDXOpen(pOrder.id)) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Order (id) Already Exists"))
    }
    If '$IsObject(pOrder.pet) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Invalid Pet (id)"))
    Quit pOrder.%Save()
}

/// Find purchase order by ID
Method getOrderById(orderId As %Integer(MINVAL=1,MAXVAL=10)) As apiPub.samples.Order [ WebMethod ]
{
    Set order = ##class(apiPub.samples.Order).idIDXOpen(orderId)
    If '$IsObject(order) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> Order (id) doesn't Exist"))
    }
    Quit order
}

/// Delete purchase order by ID
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
Method getUserByName(pUserName As %String) As apiPub.samples.User [ WebMethod ]
{
    Set tUser = ##class(apiPub.samples.User).usernameIDXOpen(pUserName)
    If '$IsObject(tUser) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "username doesn't Exist"))
    }
    Return tUser
}

/// Delete user
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
Method loginUser(username As %String, password As %String, Output expiresAfter As %DateTime, Output rateLimit As %BigInt) As %String [ WebMethod ]
{
    Quit $Horolog
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
    }
}

}
