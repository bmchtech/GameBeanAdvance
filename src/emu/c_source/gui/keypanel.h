#ifndef KEYPANEL_H
#define KEYPANEL_H

#ifndef WX_PRECOMP
    #include <wx/wx.h>
#endif

#include "../memory.h"

class KeyPanel: public wxPanel {
    public:
        KeyPanel(wxFrame* parent, Memory* memory);
        void OnKeyDown(wxKeyEvent& event);
        void OnKeyUp  (wxKeyEvent& event);
        DECLARE_EVENT_TABLE()

        static constexpr wxKeyCode KEY_MAPPING[10] = {
            WXK_CONTROL_Z, // A
            WXK_CONTROL_X, // B
            WXK_RETURN,    // SELECT
            WXK_SPACE,     // START
            WXK_RIGHT,     // RIGHT
            WXK_LEFT,      // LEFT
            WXK_UP,        // UP
            WXK_DOWN,      // DOWN
            WXK_CONTROL_Q, // L
            WXK_CONTROL_W  // R
        };
    
    private:
        Memory* memory;
};

#endif