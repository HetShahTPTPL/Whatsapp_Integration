page 50102 "WhatsApp Test Send Dialog"
{
    ApplicationArea = All;
    Caption = 'Send Test WhatsApp Message';
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Input)
            {
                Caption = 'Recipient';

                field(TestNumberField; TestNumber)
                {
                    ApplicationArea = All;
                    Caption = 'WhatsApp Number';
                    ToolTip = 'Enter the recipient phone number including country code. Example: +919724242267';
                }
            }
        }
    }

    procedure GetTestNumber(): Text
    begin
        exit(TestNumber);
    end;

    var
        TestNumber: Text[50];
}
