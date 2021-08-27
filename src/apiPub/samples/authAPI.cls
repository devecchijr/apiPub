/// sample api for custom authentication and authorization
Class apiPub.samples.authAPI Extends (%RegisteredObject, apiPub.core.jsonBuilder) [ ProcedureBlock ]
{

/// authenticate and get authorization token
/// @apiPub[tag="Authentication"]
/// @apiPub[path="/user/login"]
/// @apiPub[protected="false"]
Method userLogin(user As %Library.DynamicObject, pHttpReq As apiPub.service.message) As %Library.DynamicObject [ WebMethod ]
{
    Set tEnctUserAgent = $SYSTEM.Encryption.Base64Encode($Extract(pHttpReq.CallerInfo,1,30))    
    Set tEmail = $ZConvert(..JGet(user,"email"),"L")
    If tEmail="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<401> email is required"))
    Set tPwd = ..JGet(user,"password")
    If tPwd="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<401> password is required"))
    Set tId=$Order(^usersI("email",tEmail,""))
    If tId="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<401> invalid user"))
    Set tUser = {}.%FromJSON(^usersD(tId))
    If '##class(Custom.Posts.Services).validatePassword(tPwd,..JGet(tUser,"password")) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<401> Auth failed"))
    Set tCustomPayload = {
        "userId": (tId),
        "email": (tEmail),
        "device": (tEnctUserAgent)
    }
    Set tToken = ##class(Custom.Posts.Services).getJWT(tCustomPayload)
    Quit {
        "token":(tToken),
        "expiresIn": 3600,
        "userId": (tId)
    }
}

/// @apiPub[tag="Authentication"]
/// @apiPub[path="/user/signup"]
/// @apiPub[successfulCode="201"]
/// @apiPub[protected="false"]
Method createUser(user As %Library.DynamicObject) As %Library.DynamicObject [ WebMethod ]
{
    Set tEmail = $ZConvert(..JGet(user,"email"),"L")
    Set tPwd = ..JGet(user,"password")
    If tEmail="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "email is required"))
    If tPwd="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "password is required"))
    If $Order(^usersI("email",tEmail,""))'="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "user "_tEmail_" already exists"))
    Set tId = $I(^usersD)
    Set tUser={
        "_id":(tId),
        "email":(tEmail),
        "password":(tPwd)
    }
    Set ^usersD(tId)=tUser.%ToJSON()
    Set ^usersI("email",..JGet(user,"email"),tId)=""
    Quit {"message": "User created!", "result":{"_id":(tId), "email":(tEmail)}}
}

}
