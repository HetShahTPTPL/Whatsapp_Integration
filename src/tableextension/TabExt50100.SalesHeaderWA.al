tableextension 50100 "Sales Header WA Ext." extends "Sales Header"
{
    // -----------------------------------------------------------------------
    // Sales Header WA Ext.
    //
    // Fires a WhatsApp notification when a new Sales Order is inserted.
    // The recipient number is read from the "Bill-to Contact No." → Contact
    // record's "Phone No." field.
    //
    // If your Contact stores WhatsApp in a different field (e.g. a custom
    // field or "Mobile Phone No."), change the field reference in
    // GetContactPhoneNo() below.
    // -----------------------------------------------------------------------

    trigger OnAfterInsert()
    var
        WhatsAppMgt: Codeunit "WhatsApp Mgt.";
        Setup: Record "WhatsApp Setup";
        ToNumber: Text;
        MsgBody: Text;
    begin
        // Only proceed if integration is enabled
        if not Setup.Get() then
            exit;
        if not Setup.Enabled then
            exit;

        // Only fire for Sales Orders (not Quotes, Invoices, etc.)
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;

        ToNumber := GetContactPhoneNo();
        if ToNumber = '' then
            exit;  // No phone on contact – skip silently

        MsgBody := WhatsAppMgt.BuildMessageFromTemplate(
            Setup."Message Template",
            Rec."No.",
            Rec."Sell-to Customer Name",
            Rec."Order Date"
        );

        // SendMessageSilent so a Twilio error never blocks the record save
        WhatsAppMgt.SendMessageSilent(ToNumber, MsgBody, 'Sales Header', Rec."No.");
    end;

    local procedure GetContactPhoneNo(): Text
    var
        Contact: Record Contact;
    begin
        // Priority 1: Sell-to Contact No.
        if Rec."Sell-to Contact No." <> '' then
            if Contact.Get(Rec."Sell-to Contact No.") then
                if Contact."Phone No." <> '' then
                    exit(Contact."Phone No.");

        // Priority 2: Bill-to Contact No.
        if Rec."Bill-to Contact No." <> '' then
            if Contact.Get(Rec."Bill-to Contact No.") then
                if Contact."Phone No." <> '' then
                    exit(Contact."Phone No.");

        exit('');
    end;
}
