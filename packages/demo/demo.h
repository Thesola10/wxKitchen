#include <wx/wx.h>

#define ID_Bt_Click 1

class DemoApp: public wxApp
{
    virtual bool OnInit();
};

class DemoFrame: public wxFrame
{
public:
    DemoFrame(const wxString &title, const wxPoint &pos, const wxSize &size);

    void OnClickButton1(wxCommandEvent &event);

    wxButton *Button1;

    DECLARE_EVENT_TABLE()
};

IMPLEMENT_APP(DemoApp)
