Class XF.CCDA.FileInboud Extends Ens.BusinessService
{

/// Configuration item(s) to which to send messages
Property TargetConfigNames As Ens.DataType.ConfigName;

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Parameter SETTINGS = "TargetConfigNames:Basic:selector?multiSelect=0&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnProcessInput(file As %CharacterStream, Output output As %RegisteredObject) As %Status
{
    set sc = $$$OK
    try {
        set filename = $translate(file.Filename,"/","\")
        set filename = $piece(filename,"\",$length(filename,"\")) 

        set request = ##class(HS.Message.XMLMessage).%New()
        do request.AdditionalInfo.SetAt(filename,"Filename")
        set request.ContentStream = ##class(%GlobalCharacterStream).%New()
        while 'file.AtEnd {
		    do request.ContentStream.Write(file.Read())
        }

        set sc = $$$ADDSC(sc,..SendRequestSync(..TargetConfigNames,request,.response))
    } catch (err) {
        set sc = $$$ADDSC(sc,err.AsStatus())
    }
    return sc
}

}
