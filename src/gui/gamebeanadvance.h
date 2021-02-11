#include <wx/wxprec.h>
#include <wx/cmdline.h>

#ifndef WX_PRECOMP
       #include <wx/wx.h>
#endif

#include "../gba.h"
#include "main.h"

class GameBeanAdvance : public wxApp {
    public:
        virtual bool OnInit();
        virtual int OnExit();
        virtual int OnRun();
        virtual void OnInitCmdLine(wxCmdLineParser& parser);
        virtual bool OnCmdLineParsed(wxCmdLineParser& parser);

    private:
        bool silent_mode;
        GBA* gba;
        MyFrame* frame;
};

static const wxCmdLineEntryDesc g_cmdLineDesc [] = {
     { wxCMD_LINE_SWITCH, "h", "help", "displays help on the command line parameters",
          wxCMD_LINE_VAL_NONE, wxCMD_LINE_OPTION_HELP },
     { wxCMD_LINE_OPTION, "f", "file", "gba rom to run",
          wxCMD_LINE_VAL_STRING, wxCMD_LINE_PARAM_OPTIONAL  },

     { wxCMD_LINE_NONE }
};

DECLARE_APP(GameBeanAdvance)