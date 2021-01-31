// #include "gba.h"
// #include "util.h"

// int main(int argc, char** argv) {
//     if (argc == 1) {
//         error("Usage: ./gba <rom_name>");
//     }
    
//     GBA* gba = new GBA();
//     gba->run(argv[1]);

//     return 0;
// }

#include <wx/wxprec.h>
#ifndef WX_PRECOMP
    #include <wx/wx.h>
#endif

class MyFrame : public wxFrame {
    public:
        MyFrame();
    private:
        void OnHello(wxCommandEvent& event);
        void OnExit (wxCommandEvent& event);
        void OnAbout(wxCommandEvent& event);
};

bool GameBeanAdvance::OnInit() {
    MyFrame *frame = new MyFrame();
    frame->Show(true);
    return true;
}
