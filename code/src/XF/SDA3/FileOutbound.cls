Class XF.SDA3.FileOutbound Extends EnsLib.XML.Object.Operation.FileOperation
{

Method OnMessage(request As %Library.Persistent, Output response As %Library.Persistent) As %Status
{
    set sc = $$$OK
    try {
        set dtl = "SDA3/CCDAv21-to-SDA.xsl"
        set ccda = request.ContentStream
        set filename = ..Adapter.CreateFilename(request.AdditionalInfo.GetAt("Filename"),..Filename)
        set transformer = ##class(HS.Util.XSLTTransformer).%New()

        // charset processing is done by %XML.Writer.  Disable Charset property of the Adapter.
        set charset = ..Adapter.Charset
        Set ..Adapter.Charset = ""
        
        set sc = $$$ADDSC(sc,transformer.Transform(ccda, dtl, .sda))
        set sc = $$$ADDSC(sc,..Adapter.PutStream(filename,sda))

        // restore the adapter Charset
        set ..Adapter.Charset = charset
    } catch (err) {
        set sc = $$$ADDSC(sc,err.AsStatus())
    }
    return sc
}

}
