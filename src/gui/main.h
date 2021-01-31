#include <wx/wxprec.h>

#ifndef WX_PRECOMP
    #include <wx/wx.h>
#endif

#include "../gba.h"

// a value of "2" would mean that one pixel on the GBA is 2 pixels given as output.
#define SCREEN_SCALE_WIDTH  2
#define SCREEN_SCALE_HEIGHT 2

class MyFrame : public wxFrame {
    public:
        MyFrame();
    private:
        void OnHello(wxCommandEvent& event);
        void OnExit (wxCommandEvent& event);
        void OnAbout(wxCommandEvent& event);
};

enum
{
    ID_Hello = 1
};