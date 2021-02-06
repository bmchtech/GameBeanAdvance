#ifndef MAIN_H
#define MAIN_H

#include <wx/wxprec.h>
#include <wx/timer.h>

#ifndef WX_PRECOMP
    #include <wx/wx.h>
#endif

// a value of "2" would mean that one pixel on the GBA is 2 pixels given as output.
#define SCREEN_SCALE_WIDTH  2
#define SCREEN_SCALE_HEIGHT 2

class MyFrame : public wxFrame {
    public:
        MyFrame();
        wxImage image;

        void SetRGB(int x, int y, uint8_t r, uint8_t g, uint8_t b);

    private:
        void OnHello(wxCommandEvent& event);
        void OnExit (wxCommandEvent& event);
        void OnAbout(wxCommandEvent& event);
        void OnPaint(wxPaintEvent& roEvent);
        void OnIdle (wxIdleEvent& evt);

        DECLARE_EVENT_TABLE()
        
        class RenderTimer : public wxTimer {
            MyFrame* myFrame;

            public:
                RenderTimer(MyFrame* myFrame) {
                    this->myFrame = myFrame;
                }

                void Notify() {
                    myFrame->Refresh();
                }

                void start() {
                    wxTimer::Start(1);
                }
        };

        // deal with this
        uint8_t* pixels;

        RenderTimer* renderTimer;
};

enum {
    ID_Hello = 1
};

#endif