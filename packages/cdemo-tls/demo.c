#include <unistd.h>
#include <stdbool.h>
#include <wxc.h>
#include <curling.h>

wxStaticText *label;

void btnClicked(void *evt)
{
    int result = 0;

    char buf[256];

    result = curling_readURL("https://api.ipify.org/", buf, 255);

    if (result == -1)
        wxWindow_SetLabel((wxWindow *) label, "Error connecting to api.ipify.org");
    else
        wxWindow_SetLabel((wxWindow *) label, buf);
}

void app_main(void *dat)
{
    wxFrame *fr;
    wxPanel *pan;
    wxButton *bt;
    wxClosure *evt;

    fr = wxFrame_Create(NULL, 10, "wxKitchen demo app with HTTPS", 40, 40, 320, 240, wxDEFAULT_FRAME_STYLE);
    pan = wxPanel_Create((wxWindow *) fr, 11, 0, 0, 320, 240, wxTAB_TRAVERSAL);
    bt = wxButton_Create((wxWindow *) pan, 12, "Connect", 40, 40, 100, 20, wxBU_EXACTFIT);
    label = wxStaticText_Create((wxWindow *) pan, 15, "Click the Connect button!", 40, 40, 12000, 40, wxALIGN_LEFT);
    evt = wxClosure_Create(btnClicked, NULL);

    wxBoxSizer *parent = wxBoxSizer_Create(wxVERTICAL);
    wxBoxSizer *body = wxBoxSizer_Create(wxHORIZONTAL);
    wxBoxSizer *btns = wxBoxSizer_Create(wxHORIZONTAL);

    wxSizer_AddSizer((wxSizer *) parent, (wxSizer *) body, 1, wxEXPAND, wxALL, NULL);
    wxSizer_AddSizer((wxSizer *) parent, (wxSizer *) btns, 0, wxALIGN_RIGHT | wxRIGHT | wxBOTTOM, 10, NULL);

    wxSizer_AddWindow((wxSizer *) btns, (wxWindow *) bt, 0, 0, wxALL, NULL);
    wxSizer_AddWindow((wxSizer *) body, (wxWindow *) label, 0, 0, wxALL, NULL);

    wxEvtHandler_Connect((wxEvtHandler *) fr, 12, 12, expEVT_COMMAND_BUTTON_CLICKED(), evt);

    wxWindow_SetSizer((wxWindow *) pan, (wxSizer *) parent);

    wxWindow_Show((wxWindow *) fr);
    ELJApp_SetTopWindow((wxWindow *) fr);
}

int main(int argc, char *argv[])
{
    ELJApp_InitializeC(wxClosure_Create(app_main, NULL), argc, argv);
}
