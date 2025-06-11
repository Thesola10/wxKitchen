#include <unistd.h>
#include <stdbool.h>
#include <wxc.h>

TClass(wxClosure) closure;

void btnClicked(void *evt)
{
    ELJApp_Exit();
}

void app_main(void *dat)
{
    wxFrame *fr;
    wxPanel *pan;
    wxButton *bt;
    wxClosure *evt;

    fr = wxFrame_Create(NULL, 10, "wxKitchen demo written in C", 40, 40, 320, 240, wxDEFAULT_FRAME_STYLE);
    pan = wxPanel_Create((wxWindow *) fr, 11, 0, 0, 320, 240, NULL);
    bt = wxButton_Create((wxWindow *) pan, 12, "Nice", 40, 40, 100, 20, wxBU_EXACTFIT);
    evt = wxClosure_Create(btnClicked, NULL);

    wxBoxSizer_Create(wxVERTICAL);

    wxEvtHandler_Connect((wxEvtHandler *) fr, 12, 12, expEVT_COMMAND_BUTTON_CLICKED(), evt);

    wxWindow_Show((wxWindow *) fr);
    ELJApp_SetTopWindow((wxWindow *) fr);
}

int main(int argc, char *argv[])
{
    ELJApp_InitializeC(wxClosure_Create(app_main, NULL), argc, argv);
}
