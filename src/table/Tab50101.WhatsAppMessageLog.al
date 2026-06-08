table 50101 "WhatsApp Message Log"
{
    Caption = 'WhatsApp Message Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Date/Time Sent"; DateTime)
        {
            Caption = 'Date/Time Sent';
            DataClassification = SystemMetadata;
        }
        field(3; "To Number"; Text[50])
        {
            Caption = 'To Number';
            DataClassification = CustomerContent;
        }
        field(4; "Message Body"; Text[1024])
        {
            Caption = 'Message Body';
            DataClassification = CustomerContent;
        }
        field(5; "Source Table"; Text[100])
        {
            Caption = 'Source Table';
            DataClassification = SystemMetadata;
        }
        field(6; "Source Record No."; Text[50])
        {
            Caption = 'Source Record No.';
            DataClassification = CustomerContent;
        }
        field(7; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = " ",Sent,Failed;
            OptionCaption = ' ,Sent,Failed';
            DataClassification = SystemMetadata;
        }
        field(8; "Error Message"; Text[500])
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
        }
        field(9; "Twilio Message SID"; Text[100])
        {
            Caption = 'Twilio Message SID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ByDate; "Date/Time Sent") { }
        key(ByStatus; Status) { }
    }
}
