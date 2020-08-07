Class apiPub.samples.api Extends %RegisteredObject [ ProcedureBlock ]
{

/// Add a new pet to the store
/// @apiPub[operationId="addPet"]
/// @apiPub[tag.name="pet"]
/// @apiPub[path="/pet"]
/// @apiPub[params.pPet.name="Body"]
/// @apiPub[params.description="Pet object that needs to be added to the store"]
/// @apiPub[params.required="true"]
Method addPet(pPet As apiPub.samples.Pet) As %Status [ WebMethod ]
{
}

/// @apiPub[params.description="Test 2"]
/// @apiPub[params.required="true"]
Method addPet2(pPet As apiPub.samples.Pet, pPet2 As apiPub.samples.Pet) As %Status [ WebMethod ]
{
}

}
