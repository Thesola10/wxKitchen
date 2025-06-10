typedef long unsigned int size_t;
typedef long unsigned int time_t;
#include <wxc.h>


void *closure;

void btnClicked(void *evt)
{
    ELJApp_Exit();
}

void app_main(void *dat)
{
    void *fr = wxFrame_Create(NULL, 10, "wxKitchen demo written in C", 40, 40, 320, 240, wxDEFAULT_FRAME_STYLE);

    void *pan = wxPanel_Create(fr, 11, 0, 0, 320, 240, NULL);

    void *bt = wxButton_Create(pan, 12, "Nice", 40, 40, 100, 20, wxBU_EXACTFIT);

    void *evt = wxClosure_Create(btnClicked, NULL);

    wxWindow_Show(fr);

    ELJApp_SetTopWindow(fr);

    wxEvtHandler_Connect(fr, 12, 12, expEVT_COMMAND_BUTTON_CLICKED(), evt);
}

int main(int argc, char *argv[])
{
    void *closure = wxClosure_Create(app_main, NULL);

    ELJApp_InitializeC(closure, argc, argv);
}
