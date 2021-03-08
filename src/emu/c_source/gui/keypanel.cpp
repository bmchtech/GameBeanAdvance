#ifndef WX_PRECOMP
    #include <wx/wx.h>
#endif

#include "keypanel.h"
#include "../memory.h"

KeyPanel::KeyPanel(wxFrame* parent, Memory* memory) : wxPanel(parent) {
    this->memory = memory;
}

void KeyPanel::OnKeyDown(wxKeyEvent& event) {
    int key_code = event.GetKeyCode();

    for (int i = 0; i < 10; i++) {
        if (key_code == KEY_MAPPING[i]) {
            *memory->KEYINPUT &= ~(1UL << i);
            std::cout << "KEYPRESS RECOGNIZED " << *memory->KEYINPUT << std::endl;
        }
    }
}

void KeyPanel::OnKeyUp(wxKeyEvent& event) {
    int key_code = event.GetKeyCode();

    for (int i = 0; i < 10; i++) {
        if (key_code == KEY_MAPPING[i]) {
            *memory->KEYINPUT |= (1 << i);
            std::cout << "KEYPRESS RECOGNIZED " << *memory->KEYINPUT << std::endl;
        }
    }
}

BEGIN_EVENT_TABLE(KeyPanel, wxPanel)
    EVT_KEY_DOWN(KeyPanel::OnKeyDown)
    EVT_KEY_UP  (KeyPanel::OnKeyUp)
END_EVENT_TABLE()