table 50100 "WhatsApp Setup"
{
    Caption = 'WhatsApp Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Account SID"; Text[100])
        {
            Caption = 'Account SID';
            DataClassification = CustomerContent;
        }
        field(3; "Auth Token"; Text[100])
        {
            Caption = 'Auth Token';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(4; "From Number"; Text[50])
        {
            Caption = 'From Number (WhatsApp Sandbox)';
            DataClassification = CustomerContent;
            ToolTip = 'Enter the Twilio WhatsApp sandbox number, e.g. +14155238886. The whatsapp: prefix is added automatically.';
        }
        field(5; "Message Template"; Text[1024])
        {
            Caption = 'Message Template';
            DataClassification = CustomerContent;
            ToolTip = 'Use placeholders: %1 = Record No., %2 = Description/Name, %3 = Date.';
        }
        field(6; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
