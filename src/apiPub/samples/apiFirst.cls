/// Methods spec projected using API first approach mode (apiPub wizard)
/// All of the schemas and information needed on XDATA block were imported from Swagger Spec file
/// All of schemas ared automatically parsed by apiPub tool
Class apiPub.samples.apiFirst Extends %RegisteredObject [ ProcedureBlock ]
{

/// Add a new pet to the store
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet"]
/// @apiPub[params.description="Pet object that needs to be added to the store"]
/// @apiPub[params.payload.schema="Pet"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[statusCodes=[{"code":"405","description":"Invalid input"}]]
ClassMethod addPet(payload As %DynamicObject) As %Status [ WebMethod ]
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
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet"]
/// @apiPub[verb="put"]
/// @apiPub[params.description="Pet object that needs to be added to the store"]
/// @apiPub[params.payload.schema="Pet"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid ID supplied"},{"code":"404","description":"Pet not found"},{"code":"405","description":"Validation exception"}]]
ClassMethod updatePet(payload As %DynamicObject) As %Status [ WebMethod ]
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
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/findByStatus"]
/// @apiPub[params.description="Multiple status values can be provided with comma separated strings"]
/// @apiPub[params.status.required="1"]
/// @apiPub[params.status.description="Status values that need to be considered for filter"]
/// @apiPub[params.status.schema.items.enum=["available","pending","sold"]]
/// @apiPub[params.status.schema.items.default="available"]
/// @apiPub[response.schema="findPetsByStatus_response"]
/// @apiPub[successfulCode="201"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid status value"}]]
ClassMethod findPetsByStatus(status As %String) As %DynamicArray [ WebMethod ]
{
	//your code here
}

/// Finds Pets by tags
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/findByTags"]
/// @apiPub[params.description="Muliple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."]
/// @apiPub[params.tags.required="1"]
/// @apiPub[params.tags.description="Tags to filter by"]
/// @apiPub[response.schema="findPetsByTags_response"]
/// @apiPub[successfulCode="200"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid tag value"}]]
ClassMethod findPetsByTags(tags As %String) As %DynamicArray [ WebMethod ]
{
	//your code here
}

/// Find pet by ID
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[params.description="Returns a single pet"]
/// @apiPub[params.petId.required="1"]
/// @apiPub[params.petId.description="ID of pet to return"]
/// @apiPub[response.schema="Pet"]
/// @apiPub[successfulCode="200"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid ID supplied"},{"code":"404","description":"Pet not found"}]]
ClassMethod getPetById(petId As %BigInt) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Updates a pet in the store with form data
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[params.petId.required="1"]
/// @apiPub[params.petId.description="ID of pet that needs to be updated"]
/// @apiPub[params.name.description="Updated name of the pet"]
/// @apiPub[params.name.inputType="application/x-www-form-urlencoded"]
/// @apiPub[params.status.description="Updated status of the pet"]
/// @apiPub[params.status.inputType="application/x-www-form-urlencoded"]
/// @apiPub[statusCodes=[{"code":"405","description":"Invalid input"}]]
ClassMethod updatePetWithForm(petId As %BigInt, name As %String, status As %String) As %Status [ WebMethod ]
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

/// Deletes a pet
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[verb="delete"]
/// @apiPub[params.apikey.name="api_key"]
/// @apiPub[params.apikey.required="0"]
/// @apiPub[params.apikey.inputType="header"]
/// @apiPub[params.petId.required="1"]
/// @apiPub[params.petId.description="Pet id to delete"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid ID supplied"},{"code":"404","description":"Pet not found"}]]
ClassMethod deletePet(apikey As %String, petId As %BigInt) As %Status [ WebMethod ]
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

/// uploads an image
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/{petId}/uploadImage"]
/// @apiPub[params.petId.required="1"]
/// @apiPub[params.petId.description="ID of pet to update"]
/// @apiPub[params.payload.inputType="application/octet-stream"]
/// @apiPub[response.schema="ApiResponse"]
/// @apiPub[successfulCode="200"]
ClassMethod uploadFile(petId As %BigInt, payload As %Stream.GlobalBinary) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Returns pet inventories by status
/// @apiPub[tag="store"]
/// @apiPub[path="/store/inventory"]
/// @apiPub[params.description="Returns a map of status codes to quantities"]
/// @apiPub[response.schema="getInventory_response"]
/// @apiPub[successfulCode="200"]
ClassMethod getInventory() As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Place an order for a pet
/// @apiPub[tag="store"]
/// @apiPub[path="/store/order"]
/// @apiPub[params.payload.schema="Order"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[response.schema="Order"]
/// @apiPub[successfulCode="200"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid Order"}]]
ClassMethod placeOrder(payload As %DynamicObject) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Find purchase order by ID
/// @apiPub[tag="store"]
/// @apiPub[path="/store/order/{orderId}"]
/// @apiPub[params.description="For valid response try integer IDs with value >\= 1 and <\= 10. Other values will generated exceptions"]
/// @apiPub[params.orderId.required="1"]
/// @apiPub[params.orderId.description="ID of pet that needs to be fetched"]
/// @apiPub[response.schema="Order"]
/// @apiPub[successfulCode="200"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid ID supplied"},{"code":"404","description":"Order not found"}]]
ClassMethod getOrderById(orderId As %BigInt) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Delete purchase order by ID
/// @apiPub[tag="store"]
/// @apiPub[path="/store/order/{orderId}"]
/// @apiPub[verb="delete"]
/// @apiPub[params.description="For valid response try integer IDs with positive integer value. Negative or non-integer values will generate API errors"]
/// @apiPub[params.orderId.required="1"]
/// @apiPub[params.orderId.description="ID of the order that needs to be deleted"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid ID supplied"},{"code":"404","description":"Order not found"}]]
ClassMethod deleteOrder(orderId As %BigInt) As %Status [ WebMethod ]
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
/// @apiPub[tag="user"]
/// @apiPub[path="/user"]
/// @apiPub[params.description="This can only be done by the logged in user."]
/// @apiPub[params.payload.schema="User"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[successfulCode="0"]
ClassMethod createUser(payload As %DynamicObject) As %Status [ WebMethod ]
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
/// @apiPub[tag="user"]
/// @apiPub[path="/user/createWithArray"]
/// @apiPub[params.description="List of user object"]
/// @apiPub[params.payload.schema="createUsersWithArrayInput_request"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[successfulCode="0"]
ClassMethod createUsersWithArrayInput(payload As %DynamicArray) As %Status [ WebMethod ]
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
/// @apiPub[tag="user"]
/// @apiPub[path="/user/createWithList"]
/// @apiPub[params.description="List of user object"]
/// @apiPub[params.payload.schema="createUsersWithListInput_request"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[successfulCode="0"]
ClassMethod createUsersWithListInput(payload As %DynamicArray) As %Status [ WebMethod ]
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
/// @apiPub[params.username.required="1"]
/// @apiPub[params.username.description="The user name for login"]
/// @apiPub[params.password.required="1"]
/// @apiPub[params.password.description="The password for login in clear text"]
/// @apiPub[params.XRateLimit.name="X-Rate-Limit"]
/// @apiPub[params.XRateLimit.description="calls per hour allowed by the user"]
/// @apiPub[params.XRateLimit.outputType="headers"]
/// @apiPub[params.XExpiresAfter.name="X-Expires-After"]
/// @apiPub[params.XExpiresAfter.description="date in UTC when token expires"]
/// @apiPub[params.XExpiresAfter.outputType="headers"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[response.schema="loginUser_response"]
/// @apiPub[successfulCode="200"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid username/password supplied"}]]
ClassMethod loginUser(username As %String, password As %String, Output XRateLimit As %Integer, Output XExpiresAfter As %DateTime) As %String [ WebMethod ]
{
	//your code here
}

/// Logs out current logged in user session
/// @apiPub[tag="user"]
/// @apiPub[path="/user/logout"]
/// @apiPub[successfulCode="0"]
ClassMethod logoutUser() As %Status [ WebMethod ]
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
/// @apiPub[params.username.required="1"]
/// @apiPub[params.username.description="The name that needs to be fetched. Use user1 for testing."]
/// @apiPub[response.schema="User"]
/// @apiPub[successfulCode="200"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid username supplied"},{"code":"404","description":"User not found"}]]
ClassMethod getUserByName(username As %String) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Updated user
/// @apiPub[tag="user"]
/// @apiPub[path="/user/{username}"]
/// @apiPub[verb="put"]
/// @apiPub[params.description="This can only be done by the logged in user."]
/// @apiPub[params.username.required="1"]
/// @apiPub[params.username.description="name that need to be updated"]
/// @apiPub[params.payload.schema="User"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid user supplied"},{"code":"404","description":"User not found"}]]
ClassMethod updateUser(username As %String, payload As %DynamicObject) As %Status [ WebMethod ]
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

/// Delete user
/// @apiPub[tag="user"]
/// @apiPub[path="/user/{username}"]
/// @apiPub[verb="delete"]
/// @apiPub[params.description="This can only be done by the logged in user."]
/// @apiPub[params.username.required="1"]
/// @apiPub[params.username.description="The name that needs to be deleted"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid username supplied"},{"code":"404","description":"User not found"}]]
ClassMethod deleteUser(username As %String) As %Status [ WebMethod ]
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

XData apiPub [ MimeType = application/json ]
{
{
  "info":{
    "description":"This is a sample Petstore server.  You can find\nout more about Swagger at\n[http://swagger.io](http://swagger.io) or on\n[irc.freenode.net, #swagger](http://swagger.io/irc/).\n",
    "version":"1.0.0",
    "title":"Swagger Petstore",
    "termsOfService":"http://swagger.io/terms/",
    "contact":{
      "email":"apiteam@swagger.io"
    },
    "license":{
      "name":"Apache 2.0",
      "url":"http://www.apache.org/licenses/LICENSE-2.0.html"
    }
  },
  "tags":[
    {
      "name":"pet",
      "description":"Everything about your Pets",
      "externalDocs":{
        "description":"Find out more",
        "url":"http://swagger.io"
      }
    },
    {
      "name":"store",
      "description":"Access to Petstore orders"
    },
    {
      "name":"user",
      "description":"Operations about user",
      "externalDocs":{
        "description":"Find out more about our store",
        "url":"http://swagger.io"
      }
    }
  ],
  "schemas":{
    "findPetsByStatus_response":{
      "type":"array",
      "items":{
        "$ref":"#/components/schemas/Pet"
      }
    },
    "findPetsByTags_response":{
      "type":"array",
      "items":{
        "$ref":"#/components/schemas/Pet"
      }
    },
    "getInventory_response":{
      "type":"object",
      "additionalProperties":{
        "type":"integer",
        "format":"int32"
      }
    },
    "createUsersWithArrayInput_request":{
      "type":"array",
      "items":{
        "$ref":"#/components/schemas/User"
      }
    },
    "createUsersWithListInput_request":{
      "type":"array",
      "items":{
        "$ref":"#/components/schemas/User"
      }
    },
    "loginUser_response":{
      "type":"string"
    },
    "Order":{
      "type":"object",
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64"
        },
        "petId":{
          "type":"integer",
          "format":"int64"
        },
        "quantity":{
          "type":"integer",
          "format":"int32"
        },
        "shipDate":{
          "type":"string",
          "format":"date-time"
        },
        "status":{
          "type":"string",
          "description":"Order Status",
          "enum":[
            "placed",
            "approved",
            "delivered"
          ]
        },
        "complete":{
          "type":"boolean",
          "default":"0"
        }
      },
      "xml":{
        "name":"Order"
      }
    },
    "Category":{
      "type":"object",
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64"
        },
        "name":{
          "type":"string"
        }
      },
      "xml":{
        "name":"Category"
      }
    },
    "User":{
      "type":"object",
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64"
        },
        "username":{
          "type":"string"
        },
        "firstName":{
          "type":"string"
        },
        "lastName":{
          "type":"string"
        },
        "email":{
          "type":"string"
        },
        "password":{
          "type":"string"
        },
        "phone":{
          "type":"string"
        },
        "userStatus":{
          "type":"integer",
          "format":"int32",
          "description":"User Status"
        }
      },
      "xml":{
        "name":"User"
      }
    },
    "Tag":{
      "type":"object",
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64"
        },
        "name":{
          "type":"string"
        }
      },
      "xml":{
        "name":"Tag"
      }
    },
    "Pet":{
      "type":"object",
      "required":[
        "name",
        "photoUrls"
      ],
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64"
        },
        "category":{
          "$ref":"#/components/schemas/Category"
        },
        "name":{
          "type":"string",
          "example":"doggie"
        },
        "photoUrls":{
          "type":"array",
          "xml":{
            "name":"photoUrl",
            "wrapped":"1"
          },
          "items":{
            "type":"string"
          }
        },
        "tags":{
          "type":"array",
          "xml":{
            "name":"tag",
            "wrapped":"1"
          },
          "items":{
            "$ref":"#/components/schemas/Tag"
          }
        },
        "status":{
          "type":"string",
          "description":"pet status in the store",
          "enum":[
            "available",
            "pending",
            "sold"
          ]
        }
      },
      "xml":{
        "name":"Pet"
      }
    },
    "ApiResponse":{
      "type":"object",
      "properties":{
        "code":{
          "type":"integer",
          "format":"int32"
        },
        "type":{
          "type":"string"
        },
        "message":{
          "type":"string"
        }
      }
    }
  }
}
}

}
