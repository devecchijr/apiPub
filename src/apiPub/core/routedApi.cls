Class apiPub.core.routedApi Extends %Projection.AbstractProjection [ Abstract ]
{

/// Latency improvement. This method will create the cached route api object for all classes (apis) that inherit from this one. 
ClassMethod CreateProjection() As %Status [ CodeMode = objectgenerator ]
{
	Set tSC = $System.Status.OK()
	Try {
        Set tSC = ##class(apiPub.core.irisMetadata).GetSubclassesOf(..GetClassName(),.arr)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set arrIt = arr.%GetIterator()
        While arrIt.%GetNext(.key,.classname) {
            Write !,"Generating Metadata For "_classname
            Kill ^TmpApipubClassInfo(classname)
            Set tTimeChanged=""
            Set tSC = ##class(apiPub.core.irisMetadata).GetClassDefInfo(classname,.tTimeChanged,.tIsXMLAdaptor,.tIsBusinessService)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            If tTimeChanged'="" Set ^TmpApipubClassInfo(classname)=tTimeChanged_"^"_tIsXMLAdaptor_"^"_tIsBusinessService
            Set tSC = ##class(apiPub.core.irisMetadata).GetCacheCustomPaths(classname,.tIdxMap)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        }
    }
	Catch(e) {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod GetClassName() As %String
{
    Quit $CLASSNAME()
}

}
