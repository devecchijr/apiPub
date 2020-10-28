Class apiPub.samples.petServices Extends %RegisteredObject [ ProcedureBlock ]
{

/// Add a new pet to the store
Method addPet(pPet As apiPub.samples.Pet) As %Status [ WebMethod ]
{
    Set tSC = $System.Status.OK()
    Try {
        If $IsObject(##class(apiPub.samples.Pet).idIDXOpen(pPet.id)) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Pet (id) Already Exists"))
        }
        Set tSC = ..savePet(pPet)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

Method savePet(pPet As apiPub.samples.Pet) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$IsObject(pPet) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> Invalid Object"))
        }
        Set tCat = ##class(apiPub.samples.Category).idIDXOpen(pPet.category.id)
        If $IsObject(pPet.category) {
            Set tCat = ##class(apiPub.samples.Category).idIDXOpen(pPet.category.id)
            If '$IsObject(tCat) {
                Set tCat = ##class(apiPub.samples.Category).%New()
                Set tCat.id = pPet.category.id
                Set tCat.name = pPet.category.name
                Set tSC = tCat.%Save()
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
            Set pPet.category=tCat
        }
        Set tExPet = ##class(apiPub.samples.Pet).idIDXOpen(pPet.id)
        If $IsObject(tExPet) {
            Set tExPet.name=pPet.name
            Set tExPet.category=pPet.category
            Set tExPet.status=pPet.status
            Set tSC = tExPet.%Save()
        } Else {
            Set tSC = pPet.%Save()
        }
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
    Catch(e) {
        Set tSC = e.AsStatus()      
    }
    Quit tSC
}

}
