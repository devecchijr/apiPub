Class apiPub.tracer.bm Extends Ens.BusinessMetric
{

Property LastRun As Ens.DataType.Metric;

Property IncomingMessages As Ens.DataType.Metric(AUTOHISTORY = 60) [ MultiDimensional ];

Property Errors As Ens.DataType.Metric(AUTOHISTORY = 60) [ MultiDimensional ];

Property Expired As Ens.DataType.Metric(AUTOHISTORY = 60) [ MultiDimensional ];

Property Cube As %String [ InitialExpression = "apiPub" ];

Property TimeForExpiration As %Integer [ InitialExpression = 120 ];

Parameter SETTINGS = "Cube,TimeForExpiration";

Method OnCalculateMetrics() As %Status
{
	Set tSC = $$$OK
	Try {
		// Check messages that were visited but were still running one more time
		Set tStmt = ##class(%SQL.Statement).%New()
		Set tSC = tStmt.%Prepare("Select ID,SessionId,Status,IsError From Ens.MessageHeader mh Where ID = ?")
		Set tExpired = 0
		Quit:$$$ISERR(tSC)
		Set tID = $Order(^apiPub.tracer(""),1,tDate)
		While tID {
			Set tRS = tStmt.%Execute(tID), tDelete = 1
			If tRS.%Next() {
				If (tRS.Status = $$$eMessageStatusCompleted) || (tRS.IsError) || (tRS.Status = $$$eMessageStatusError) || (tRS.Status = $$$eMessageStatusDiscarded) {
					Set tSC = ..SaveFact(tRS.ID)
					Quit:$$$ISERR(tSC)
				}
				ElseIf ($System.SQL.DATEDIFF("SS",tDate,$Horolog) > ..TimeForExpiration) {
					Set tExpired = tExpired + 1
					Set tSC = ..SaveFact(tRS.ID,1,..TimeForExpiration)
					Quit:$$$ISERR(tSC)
				}
				ElseIf (tRS.Status '= $$$eMessageStatusSuspended) {
					Set tDelete = 0
				}
			}
			If tDelete {
				Kill ^apiPub.tracer(tID)
			}
			Set tID = $Order(^apiPub.tracer(tID),1,tDate)
		}
		Quit:$$$ISERR(tSC)
		// Continue From Last Run
		Set tLastID = $Get(^apiPub.tracer,0)
		Set (tIncoming, tErrors) = 0
		Set tStmt = ##class(%SQL.Statement).%New()
		Set tSC = tStmt.%Prepare("Select ID,SessionId,Status,IsError From Ens.MessageHeader mh Where ID > ? And Type = ?")
		Quit:$$$ISERR(tSC)
		Set tRS = tStmt.%Execute(tLastID, $$$eMessageTypeRequest)
		While tRS.%Next() {
            If tRS.ID = tRS.SessionId { // Incoming Message
				Set tIncoming = tIncoming + 1
			}
            If tRS.IsError || (tRS.Status = $$$eMessageStatusError) {
                Set tSC = ..SaveFact(tRS.ID)
                Quit:$$$ISERR(tSC)
                Set tErrors = tErrors + 1
            }
            Else {
                If tRS.Status = $$$eMessageStatusCompleted {
                    Set tSC = ..SaveFact(tRS.ID)
                    Quit:$$$ISERR(tSC)
                }
                ElseIf tRS.Status '= $$$eMessageStatusAborted { // Still processing
                    Set ^apiPub.tracer(tRS.ID) = $Horolog
                }
                Else {
                    Set tSC = ..SaveFact(tRS.ID)
                    Quit:$$$ISERR(tSC)
                }
            }
            Set ^apiPub.tracer = tRS.ID
            Quit:$$$ISERR(tSC)
		}
	}
	Catch tError {
		Set tSC = tError.AsStatus()
	}
	If $$$ISOK(tSC) {
		Set ..LastRun = $ZDateTime($Horolog,3)
		Set ..IncomingMessages = tIncoming
		Set ..Errors = tErrors
		Set ..Expired = tExpired
		If ..Cube '= "" {
			Job ##class(%DeepSee.Utils).%SynchronizeCube(..Cube)
		}
	}		
	Quit tSC
}

ClassMethod SaveFact(pMessageId As %Integer, pExpired As %Boolean = 0, pTimeForExpiration As %Integer = 120) As %Status
{
	Set tSC = $$$OK
	Try {
        Set tMsgReq = ##class(Ens.MessageHeader).%OpenId(pMessageId)
        If $IsObject(tMsgReq) {
            Set tID = ""
            &sql(SELECT ID INTO :tID FROM apiPub_tracer.message where reqId = :pMessageId)
            Set tFact = ##class(apiPub.tracer.message).%New()
            If SQLCODE=0,tID'="" Set tFact = ##class(apiPub.tracer.message).%OpenId(tID)
            Set tFact.reqId = pMessageId
            Set tFact.sessionId = tMsgReq.SessionId
            Set tFact.intType = $Select(tMsgReq.SessionId=tMsgReq.%Id():1,tMsgReq.TargetBusinessType=3:3,1:2)
            Set tFact.intBusinessType = $Select(tMsgReq.SourceBusinessType=1:"BS",tMsgReq.SourceBusinessType=2:"BP",1:"BO")_"|"_$Select(tMsgReq.TargetBusinessType=1:"BS",tMsgReq.TargetBusinessType=2:"BP",1:"BO")
            Set tFact.intBusinessComponent = tMsgReq.SourceConfigName_"|"_tMsgReq.TargetConfigName
            Set tFact.reqDt = $System.SQL.DATEADD("HH",-3,tMsgReq.TimeCreated)
            Set tFact.timeToComplete = $System.SQL.DATEDIFF("MS", $System.SQL.DATEADD("HH",-3,tMsgReq.TimeCreated), $ZDT($H,3))/1000
            Set tFact.msgStatus = tMsgReq.Status
            Set tFact.respIsError = 0
            Set tFact.respErrorMsg = ""
            If tMsgReq.MessageBodyClassName = "apiPub.service.message" {
                Set tBodyReq = ##class(apiPub.service.message).%OpenId(tMsgReq.MessageBodyId)
                If $IsObject(tBodyReq) {
                    Set tFact.reqBodyId = tMsgReq.MessageBodyId
                    Set tFact.callerInfo = tBodyReq.CallerInfo
                    Set tFact.apiOperationId = tBodyReq.APIOperationId
                    Set tFact.apiDomain = tBodyReq.APIDomain
                    Set tFact.targetBaseURL = tBodyReq.TargetBaseURL
                    Set tFact.apiPath = tBodyReq.APIPath
                    Set tFact.reqHttpVerb = tBodyReq.HttpVerb
                    Set tFact.reqHttpURL = tBodyReq.RequestURL
                    Set tFact.reqHttpParams = tBodyReq.Params
                    Set tFact.reqHttpHeaders = tBodyReq.Headers
                    Set tFact.reqHttpBody = tBodyReq.Body
                }
            }
            If tMsgReq.CorrespondingMessageId'="" {
                Set tMsgResp = ##class(Ens.MessageHeader).%OpenId(tMsgReq.CorrespondingMessageId)
                If $IsObject(tMsgResp) {
                    Set tFact.intBusinessType = $Select(tMsgReq.SourceBusinessType=1:"BS",tMsgReq.SourceBusinessType=2:"BP",1:"BO")_"|"_$Select(tMsgResp.SourceBusinessType=1:"BS",tMsgResp.SourceBusinessType=2:"BP",1:"BO")
                    Set tFact.intBusinessComponent = tMsgReq.SourceConfigName_"|"_tMsgResp.SourceConfigName
                    Set tFact.respDt = $System.SQL.DATEADD("HH",-3,tMsgResp.TimeCreated)
                    If tMsgResp.TimeProcessed'="" Set tFact.timeToComplete = $System.SQL.DATEDIFF("MS", tMsgReq.TimeCreated, tMsgResp.TimeProcessed)/1000
                    Set tFact.msgStatus = tMsgResp.Status
                    Set tFact.respIsError = tMsgResp.IsError
                    If tMsgResp.ErrorStatus'=$$$OK {
                        Set tErrorText = $System.Status.GetErrorText(tMsgResp.ErrorStatus)
                        Set tFact.respErrorMsg = $Select($Find(tErrorText," > ")>0:$Piece(tErrorText," > ",2),1:tErrorText)
                        Set tFact.respErrorCode = $System.Status.GetErrorCodes(tMsgResp.ErrorStatus)
                    }
                    If tMsgResp.MessageBodyClassName = "apiPub.service.message" {
                        Set tBodyResp = ##class(apiPub.service.message).%OpenId(tMsgResp.MessageBodyId)
                        If $IsObject(tBodyResp) {
                            Set tFact.respBodyId = tMsgResp.MessageBodyId
                            Set tFact.respHttpHeaders = tBodyResp.Headers
                            Set tFact.respHttpBody = tBodyResp.Body
                            Set tFact.respHttpURL = tBodyResp.RequestURL
                            Set tFact.respHttpStatusCode = tBodyResp.ResponseStatusCode
                            Set tFact.respHttpStatusLine = tBodyResp.ResponseStatusLine
                            Set tFact.respHttpReasonPhrase = tBodyResp.ResponseReasonPhrase
                        }
                    }
                    //Treat Response Status
                    //**********************************************
                    Set tFact.responseStatus = 0 //Not Defined
                    If tFact.respIsError {
                        Set tFact.responseStatus = 3 //Error
                        If +tFact.respErrorCode=0,tFact.respErrorMsg["#",tFact.respErrorMsg[":" {
                            Set tFact.respErrorCode = $Piece($Piece(tFact.respErrorMsg,"#",2),":",1)
                        }
                        If +tFact.respErrorCode>=83,+tFact.respErrorCode<=5001 Set tFact.responseStatus = 2 // Business Error
                    } ElseIf tFact.respHttpStatusCode'="" {
                        Set tFact.responseStatus = 1 //Success
                        If tFact.respHttpStatusCode>202 {
                            Set tFact.responseStatus = 3 
                            Set tFact.respErrorMsg = tFact.respHttpStatusLine_" "_tFact.respHttpReasonPhrase
                            If tFact.respErrorCode = "" Set tFact.respErrorCode = tFact.respHttpStatusCode
                        }
                    }
                }
            }
            //Treat Status
            //**********************************************
            If pExpired {
                Set tFact.status = 4 // Expired
                Set tFact.timeToComplete = $System.SQL.DATEDIFF("MS",tMsgReq.TimeCreated, $ZDateTime($Horolog,3))/1000 // Expired
            }
            Else {
                If tMsgReq.Status = $$$eMessageStatusCompleted {
                    Set tFact.status = 1
                }
                ElseIf tMsgReq.Status = $$$eMessageStatusError || tMsgReq.IsError {
                    Set tFact.status = 2
                }
                Else {
                    Set tFact.status = 3 // Aborted
                }
                If tMsgReq.TimeProcessed'="" Set tFact.timeToComplete = $System.SQL.DATEDIFF("MS", tMsgReq.TimeCreated, tMsgReq.TimeProcessed)/1000
            }
            Set tSC = tFact.%Save()
		    Quit:$$$ISERR(tSC)
            Write "Saving...",pMessageId,!
        }
	}
	Catch(e)
	{
		Write $System.Status.DisplayError(e.AsStatus())
        Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod GetByLineKey(pJSON As %Library.DynamicObject, pKey As %String, pKeyDelimiter As %String = ".") As %Library.DynamicObject
{
    Quit ##class(apiPub.core.jsonBuilder).GetByLineKey(pJSON,pKey,pKeyDelimiter)
}

}
