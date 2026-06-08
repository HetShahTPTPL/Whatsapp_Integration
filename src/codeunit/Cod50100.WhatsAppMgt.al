codeunit 50100 "WhatsApp Mgt."
{
    // -----------------------------------------------------------------------
    // WhatsApp Mgt.
    // Central codeunit for sending WhatsApp messages via Twilio REST API.
    //
    // Public entry points:
    //   SendMessage(...)       -- raises an error on failure
    //   SendMessageSilent(...) -- logs failure silently, never errors
    //   BuildMessageFromTemplate(...)
    // -----------------------------------------------------------------------

    procedure SendMessage(ToNumber: Text; MessageBody: Text; SourceTable: Text; SourceRecordNo: Text)
    var
        Setup: Record "WhatsApp Setup";
        Success: Boolean;
        ErrorMsg: Text;
        TwilioSID: Text;
    begin
        GetSetup(Setup);

        if not Setup.Enabled then
            exit;

        if ToNumber = '' then
            Error('WhatsApp: Cannot send message – recipient number is empty.');

        DoSendMessage(Setup, ToNumber, MessageBody, Success, ErrorMsg, TwilioSID);

        WriteLog(ToNumber, MessageBody, SourceTable, SourceRecordNo, Success, ErrorMsg, TwilioSID);

        if not Success then
            Error('WhatsApp message failed: %1', ErrorMsg);
    end;

    procedure SendMessageSilent(ToNumber: Text; MessageBody: Text; SourceTable: Text; SourceRecordNo: Text)
    var
        Setup: Record "WhatsApp Setup";
        Success: Boolean;
        ErrorMsg: Text;
        TwilioSID: Text;
    begin
        if not Setup.Get() then
            exit;

        if not Setup.Enabled then
            exit;

        if ToNumber = '' then
            exit;

        DoSendMessage(Setup, ToNumber, MessageBody, Success, ErrorMsg, TwilioSID);

        WriteLog(ToNumber, MessageBody, SourceTable, SourceRecordNo, Success, ErrorMsg, TwilioSID);
    end;

    local procedure DoSendMessage(Setup: Record "WhatsApp Setup"; ToNumber: Text; MessageBody: Text; var Success: Boolean; var ErrorMsg: Text; var TwilioMsgSID: Text)
    var
        HttpClient: HttpClient;
        HttpRequestMsg: HttpRequestMessage;
        HttpResponseMsg: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        Base64Convert: Codeunit "Base64 Convert";
        TypeHelper: Codeunit "Type Helper";
        RequestUri: Text;
        BodyText: Text;
        ResponseText: Text;
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        EncodedBody: Text;
        EncodedTo: Text;
        EncodedFrom: Text;
        FormattedTo: Text;
        FormattedFrom: Text;
        EncodedContentSid: Text;
        EncodedContentVars: Text;
    begin
        Success := false;

        // Build URI
        RequestUri := 'https://api.twilio.com/2010-04-01/Accounts/' + Setup."Account SID" + '/Messages.json';
        HttpRequestMsg.SetRequestUri(RequestUri);
        HttpRequestMsg.Method := 'POST';

        // Authorization header – note the required space after 'Basic'
        HttpRequestMsg.GetHeaders(RequestHeaders);
        RequestHeaders.Add(
            'Authorization',
            'Basic ' + Base64Convert.ToBase64(Setup."Account SID" + ':' + Setup."Auth Token")
        );

        // UrlEncode requires var Text, so assign to local variables first
        EncodedBody := MessageBody;
        FormattedTo := FormatWhatsAppNumber(ToNumber);
        FormattedFrom := FormatWhatsAppNumber(Setup."From Number");
        EncodedBody := TypeHelper.UrlEncode(EncodedBody);
        EncodedTo := TypeHelper.UrlEncode(FormattedTo);
        EncodedFrom := TypeHelper.UrlEncode(FormattedFrom);

        // Build URL-encoded body; Twilio WhatsApp numbers need "whatsapp:" prefix
        // If a ContentSid (pre-approved template) is configured, use it.
        // Otherwise fall back to free-form Body (works after user opts in to sandbox).
        // if Setup."Content Template SID" <> '' then begin
        //     EncodedContentSid := Setup."Content Template SID";
        //     EncodedContentVars := '{"1":"' + MessageBody.Replace('"', '\"') + '"}';
        //     EncodedContentSid := TypeHelper.UrlEncode(EncodedContentSid);
        //     EncodedContentVars := TypeHelper.UrlEncode(EncodedContentVars);
        //     BodyText := 'To=' + EncodedTo +
        //                 '&From=' + EncodedFrom +
        //                 '&ContentSid=' + EncodedContentSid +
        //                 '&ContentVariables=' + EncodedContentVars;
        // end else
        BodyText := 'Body=' + EncodedBody + '&To=' + EncodedTo + '&From=' + EncodedFrom;

        Content.WriteFrom(BodyText);
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        HttpRequestMsg.Content(Content);

        // Send the request
        if not HttpClient.Send(HttpRequestMsg, HttpResponseMsg) then begin
            ErrorMsg := 'HTTP request failed – check network connectivity or allowed outbound domains.';
            exit;
        end;

        HttpResponseMsg.Content().ReadAs(ResponseText);

        if HttpResponseMsg.IsSuccessStatusCode() then begin
            Success := true;
            if JsonObj.ReadFrom(ResponseText) then
                if JsonObj.Get('sid', JsonToken) then
                    TwilioMsgSID := JsonToken.AsValue().AsText();
        end else
            ErrorMsg := StrSubstNo('HTTP %1 – %2', HttpResponseMsg.HttpStatusCode(), ResponseText);
    end;

    local procedure FormatWhatsAppNumber(PhoneNo: Text): Text
    begin
        if PhoneNo.StartsWith('whatsapp:') then
            exit(PhoneNo);

        // Strip common formatting characters
        PhoneNo := PhoneNo.Replace(' ', '').Replace('-', '').Replace('(', '').Replace(')', '');
        exit('whatsapp:' + PhoneNo);
    end;

    local procedure GetSetup(var Setup: Record "WhatsApp Setup")
    begin
        if not Setup.Get() then
            Error('WhatsApp Setup is not configured. Open the WhatsApp Integration Setup page.');

        if Setup."Account SID" = '' then
            Error('WhatsApp Setup: Account SID is missing.');

        if Setup."Auth Token" = '' then
            Error('WhatsApp Setup: Auth Token is missing.');

        if Setup."From Number" = '' then
            Error('WhatsApp Setup: From Number is missing.');
    end;

    local procedure WriteLog(ToNumber: Text; MessageBody: Text; SourceTable: Text; SourceRecordNo: Text; Success: Boolean; ErrorMsg: Text; TwilioSID: Text)
    var
        Log: Record "WhatsApp Message Log";
    begin
        Log.Init();
        Log."Date/Time Sent" := CurrentDateTime();
        Log."To Number" := CopyStr(ToNumber, 1, MaxStrLen(Log."To Number"));
        Log."Message Body" := CopyStr(MessageBody, 1, MaxStrLen(Log."Message Body"));
        Log."Source Table" := CopyStr(SourceTable, 1, MaxStrLen(Log."Source Table"));
        Log."Source Record No." := CopyStr(SourceRecordNo, 1, MaxStrLen(Log."Source Record No."));
        if Success then
            Log.Status := Log.Status::Sent
        else begin
            Log.Status := Log.Status::Failed;
            Log."Error Message" := CopyStr(ErrorMsg, 1, MaxStrLen(Log."Error Message"));
        end;
        Log."Twilio Message SID" := CopyStr(TwilioSID, 1, MaxStrLen(Log."Twilio Message SID"));
        Log.Insert();
    end;

    procedure BuildMessageFromTemplate(Template: Text; RecordNo: Text; Description: Text; RecordDate: Date): Text
    var
        FinalMsg: Text;
    begin
        if Template = '' then
            Template := 'New record created in Business Central.%NRecord No: %1%NDescription: %2%NDate: %3';

        FinalMsg := StrSubstNo(Template, RecordNo, Description, Format(RecordDate));
        exit(FinalMsg);
    end;
}
