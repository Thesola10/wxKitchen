#include "demo.h"

BEGIN_EVENT_TABLE(DemoFrame, wxFrame)
    EVT_BUTTON(ID_Bt_Click, DemoFrame::OnClickButton1)
END_EVENT_TABLE();

bool DemoApp::OnInit()
{
    DemoFrame *frame;
    wxString Name = _T("Demo app built with wxKitchen");

    frame = new DemoFrame(Name, wxPoint(50,50), wxSize(450,340) );
    frame->Show(true);
    SetTopWindow(frame);
    return true;
}

DemoFrame::DemoFrame(const wxString &title, const wxPoint &pos, const wxSize &size)
        : wxFrame((wxFrame *)NULL, -1, title, pos, size)
{
    wxPanel *panel = new wxPanel(this, -1, wxDefaultPosition, wxDefaultSize);
    Button1 = new wxButton(panel, ID_Bt_Click, _T("Cool, huh?"), wxDefaultPosition, wxDefaultSize, wxBU_EXACTFIT);
}

void DemoFrame::OnClickButton1(wxCommandEvent &event)
{
    wxExit();
    return;
}
