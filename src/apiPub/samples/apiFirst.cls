/// Methods spec projected using API first approach mode (apiPub wizard)
/// All of the schemas and information needed on XDATA block were imported from Swagger Spec file
/// All of schemas ared automatically parsed by apiPub framework
Class apiPub.samples.apiFirst Extends %RegisteredObject [ ProcedureBlock ]
{

/// Add a new pet to the store
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet"]
/// @apiPub[description="Add a new pet to the store"]
/// @apiPub[params.payload.schema="Pet"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[response.schema="Pet"]
/// @apiPub[statusCodes=[{"code":"405","description":"Invalid input"}]]
ClassMethod addPet(payload As %DynamicObject) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Update an existing pet
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet"]
/// @apiPub[verb="put"]
/// @apiPub[description="Update an existing pet by Id"]
/// @apiPub[params.payload.schema="Pet"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[response.schema="Pet"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid ID supplied"},{"code":"404","description":"Pet not found"},{"code":"405","description":"Validation exception"}]]
ClassMethod updatePet(payload As %DynamicObject) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Finds Pets by status
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/findByStatus"]
/// @apiPub[description="Multiple status values can be provided with comma separated strings"]
/// @apiPub[params.status.description="Status values that need to be considered for filter"]
/// @apiPub[params.status.schema.items.enum=["available","pending","sold"]]
/// @apiPub[params.status.schema.items.default="available"]
/// @apiPub[response.schema="findPetsByStatus_response"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid status value"}]]
ClassMethod findPetsByStatus(status As %String) As %DynamicArray [ WebMethod ]
{
	//your code here
}

/// Finds Pets by tags
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/findByTags"]
/// @apiPub[description="Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."]
/// @apiPub[params.tags.description="Tags to filter by"]
/// @apiPub[response.schema="findPetsByTags_response"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid tag value"}]]
ClassMethod findPetsByTags(tags As %DynamicArray) As %DynamicArray [ WebMethod ]
{
	//your code here
}

/// Find pet by ID
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[description="Returns a single pet"]
/// @apiPub[params.petId.description="ID of pet to return"]
/// @apiPub[response.schema="Pet"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid ID supplied"},{"code":"404","description":"Pet not found"}]]
ClassMethod getPetById(petId As %BigInt) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Updates a pet in the store with form data
/// @apiPub[tag="pet"]
/// @apiPub[path="/pet/{petId}"]
/// @apiPub[verb="post"]
/// @apiPub[params.petId.description="ID of pet that needs to be updated"]
/// @apiPub[params.name.description="Name of pet that needs to be updated"]
/// @apiPub[params.status.description="Status of pet that needs to be updated"]
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
/// @apiPub[params.apikey.inputType="header"]
/// @apiPub[params.petId.description="Pet id to delete"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid pet value"}]]
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
/// @apiPub[params.petId.description="ID of pet to update"]
/// @apiPub[params.additionalMetadata.description="Additional Metadata"]
/// @apiPub[params.payload.inputType="application/octet-stream"]
/// @apiPub[charset="ISO-8859-1"]
/// @apiPub[response.schema="ApiResponse"]
ClassMethod uploadFile(petId As %BigInt, additionalMetadata As %String, payload As %Stream.GlobalBinary) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Returns pet inventories by status
/// @apiPub[tag="store"]
/// @apiPub[path="/store/inventory"]
/// @apiPub[description="Returns a map of status codes to quantities"]
/// @apiPub[response.schema="getInventory_response"]
ClassMethod getInventory() As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Place an order for a pet
/// @apiPub[tag="store"]
/// @apiPub[path="/store/order"]
/// @apiPub[description="Place a new order in the store"]
/// @apiPub[params.payload.schema="Order"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[response.schema="Order"]
/// @apiPub[statusCodes=[{"code":"405","description":"Invalid input"}]]
ClassMethod placeOrder(payload As %DynamicObject) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Find purchase order by ID
/// @apiPub[tag="store"]
/// @apiPub[path="/store/order/{orderId}"]
/// @apiPub[description="For valid response try integer IDs with value <\= 5 or > 10. Other values will generate exceptions."]
/// @apiPub[params.orderId.description="ID of order that needs to be fetched"]
/// @apiPub[response.schema="Order"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid ID supplied"},{"code":"404","description":"Order not found"}]]
ClassMethod getOrderById(orderId As %BigInt) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Delete purchase order by ID
/// @apiPub[tag="store"]
/// @apiPub[path="/store/order/{orderId}"]
/// @apiPub[verb="delete"]
/// @apiPub[description="For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"]
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
/// @apiPub[description="This can only be done by the logged in user."]
/// @apiPub[params.payload.schema="User"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[response.schema="User"]
ClassMethod createUser(payload As %DynamicObject) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Creates list of users with given input array
/// @apiPub[tag="user"]
/// @apiPub[path="/user/createWithList"]
/// @apiPub[description="Creates list of users with given input array"]
/// @apiPub[params.payload.schema="createUsersWithListInput_request"]
/// @apiPub[params.payload.parse="1"]
/// @apiPub[response.schema="User"]
ClassMethod createUsersWithListInput(payload As %DynamicArray) As %DynamicObject [ WebMethod ]
{
	
  //your code here
}

/// Logs user into the system
/// @apiPub[tag="user"]
/// @apiPub[path="/user/login"]
/// @apiPub[params.username.description="The user name for login"]
/// @apiPub[params.password.description="The password for login in clear text"]
/// @apiPub[params.XRateLimit.name="X-Rate-Limit"]
/// @apiPub[params.XRateLimit.description="calls per hour allowed by the user"]
/// @apiPub[params.XRateLimit.outputType="header"]
/// @apiPub[params.XExpiresAfter.name="X-Expires-After"]
/// @apiPub[params.XExpiresAfter.description="date in UTC when token expires"]
/// @apiPub[params.XExpiresAfter.outputType="header"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[response.schema="loginUser_response"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid username/password supplied"}]]
ClassMethod loginUser(username As %String, password As %String, Output XRateLimit As %Integer, Output XExpiresAfter As %DateTime) As %String [ WebMethod ]
{
	//your code here
}

/// Logs out current logged in user session
/// @apiPub[tag="user"]
/// @apiPub[path="/user/logout"]
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
/// @apiPub[params.username.description="The name that needs to be fetched. Use user1 for testing. "]
/// @apiPub[response.schema="User"]
/// @apiPub[statusCodes=[{"code":"400","description":"Invalid username supplied"},{"code":"404","description":"User not found"}]]
ClassMethod getUserByName(username As %String) As %DynamicObject [ WebMethod ]
{
	//your code here
}

/// Update user
/// @apiPub[tag="user"]
/// @apiPub[path="/user/{username}"]
/// @apiPub[verb="put"]
/// @apiPub[description="This can only be done by the logged in user."]
/// @apiPub[params.username.description="name that need to be deleted"]
/// @apiPub[params.payload.schema="User"]
/// @apiPub[params.payload.parse="1"]
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
/// @apiPub[description="This can only be done by the logged in user."]
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
    "title":"Swagger Petstore - OpenAPI 3.0",
    "description":"This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about\nSwagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!\nYou can now help us improve the API whether it's by making changes to the definition itself or to the code.\nThat way, with time, we can improve the API in general, and expose some of the new features in OAS3.\n\nSome useful links:\n- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)\n- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)",
    "termsOfService":"http://swagger.io/terms/",
    "contact":{
      "email":"apiteam@swagger.io"
    },
    "license":{
      "name":"Apache 2.0",
      "url":"http://www.apache.org/licenses/LICENSE-2.0.html"
    },
    "version":"1.0.17"
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
      "description":"Access to Petstore orders",
      "externalDocs":{
        "description":"Find out more about our store",
        "url":"http://swagger.io"
      }
    },
    {
      "name":"user",
      "description":"Operations about user"
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
          "format":"int64",
          "example":10
        },
        "petId":{
          "type":"integer",
          "format":"int64",
          "example":198772
        },
        "quantity":{
          "type":"integer",
          "format":"int32",
          "example":7
        },
        "shipDate":{
          "type":"string",
          "format":"date-time"
        },
        "status":{
          "type":"string",
          "description":"Order Status",
          "example":"approved",
          "enum":[
            "placed",
            "approved",
            "delivered"
          ]
        },
        "complete":{
          "type":"boolean"
        }
      },
      "xml":{
        "name":"order"
      }
    },
    "Customer":{
      "type":"object",
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64",
          "example":100000
        },
        "username":{
          "type":"string",
          "example":"fehguy"
        },
        "address":{
          "type":"array",
          "xml":{
            "name":"addresses",
            "wrapped":true
          },
          "items":{
            "$ref":"#/components/schemas/Address"
          }
        }
      },
      "xml":{
        "name":"customer"
      }
    },
    "Address":{
      "type":"object",
      "properties":{
        "street":{
          "type":"string",
          "example":"437 Lytton"
        },
        "city":{
          "type":"string",
          "example":"Palo Alto"
        },
        "state":{
          "type":"string",
          "example":"CA"
        },
        "zip":{
          "type":"string",
          "example":"94301"
        }
      },
      "xml":{
        "name":"address"
      }
    },
    "Category":{
      "type":"object",
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64",
          "example":1
        },
        "name":{
          "type":"string",
          "example":"Dogs"
        }
      },
      "xml":{
        "name":"category"
      }
    },
    "User":{
      "type":"object",
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64",
          "example":10
        },
        "username":{
          "type":"string",
          "example":"theUser"
        },
        "firstName":{
          "type":"string",
          "example":"John"
        },
        "lastName":{
          "type":"string",
          "example":"James"
        },
        "email":{
          "type":"string",
          "example":"john@email.com"
        },
        "password":{
          "type":"string",
          "example":"12345"
        },
        "phone":{
          "type":"string",
          "example":"12345"
        },
        "userStatus":{
          "type":"integer",
          "description":"User Status",
          "format":"int32",
          "example":1
        }
      },
      "xml":{
        "name":"user"
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
        "name":"tag"
      }
    },
    "Pet":{
      "required":[
        "name",
        "photoUrls"
      ],
      "type":"object",
      "properties":{
        "id":{
          "type":"integer",
          "format":"int64",
          "example":10
        },
        "name":{
          "type":"string",
          "example":"doggie"
        },
        "category":{
          "$ref":"#/components/schemas/Category"
        },
        "photoUrls":{
          "type":"array",
          "xml":{
            "wrapped":true
          },
          "items":{
            "type":"string",
            "xml":{
              "name":"photoUrl"
            }
          }
        },
        "tags":{
          "type":"array",
          "xml":{
            "wrapped":true
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
        "name":"pet"
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
      },
      "xml":{
        "name":"##default"
      }
    }
  }
}
}

}
