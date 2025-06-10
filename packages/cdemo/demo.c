typedef long unsigned int size_t;
typedef long unsigned int time_t;
#include <wxc.h>


void *closure;

int main(int argc, char *argv[])
{
    ELJApp_InitializeC(closure, argc, argv);

    void *fr = wxFrame_Create(NULL, 1000, "wxKitchen demo written in C", 40, 40, 320, 240, wxDEFAULT_FRAME_STYLE);

    void *ev = wxEvtHandler_Create();
    wxEvtHandler_ProcessPendingEvents(ev);

    ELJApp_SetTopWindow(fr);

    ELJApp_MainLoop();
}
