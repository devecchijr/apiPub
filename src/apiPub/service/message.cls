Class apiPub.service.message Extends (Ens.Response, Ens.Request)
{

Property CallerInfo As %String(MAXLEN = 200);

Property APIDomain As %String;

Property APIOperationId As %String(MAXLEN = 100);

Property APIPath As %String(MAXLEN = "");

Property TargetBaseURL As %String(MAXLEN = "");

Property HttpVerb As %String;

Property RequestURL As %String(MAXLEN = "");

Property Headers As %String(MAXLEN = "");

Property ContentType As %String(MAXLEN = "");

Property CharSet As %String;

Property Body As %Stream.GlobalCharacter;

Property Params As %String(MAXLEN = "");

Property Cookies As %String(MAXLEN = "");

Property MimeData As %RawString [ MultiDimensional ];

Property ContentLength As %String;

Property ContentInfo As %String(MAXLEN = "");

Property ContentBoundary As %String;

Property HttpVersion As %String;

Property ResponseStatusCode As %Integer;

Property ResponseStatusLine As %String(MAXLEN = "");

Property ResponseReasonPhrase As %String(MAXLEN = "");

Property DispatchClass As %String(MAXLEN = 200);

Property DispatchMethod As %String(MAXLEN = 100);

Property ServiceClass As %String(MAXLEN = 200);

/// Retrieves the named multipart MIME stream.
Method GetMimeData(name As %String, default As %Stream.Object = "", index As %Integer = 1) As %Stream.Object [ CodeMode = expression, Final ]
{
$get(i%MimeData(name,index),default)
}

/// Inserts a multipart MIME stream by name into the collection.
Method InsertMimeData(name As %String, value As %Stream.Object) [ Final, Internal ]
{
	If value="" Quit
	Set i%MimeData(name,$order(i%MimeData(name,""),-1)+1)=value
}

/// Returns true if the named multipart MIME stream exists in the collection, false otherwise.
Method IsDefinedMimeData(name As %String, index As %Integer = 1) As %Boolean [ CodeMode = expression, Final ]
{
$data(i%MimeData(name,index))
}

/// Returns the count of multipart MIME streams with this name.
Method CountMimeData(name As %String) As %Integer [ Final ]
{
	#Dim count,i
	
	Quit:'$data(i%MimeData(name)) 0
	Set count=0 Set i="" For  Set i=$order(i%MimeData(name,i)) Quit:i=""  Set count=count+1
	Quit count
}

/// Retrieves name of the next multipart MIME stream stored in the request object.
Method NextMimeData(name As %String) As %String [ CodeMode = expression, Final ]
{
$order(i%MimeData(name))
}

/// Return the index number of the next multipart MIME stream stored in the request object.
Method NextMimeDataIndex(name As %String, index As %Integer = "") As %String [ CodeMode = expression, Final ]
{
$order(i%MimeData(name,index))
}

/// Removes this multipart MIME stream from the collection. Returns the number
/// of nodes it has removed. If <var>name</var> is not defined then it will
/// remove the entire set of MimeData, if <var>name</var> is defined but <var>index</var>
/// is not then it will remove all items stored under <var>name</var>.
Method DeleteMimeData(name As %String = "", index As %Integer = "") As %Integer [ Final, Internal ]
{
	#Dim defined
	If name="" {
		Set defined=0
		Set name=$order(i%MimeData(""))
		While name'="" {
			Set index=$order(i%MimeData(name,""))
			While index'="" { Set defined=defined+1,index=$order(i%MimeData(name,index)) }
			Set name=$Order(i%MimeData(name))
		}
		Kill i%MimeData
		Quit defined
	} ElseIf index="" {
		Set defined=0
		Set index=$order(i%MimeData(name,""))
		While index'="" { Set defined=defined+1,index=$order(i%MimeData(name,index)) }
		Kill i%MimeData(name)
		Quit defined
	} ElseIf $Data(i%MimeData(name,index)) {
		Kill i%MimeData(name,index)
		Quit 1
	}
	Quit 0
}

Method GetParams(pLineKey, pKeyDelimiter As %String = ".") As %Library.DynamicObject
{
    Set tRef=""
    Try
	{
        If $Length(..Params)=0 Return tRef
        Set tJson = {}.%FromJSON(..Params)
        Set tRef = ##class(apiPub.core.jsonBuilder).GetByLineKey(tJson,pLineKey,pKeyDelimiter)
    }
	Catch(e)
	{
	}
    Quit tRef
}

Method GetHeaders(pLineKey, pKeyDelimiter As %String = ".") As %Library.DynamicObject
{
    Set tRef=""
    Try
	{
        If $Length(..Headers)=0 Return tRef
        Set tJson = {}.%FromJSON(..Headers)
        Set tRef = ##class(apiPub.core.jsonBuilder).GetByLineKey(tJson,pLineKey,pKeyDelimiter)
    }
	Catch(e)
	{
	}
    Quit tRef
}

Method GetBody(pLineKey, pKeyDelimiter As %String = ".") As %Library.DynamicObject
{
    Set tRef=""
    Try
	{
        Do ..Body.Rewind()
        If $Length(..Body.Read())=0 Return tRef
        Do ..Body.Rewind()
        Set tJson = {}.%FromJSON(..Body)
        Set tRef = ##class(apiPub.core.jsonBuilder).GetByLineKey(tJson,pLineKey,pKeyDelimiter)
    }
	Catch(e)
	{
	}
    Quit tRef
}

ClassMethod GetHeadersProp(pID, pLineKey, pKeyDelimiter As %String = ".") As %Library.DynamicObject [ SqlProc ]
{
    Set tRef=""
    Try
	{
        Set tObj = ..%OpenId(pID)
        Set tRef = tObj.GetHeaders(pLineKey,pKeyDelimiter)
    }
	Catch(e)
	{
	}
    Quit tRef
}

ClassMethod GetBodyProp(pID, pLineKey, pKeyDelimiter As %String = ".") As %Library.DynamicObject [ SqlProc ]
{
    Set tRef=""
    Try
	{
        Set tObj = ..%OpenId(pID)
        Set tRef = tObj.GetBody(pLineKey,pKeyDelimiter)
    }
	Catch(e)
	{
	}
    Quit tRef
}

ClassMethod GetParamsProp(pID, pLineKey, pKeyDelimiter As %String = ".") As %Library.DynamicObject [ SqlProc ]
{
    Set tRef=""
    Try
	{
        Set tObj = ..%OpenId(pID)
        Set tRef = tObj.GetParams(pLineKey,pKeyDelimiter)
    }
	Catch(e)
	{
	}
    Quit tRef
}

Storage Default
{
<Data name="messageDefaultData">
<Subscript>"message"</Subscript>
<Value name="1">
<Value>CallerInfo</Value>
</Value>
<Value name="2">
<Value>APIDomain</Value>
</Value>
<Value name="3">
<Value>APIOperationId</Value>
</Value>
<Value name="4">
<Value>APIPath</Value>
</Value>
<Value name="5">
<Value>TargetBaseURL</Value>
</Value>
<Value name="6">
<Value>HttpVerb</Value>
</Value>
<Value name="7">
<Value>RequestURL</Value>
</Value>
<Value name="8">
<Value>Headers</Value>
</Value>
<Value name="9">
<Value>ContentType</Value>
</Value>
<Value name="10">
<Value>CharSet</Value>
</Value>
<Value name="11">
<Value>Body</Value>
</Value>
<Value name="12">
<Value>Params</Value>
</Value>
<Value name="13">
<Value>Cookies</Value>
</Value>
<Value name="14">
<Value>MimeData</Value>
</Value>
<Value name="15">
<Value>ContentLength</Value>
</Value>
<Value name="16">
<Value>ContentInfo</Value>
</Value>
<Value name="17">
<Value>ContentBoundary</Value>
</Value>
<Value name="18">
<Value>HttpVersion</Value>
</Value>
<Value name="19">
<Value>ResponseStatusCode</Value>
</Value>
<Value name="20">
<Value>ResponseStatusLine</Value>
</Value>
<Value name="21">
<Value>ResponseReasonPhrase</Value>
</Value>
<Value name="22">
<Value>DispatchClass</Value>
</Value>
<Value name="23">
<Value>DispatchMethod</Value>
</Value>
<Value name="24">
<Value>ServiceClass</Value>
</Value>
</Data>
<DefaultData>messageDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
