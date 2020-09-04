/// Methods spec projected using API first approach mode
/// All of the schemas and information needed on XDATA block were imported from Swagger Spec file
/// All of schemas ared automatically parsed by apiPub tool
Class apiPub.samples.apiFirst Extends %RegisteredObject [ ProcedureBlock ]
{

/// Add a new pet to the store.
/// @apiPub[path="/pet"]
/// @apiPub[params.description="Pet object that needs to be added to the store"]
/// @apiPub[params.pet.schema="Pet"]
Method addPet(pet As %Library.DynamicObject) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //your code here
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
/// @apiPub[params.pet.schema="Pet"]
Method updatePet(pet As %Library.DynamicObject) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //your code here
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Finds Pets by status
/// @apiPub[path="/pet/findByStatus"]
/// @apiPub[params.description="Multiple status values can be provided with comma separated strings"]
/// @apiPub[params.status.description="Status values that need to be considered for filter"]
/// @apiPub[params.status.schema.items.enum=["available","pending","sold"]]
/// @apiPub[params.status.schema.default="available"]
/// @apiPub[response.schema={"findByStatus_response":{"type":"array","items":{"$ref":"#/components/schemas/Pet"}}}]
Method findPetsByStatus(status As %String) As %Library.DynamicArray [ WebMethod ]
{
    //your code here
}

/// Finds Pets by tags
/// @apiPub[path="/pet/findByTags"]
/// @apiPub[params.description="Muliple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."]
/// @apiPub[params.tags.description="Tags to filter by"]
/// @apiPub[response.schema={"findByTags_response":{"type":"array","items":{"$ref":"#/components/schemas/Pet"}}}]
/// @apiPub[deprecated="true"]
Method findByTags(tags As %String) As %Library.DynamicArray [ WebMethod ]
{
    //your code here
}

/// Find pet by ID
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[params.petId.description="ID of pet to return"]
/// @apiPub[response.schema="Pet"]
Method getPetById(petId As %Integer) As %Library.DynamicObject [ WebMethod ]
{
    //your code here
}

/// uploads an image
/// @apiPub[path="/pet/{petId}/uploadImage"]
/// @apiPub[params.content.inputType="application/octet-stream"]
Method uploadImage(petId As %Integer, content As %Stream.GlobalBinary) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //your code here
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Updates a pet in the store with form data
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[params.petId.description="ID of pet that needs to be updated"]
/// @apiPub[params.name.description="Updated name of the pet"]
/// @apiPub[params.name.inputType="application/x-www-form-urlencoded"]
/// @apiPub[params.status.description="Updated status of the pet"]
/// @apiPub[params.status.inputType="application/x-www-form-urlencoded"]
Method updatePetWithForm(petId As %Integer, name As %String, status As %String) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //your code here
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Deletes a Pet
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[verb="delete"]
/// @apiPub[params.apikey.inputType="header"]
/// @apiPub[params.apikey.name="api_key"]
/// @apiPub[params.petId.description="Pet id to delete"]
Method deletePet(apikey As %String, petId As %Integer) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //your code here
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
/// @apiPub[response.schema={
///         "getInventory_response":{
///             "type":"object",
///             "additionalProperties":{
///                 "type":"integer",
///                 "format":"int32"
///             }
///         }
/// }]
Method getInventory() As %Library.DynamicObject [ WebMethod ]
{
    //your code here
}

/// Place an order for a pet
/// @apiPub[path="/store/order"]
/// @apiPub[tag="store"]
/// @apiPub[params.description="order placed for purchasing the pet"]
/// @apiPub[params.pOrder.schema="Order"]
Method placeOrder(order As %Library.DynamicObject) As %Status [ WebMethod ]
{
    //your code here
}

/// Find purchase order by ID
/// @apiPub[path="/store/order/{orderId}"]
/// @apiPub[tag="store"]
/// @apiPub[params.description="For valid response try integer IDs with value >\= 1 and <\= 10. Other values will generated exceptions"]
/// @apiPub[params.orderId.description="ID of pet that needs to be fetched"]
/// @apiPub[response.schema="Order"]
Method getOrderById(orderId As %Integer(MINVAL=1,MAXVAL=10)) As %Library.DynamicObject [ WebMethod ]
{
    //your code here
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
        //your code here
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
/// @apiPub[params.user.schema="User"]
Method createUser(user As %Library.DynamicObject) As %Status [ WebMethod ]
{
    //your code here
}

/// Creates list of users with given input array
/// @apiPub[path="/user/createWithArray"]
/// @apiPub[tag="user"]
/// @apiPub[params.description="List of user object"]
/// @apiPub[params.userArray.schema={"UserArray":{"type":"array","items":{"$ref":"#/components/schemas/User"}}}]
Method createUsersWithArrayInput(userArray As %Library.DynamicArray) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //your code here
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
/// @apiPub[params.userArray.schema={"UserArray":{"type":"array","items":{"$ref":"#/components/schemas/User"}}}]
Method createUsersWithListInput(userArray As %Library.DynamicArray) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //your code here
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Update use
/// @apiPub[path="/user/{username}"]
/// @apiPub[verb="put"]
/// @apiPub[tag="user"]
/// @apiPub[params.description="This can only be done by the logged in user."]
/// @apiPub[params.user.schema="User"]
/// @apiPub[params.username.description="name that need to be updated"]
Method updateUser(username As %String, user As %Library.DynamicObject) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        //your code here
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

/// Get user by user name
/// @apiPub[tag="user"]
/// @apiPub[path="/user/{username}"]
/// @apiPub[params.username.description="The name that needs to be fetched"]
/// @apiPub[response.schema="User"]
Method getUserByName(username As %String) As %Library.DynamicObject [ WebMethod ]
{
    //your code here
}

/// Delete user
/// @apiPub[tag="user"]
/// @apiPub[verb="delete"]
/// @apiPub[path="/user/{username}"]
/// @apiPub[params.username.description="The name that needs to be deleted"]
Method deleteUser(username As %String) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {    
        //your code here
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
/// @apiPub[params.XExpiresAfter.outputType="header"]
/// @apiPub[params.XExpiresAfter.description="date in UTC when token expires"]
/// @apiPub[params.XExpiresAfter.name="X-Expires-After"]
/// @apiPub[params.XRateLimit.outputType="header"]
/// @apiPub[params.XRateLimit.description="calls per hour allowed by the user"]
/// @apiPub[params.XRateLimit.name="X-Rate-Limit"]
/// @apiPub[response.outputType="text/plain"]
Method loginUser(username As %String, password As %String, Output XExpiresAfter As %DateTime, Output XRateLimit As %BigInt) As %String [ WebMethod ]
{
       //your code here
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
            "title" : "IRIS Petstore (API First)",
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
        "schemas" : {
            "Order" : {
                "type" : "object",
                "properties" : {
                "id" : {
                    "type" : "integer",
                    "format" : "int64"
                },
                "petId" : {
                    "type" : "integer",
                    "format" : "int64"
                },
                "quantity" : {
                    "type" : "integer",
                    "format" : "int32"
                },
                "shipDate" : {
                    "type" : "string",
                    "format" : "date-time"
                },
                "status" : {
                    "type" : "string",
                    "description" : "Order Status",
                    "enum" : [ "placed", "approved", "delivered" ]
                },
                "complete" : {
                    "type" : "boolean",
                    "default" : false
                }
                },
                "xml" : {
                "name" : "Order"
                }
            },
            "Category" : {
                "type" : "object",
                "properties" : {
                "id" : {
                    "type" : "integer",
                    "format" : "int64"
                },
                "name" : {
                    "type" : "string"
                }
                },
                "xml" : {
                "name" : "Category"
                }
            },
            "User" : {
                "type" : "object",
                "properties" : {
                "id" : {
                    "type" : "integer",
                    "format" : "int64"
                },
                "username" : {
                    "type" : "string"
                },
                "firstName" : {
                    "type" : "string"
                },
                "lastName" : {
                    "type" : "string"
                },
                "email" : {
                    "type" : "string"
                },
                "password" : {
                    "type" : "string"
                },
                "phone" : {
                    "type" : "string"
                },
                "userStatus" : {
                    "type" : "integer",
                    "format" : "int32",
                    "description" : "User Status"
                }
                },
                "xml" : {
                "name" : "User"
                }
            },
            "Tag" : {
                "type" : "object",
                "properties" : {
                "id" : {
                    "type" : "integer",
                    "format" : "int64"
                },
                "name" : {
                    "type" : "string"
                }
                },
                "xml" : {
                "name" : "Tag"
                }
            },
            "Pet" : {
                "type" : "object",
                "required" : [ "name", "photoUrls" ],
                "properties" : {
                "id" : {
                    "type" : "integer",
                    "format" : "int64"
                },
                "category" : {
                    "$ref" : "#/components/schemas/Category"
                },
                "name" : {
                    "type" : "string",
                    "example" : "doggie"
                },
                "photoUrls" : {
                    "type" : "array",
                    "xml" : {
                    "name" : "photoUrl",
                    "wrapped" : true
                    },
                    "items" : {
                    "type" : "string"
                    }
                },
                "tags" : {
                    "type" : "array",
                    "xml" : {
                    "name" : "tag",
                    "wrapped" : true
                    },
                    "items" : {
                    "$ref" : "#/components/schemas/Tag"
                    }
                },
                "status" : {
                    "type" : "string",
                    "description" : "pet status in the store",
                    "enum" : [ "available", "pending", "sold" ]
                }
                },
                "xml" : {
                "name" : "Pet"
                }
            },
            "ApiResponse" : {
                "type" : "object",
                "properties" : {
                "code" : {
                    "type" : "integer",
                    "format" : "int32"
                },
                "type" : {
                    "type" : "string"
                },
                "message" : {
                    "type" : "string"
                }
                }
            }
            },
            "requestBodies" : {
            "Pet" : {
                "content" : {
                "application/json" : {
                    "schema" : {
                    "$ref" : "#/components/schemas/Pet"
                    }
                },
                "application/xml" : {
                    "schema" : {
                    "$ref" : "#/components/schemas/Pet"
                    }
                }
                },
                "description" : "Pet object that needs to be added to the store",
                "required" : true
            },
            "UserArray" : {
                "content" : {
                "application/json" : {
                    "schema" : {
                    "type" : "array",
                    "items" : {
                        "$ref" : "#/components/schemas/User"
                    }
                    }
                }
                },
                "description" : "List of user object",
                "required" : true
            }
        }
    }
}

}
