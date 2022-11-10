Class apiPub.core.routedApi Extends %Projection.AbstractProjection
{

/// Latency improvement. This method will create the cached route api object for all classes (apis) that inherit from this one. 
ClassMethod CreateProjection(classname As %String) As %Status [ CodeMode = generator ]
{
	Set tSC = $System.Status.OK()
	Try {
        Set tClassName="apiPub.core.routedApi"
        Try {
            Set tClassName = ..GetClassName()
        } Catch(tEx) {}
        Try {
            Set tSC = ##class(apiPub.core.irisMetadata).GetSubclassesOf(tClassName,.arr)
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
        } Catch(tEx) {}
    }
	Catch(e) {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod GetClassName()
{
    Quit $ClassName()
}

}
