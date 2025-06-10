typedef long unsigned int size_t;
typedef long unsigned int time_t;
#include <wxc.h>


void *closure;

void app_main(void *dat)
{
    void *fr = wxFrame_Create(NULL, 1000, "wxKitchen demo written in C", 40, 40, 320, 240, wxDEFAULT_FRAME_STYLE);

    void *pan = wxPanel_Create(fr, 1100, 0, 0, 320, 240, NULL);

    void *bt = wxButton_Create(pan, 1200, "Nice", 40, 40, 100, 20, wxBU_EXACTFIT);

    wxWindow_Show(fr);

    ELJApp_SetTopWindow(fr);
}

int main(int argc, char *argv[])
{
    void *closure = wxClosure_Create(app_main, NULL);

    ELJApp_InitializeC(closure, argc, argv);
}
