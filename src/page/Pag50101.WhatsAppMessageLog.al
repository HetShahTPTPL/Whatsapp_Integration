page 50101 "WhatsApp Message Log"
{
    ApplicationArea = All;
    Caption = 'WhatsApp Message Log';
    PageType = List;
    SourceTable = "WhatsApp Message Log";
    UsageCategory = Lists;
    Editable = false;
    AdditionalSearchTerms = 'whatsapp log, twilio log, message history';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique log entry number.';
                }
                field("Date/Time Sent"; Rec."Date/Time Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date and time the message was sent.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Sent or Failed.';
                    StyleExpr = StatusStyle;
                }
                field("To Number"; Rec."To Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Recipient WhatsApp number.';
                }
                field("Source Table"; Rec."Source Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Business Central table that triggered this message.';
                }
                field("Source Record No."; Rec."Source Record No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The record number that triggered this message.';
                }
                field("Message Body"; Rec."Message Body")
                {
                    ApplicationArea = All;
                    ToolTip = 'The full message body that was sent.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Error details if the message failed.';
                }
                field("Twilio Message SID"; Rec."Twilio Message SID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Twilio message SID returned upon successful delivery.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RetryFailed)
            {
                ApplicationArea = All;
                Caption = 'Retry Failed';
                Image = Refresh;
                ToolTip = 'Retry sending the selected failed message.';

                trigger OnAction()
                var
                    WhatsAppMgt: Codeunit "WhatsApp Mgt.";
                begin
                    if Rec.Status <> Rec.Status::Failed then begin
                        Message('Only failed messages can be retried.');
                        exit;
                    end;
                    WhatsAppMgt.SendMessage(
                        Rec."To Number",
                        Rec."Message Body",
                        Rec."Source Table",
                        Rec."Source Record No."
                    );
                    Message('Message re-sent successfully.');
                end;
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Sent:
                StatusStyle := 'Favorable';
            Rec.Status::Failed:
                StatusStyle := 'Unfavorable';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
