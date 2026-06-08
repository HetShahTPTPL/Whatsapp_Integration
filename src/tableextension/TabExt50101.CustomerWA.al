tableextension 50101 "Customer WA Ext." extends Customer
{
    trigger OnAfterInsert()
    var
        WhatsAppMgt: Codeunit "WhatsApp Mgt.";
        Setup: Record "WhatsApp Setup";
        Contact: Record Contact;
        ToNumber: Text;
        MsgBody: Text;
        DefaultTemplate: Text;
    begin
        if not Setup.Get() then
            exit;
        if not Setup.Enabled then
            exit;

        ToNumber := GetCustomerContactPhone();
        if ToNumber = '' then
            exit;

        // Build a customer-specific message
        if Setup."Message Template" <> '' then
            MsgBody := WhatsAppMgt.BuildMessageFromTemplate(
                Setup."Message Template",
                Rec."No.",
                Rec.Name,
                Today()
            )
        else
            MsgBody := StrSubstNo(
                'Welcome to our system! Your customer account has been created in Business Central.%NCustomer No: %1%NName: %2%NDate: %3',
                Rec."No.", Rec.Name, Format(Today())
            );

        WhatsAppMgt.SendMessageSilent(ToNumber, MsgBody, 'Customer', Rec."No.");
    end;

    local procedure GetCustomerContactPhone(): Text
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        // Look up the contact linked to this customer via Contact Business Relation
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", Rec."No.");
        if ContBusRel.FindFirst() then
            if Contact.Get(ContBusRel."Contact No.") then
                if Contact."Phone No." <> '' then
                    exit(Contact."Phone No.");

        // Fallback: use Phone No. directly on the Customer card if populated
        if Rec."Phone No." <> '' then
            exit(Rec."Phone No.");

        exit('');
    end;
}
