/// day by day method samples
Class apiPub.samples.demo.fastApi Extends Ens.BusinessService [ ProcedureBlock ]
{

/// creates or updates a product 
ClassMethod insertOrUpdateProduct(pProduct As apiPub.samples.demo.product, Output tSC As %Status) As apiPub.samples.demo.product [ WebMethod ]
{
    Set tSC = $$$OK
    Set tExObj = ##class(apiPub.samples.demo.product).codeIdxOpen(pProduct.code)
    If $IsObject(tExObj) {
       // Copy all properties values to existent object
       Set tSC = ..copyProperties(pProduct, .tExObj)
       Set pProduct = tExObj
    } 
    Set tSC = pProduct.%Save()
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Quit pProduct
}

/// gets a product by code (read) 
ClassMethod getProduct(code As %String) As apiPub.samples.demo.product [ WebMethod ]
{
    Set tProd = ##class(apiPub.samples.demo.product).codeIdxOpen(code)
    If '$IsObject(tProd) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Product code doesn't exist"))
    }
    Quit tProd
}

/// deletes a product 
ClassMethod deleteProduct(code As %String) As %Status [ WebMethod ]
{
    Set tProd = ..getProduct(code)
    Quit tProd.%DeleteId(tProd.%Id())
}

/// shows products with stock higher than a minimum quantity 
ClassMethod productsByStk(minStock As %Integer) As %ListOfObjects(ELEMENTTYPE="apiPub.samples.demo.product") [ WebMethod ]
{
    If minStock="" Set minStock = 0
    Set sql = "SELECT ID FROM apiPub_samples_demo.product WHERE stockQty >= "_minStock
    Set stat = ##class(%SQL.Statement).%New()
    Set Status = stat.%Prepare(sql)
    Set rset = stat.%Execute()
    Set ret = ##class(%ListOfObjects).%New()
    While rset.%Next() {
        Do ret.Insert(##class(apiPub.samples.demo.product).%OpenId(rset.ID))
    }
    Return ret
}

/// shows products by range of price 
ClassMethod productsByPriceRange(minPrice As %Numeric = 0.01, maxPrice As %Numeric = 99999999999.99) As %DynamicObject [ WebMethod ]
{
    Set list = []
    If minPrice="" Set minPrice = 0
    If maxPrice="" Set maxPrice = 99999999999
    Set sql = "SELECT ID FROM apiPub_samples_demo.product WHERE price between "_minPrice_" and "_maxPrice
    Set stat = ##class(%SQL.Statement).%New()
    Set Status = stat.%Prepare(sql)
    Set rset = stat.%Execute()
    Set ret = ##class(%ListOfObjects).%New()
    While rset.%Next() {
        Set item = ##class(apiPub.samples.demo.product).%OpenId(rset.ID)
        Do list.%Push({
            "code":(item.code),
            "description":(item.description),
            "price":(item.price)
        })
    }
    Return list
}

/// gets a list of products with current price using a filter
Method callPriceListBP(pRequest As apiPub.samples.demo.productFilter, Output tSC As %Status) As apiPub.samples.demo.productList [ WebMethod ]
{
    Set tSC = ..SendRequestSync("priceList",pRequest,.tResponse)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Quit tResponse
}

/// Math
ClassMethod division(user As %String, dividend As %Numeric, divider As %Numeric) As %String [ WebMethod ]
{
  If divider = 0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> The divider value could not be zero"))
  Quit "Hello "_user_"! The division result is: "_(dividend/divider)
}

/// uploads a file (binary) or image (stream) 
ClassMethod saveFile(payload As %Stream.GlobalBinary, keyName As %String) As %Status [ WebMethod ]
{
    Set tFileName = ##class(%SYSTEM.Util).DataDirectory()_keyName
    Set timg=##class(%Stream.FileBinary).%New()
    Set tSC=timg.LinkToFile(tFileName)
    Do timg.CopyFrom(payload)
    Do timg.%Save()
    Quit $$$OK
}

/// gets a file (binary) or image (stream)
ClassMethod getFile(keyName As %String) As %Stream.FileBinary [ WebMethod ]
{
    Set tFileName = ##class(%SYSTEM.Util).DataDirectory()_keyName
    Set tFileStream=##class(%Stream.FileBinary).%New()
    Set tSC=tFileStream.LinkToFile(tFileName)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    If tFileStream.SizeGet()=0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<404> file doesn't exist"))
    Quit tFileStream
}

/// shows an image (html wrapped) 
ClassMethod showImage(keyName As %String, httpReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    Set tFileStream=..getFile(keyName)
    Set tOutput=##class(%Stream.GlobalCharacter).%New()
    Do tOutput.Write("<img alt="""" src=""http://"_httpReq.GetHeaders("HTTP_HOST")_$Piece(httpReq.GetHeaders("REQUEST_URI"),"/",1,2)_"/file/"_keyName_"""/>")
    Quit tOutput
}

/// Copy all properties to another object
ClassMethod copyProperties(fromObj As %JSON.Adaptor, ByRef toObj As %JSON.Adaptor) As %Status
{
      Do fromObj.%JSONExportToString(.objContent)
      Quit toObj.%JSONImport(objContent)
}

XData apiPub [ MimeType = application/json ]
{
{
  "info":{
    "title":"Fast API",
    "description":"how to speed up your IRIS Api's",
    "version":"1.0.0",
    "termsOfService":"http://swagger.io/terms/",
    "contact":{
      "email":"apiteam@swagger.io"
    },
    "license":{
      "name":"Apache 2.0",
      "url":"http://www.apache.org/licenses/LICENSE-2.0.html"
    }
  }
}
}

}
