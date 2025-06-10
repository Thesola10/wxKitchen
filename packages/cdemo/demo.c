typedef long unsigned int size_t;
typedef long unsigned int time_t;
#include <wxc.h>


void *closure;

void app_main(void *dat)
{
    void *fr = wxFrame_Create(NULL, 1000, "wxKitchen demo written in C", 40, 40, 320, 240, wxDEFAULT_FRAME_STYLE);

    wxWindow_Show(fr);

    ELJApp_SetTopWindow(fr);
}

int main(int argc, char *argv[])
{
    void *closure = wxClosure_Create(app_main, NULL);

    ELJApp_InitializeC(closure, argc, argv);
}
