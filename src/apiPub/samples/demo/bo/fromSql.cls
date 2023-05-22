Class apiPub.samples.demo.bo.fromSql Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method SelectSql(pRequest As apiPub.samples.demo.productFilter, Output pOutput As apiPub.samples.demo.productList) As %Status
{
    set snap = ##class(EnsLib.SQL.Snapshot).%New()
    set tSC = ..Adapter.ExecuteQuery(.snap,"select code, description, price, stockQty, available, createdOn from apiPub_samples_demo.product where code = '"_pRequest.code_"' or ('"_pRequest.description_"' <> '' and description like '%"_pRequest.description_"%')")
    Set pOutput = ##class(apiPub.samples.demo.productList).%New()
    If $$$ISERR(tSC) return tSC
    While snap.Next()
    {
        Set pProd = ##class(apiPub.samples.demo.item).%New()
        Set pProd.code = snap.Get("code")
        Set pProd.description = snap.Get("description")
        Set pProd.price = snap.Get("price")
        Set pProd.stockQty = snap.Get("stockQty")
        Set pProd.available = snap.Get("available")
        Set pProd.createdOn = snap.Get("createdOn")
        Do pOutput.productList.Insert(pProd)            
    }              
    Quit $$$OK
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="apiPub.samples.demo.productFilter">
        <Method>SelectSql</Method>
    </MapItem>
</MapItems>
}

}
