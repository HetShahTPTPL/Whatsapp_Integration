page 50100 "WhatsApp Integration Setup"
{
    ApplicationArea = All;
    Caption = 'WhatsApp Integration Setup';
    PageType = Card;
    SourceTable = "WhatsApp Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'whatsapp, twilio, sms, notification';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable or disable sending WhatsApp messages automatically when records are created.';
                }
            }

            group("API Credentials")
            {
                Caption = 'Twilio API Credentials';

                field("Account SID"; Rec."Account SID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Your Twilio Account SID, found on the Twilio Console dashboard.';
                }
                field("Auth Token"; Rec."Auth Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Your Twilio Auth Token. This value is masked for security.';
                }
                field("From Number"; Rec."From Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Twilio WhatsApp sandbox or approved sender number. Example: +14155238886. The whatsapp: prefix is added automatically.';
                }
            }

            group(Messaging)
            {
                Caption = 'Message Settings';

                field("Message Template"; Rec."Message Template")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Optional message template. Placeholders: %1 = Record No., %2 = Description/Name, %3 = Date. Leave blank to use the default template.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendTestMessage)
            {
                ApplicationArea = All;
                Caption = 'Send Test Message';
                Image = SendTo;
                ToolTip = 'Send a test WhatsApp message to verify the Twilio credentials are correct.';

                trigger OnAction()
                var
                    WhatsAppMgt: Codeunit "WhatsApp Mgt.";
                    TestNumber: Text;
                    InputDialog: Page "WhatsApp Test Send Dialog";
                begin
                    InputDialog.RunModal();
                    TestNumber := InputDialog.GetTestNumber();
                    if TestNumber = '' then
                        exit;

                    WhatsAppMgt.SendMessage(
                        TestNumber,
                        'Test message from Business Central WhatsApp Integration. Setup is working correctly!',
                        'Setup Test',
                        'TEST-001'
                    );
                    Message('Test message sent successfully to %1.', TestNumber);
                end;
            }
            action(MessageLog)
            {
                ApplicationArea = All;
                Caption = 'Message Log';
                Image = Log;
                RunObject = page "WhatsApp Message Log";
                ToolTip = 'View all WhatsApp messages sent from Business Central.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end;
    end;
}
