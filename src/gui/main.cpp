#include "main.h"

// TODO: constants file
#define SCREEN_RESOLUTION_WIDTH  240
#define SCREEN_RESOLUTION_HEIGHT 160

#include "keypanel.h"

MyFrame::MyFrame(Memory* memory) : wxFrame(NULL, wxID_ANY, "GameBeanAdvance", wxDefaultPosition, 
                                   wxSize(SCREEN_SCALE_WIDTH  * SCREEN_RESOLUTION_WIDTH, 
                                          SCREEN_SCALE_HEIGHT * SCREEN_RESOLUTION_HEIGHT + 20)) {/*
    wxMenu *menuFile = new wxMenu;
    menuFile->Append(ID_Hello, "&Hello...\tCtrl-H",
                     "Help string shown in status bar for this menu item");
    menuFile->AppendSeparator();
    menuFile->Append(wxID_EXIT);
    wxMenuBar *menuBar = new wxMenuBar;
    menuBar->Append(menuFile, "&File");

    wxMenu *menuWindow = new wxMenu;
    menuBar->Append(menuWindow, "&View");
    SetMenuBar( menuBar );

    Bind(wxEVT_MENU, &MyFrame::OnExit, this, wxID_EXIT);*/

    wxMenu* menu_file = new wxMenu;
    menu_file->Append(ID_Hello, "&Hello! :)", "test");
    menu_file->AppendSeparator();
    menu_file->Append(wxID_EXIT, _("Exit"));

    wxMenu* menu_debug = new wxMenu;

    wxMenuBar* menu_bar = new wxMenuBar;
    menu_bar->Append(menu_file, "&File");
    menu_bar->Append(menu_debug, "&Debug");
    
    SetMenuBar(menu_bar);

    renderTimer = new RenderTimer(this);
    renderTimer->start();
    this->memory = memory;
    
    this->key_panel = new KeyPanel(this, memory);
}

void MyFrame::OnExit(wxCommandEvent& event) {
    Close(true);
}

BEGIN_EVENT_TABLE(MyFrame, wxFrame)
EVT_PAINT(MyFrame::OnPaint)
END_EVENT_TABLE()

void MyFrame::OnPaint(wxPaintEvent& roEvent) {
    wxPaintDC dc(this);
    dc.Clear();
    dc.SetUserScale(SCREEN_SCALE_WIDTH, SCREEN_SCALE_HEIGHT);

    wxImage image(240, 160);

    for (int x = 0; x < 240; x++) {
    for (int y = 0; y < 160; y++) {
        // if (x % 8 == 0 || y % 8 == 0) {
        //     image.SetRGB(x, y, 255, 0, 0);
        // } else {
            image.SetRGB(x, y, memory->pixels[((x * 160) + y) * 3 + 0],
                               memory->pixels[((x * 160) + y) * 3 + 1],
                               memory->pixels[((x * 160) + y) * 3 + 2]);
        // }
    }
    }

    wxBitmap image_buffer(image, -1);
    dc.DrawBitmap(image_buffer, 0, 0);
    //delete image_buffer;
}