Class apiPub.samples.Order Extends (%Persistent, %XML.Adaptor)
{

Property id As %Integer [ Required ];

Property petId As %Integer;

Property pet As apiPub.samples.Pet(XMLPROJECTION = "none") [ Required ];

Property quantity As %SmallInt;

Property shipDate As %DateTime [ InitialExpression = {$ZDateTime($Horolog, 3)} ];

Property status As %String(VALUELIST = ",placed,approved,delivered") [ InitialExpression = "placed" ];

Property complete As %Boolean [ InitialExpression = 0 ];

Index idIDX On id [ Unique ];

Method petIdSet(value As %Integer) As %Status
{
    Set tSC = $$$OK
    Set pPet = ##class(apiPub.samples.Pet).idIDXOpen(value)
    Set $this.pet = ""
    Set i%petId = ""
    If $IsObject(pPet) {
        Set $this.pet = pPet
        Set i%petId = value
    }
    Quit tSC
}

Storage Default
{
<Data name="OrderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>petId</Value>
</Value>
<Value name="3">
<Value>quantity</Value>
</Value>
<Value name="4">
<Value>shipDate</Value>
</Value>
<Value name="5">
<Value>status</Value>
</Value>
<Value name="6">
<Value>complete</Value>
</Value>
<Value name="7">
<Value>id</Value>
</Value>
<Value name="8">
<Value>id2</Value>
</Value>
<Value name="9">
<Value>pet</Value>
</Value>
</Data>
<DataLocation>^apiPub.samples.OrderD</DataLocation>
<DefaultData>OrderDefaultData</DefaultData>
<IdLocation>^apiPub.samples.OrderD</IdLocation>
<IndexLocation>^apiPub.samples.OrderI</IndexLocation>
<StreamLocation>^apiPub.samples.OrderS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
