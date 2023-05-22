Class apiPub.samples.demo.interopApi Extends Ens.BusinessService [ ProcedureBlock ]
{

Property currencyAPIKey As %String;

Parameter SETTINGS = "currencyAPIKey:Basic,";

/// product update
/// @apiPub[tag="product"]
/// @apiPub[verb="post"]
/// @apiPub[path="product"]
ClassMethod updateProduct(pProduct As apiPub.samples.demo.product, Output tSC As %Status) As apiPub.samples.demo.product [ WebMethod ]
{
    Set tSC = $$$OK
    Set tExObj = ##class(apiPub.samples.demo.product).codeIdxOpen(pProduct.code)
    If $IsObject(tExObj) {
       // Copy all properties values to existent object
       Do pProduct.%JSONExportToString(.objContent)
       Set tSC = tExObj.%JSONImport(objContent)
       If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
       Set pProduct = tExObj
    } 
    Set tSC = pProduct.%Save()
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Quit pProduct
}

/// get a product by code
/// @apiPub[tag="product"]
/// @apiPub[path="product/{productCode}"]
/// @apiPub[params.pProdCode.name="productCode"]
ClassMethod getProduct(pProdCode As %String) As apiPub.samples.demo.product [ WebMethod ]
{
    Set tProd = ##class(apiPub.samples.demo.product).codeIdxOpen(pProdCode)
    If '$IsObject(tProd) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<404> Product code doesn't exist"))
    }
    Quit tProd
}

/// product deletion
/// @apiPub[tag="product"]
/// @apiPub[verb="delete"]
/// @apiPub[path="product/{productCode}"]
/// @apiPub[params.pProdCode.name="productCode"]
ClassMethod deleteProduct(pProdCode As %String) As %Status [ WebMethod ]
{
    Set tProd = ..getProduct(pProdCode)
    Quit tProd.%DeleteId(tProd.%Id())
}

/// composite process (get a list of products with current price)
/// @apiPub[tag="product"]
/// @apiPub[verb="put"]
/// @apiPub[path="product/list"]
Method compositeProcess(pRequest As apiPub.samples.demo.productFilter, Output tSC As %Status) As apiPub.samples.demo.productList [ WebMethod ]
{
    Set tSC = ..SendRequestSync("compositeProcess",pRequest,.tResponse)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Quit tResponse
}

/// @apiPub[tag="outbound test"]
Method testCurrency(currencies As %String = "BRL,EUR") As %DynamicObject [ WebMethod ]
{
    Set tReq = ##class(apiPub.service.message).%New()
    Set tReq.HttpVerb = "Get"
    Set tReq.APIPath = "/v1/latest"
    Set tReq.Trace = 0
    Set tReq.Params = {
      "apikey":(..currencyAPIKey),
      "currencies":(currencies)
    }.%ToJSON()
    Set tReq.APIDomain = "External Api"
    Set tReq.APIOperationId = "currency"
    Set tSC = ..SendRequestSync("currency Api",tReq,.tResponse)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Quit {}.%FromJSON(tResponse.Body)
}

/// @apiPub[tag="outbound test"]
/// @apiPub[path="testSQL"]
Method testFromSQL(pRequest As apiPub.samples.demo.productFilter, Output pResponse As apiPub.samples.demo.productList) As %Status [ WebMethod ]
{
  Quit ..SendRequestSync("fromSql", pRequest, .pResponse)
}

XData apiPub [ MimeType = application/json ]
{
{
  "info":{
    "title":"apiPub demo",
    "description":"apiPub demonstration (with interop services)",
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
