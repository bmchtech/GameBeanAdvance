#include <wx/wxprec.h>
#include <wx/cmdline.h>

#ifndef WX_PRECOMP
       #include <wx/wx.h>
#endif

class GameBeanAdvance : public wxApp {
    public:
        virtual bool OnInit();
        virtual int OnExit();
        virtual int OnRun();
        virtual void OnInitCmdLine(wxCmdLineParser& parser);
        virtual bool OnCmdLineParsed(wxCmdLineParser& parser);
    private:
        bool silent_mode;
};

static const wxCmdLineEntryDesc g_cmdLineDesc [] =
{
     { wxCMD_LINE_SWITCH, "h", "help", "displays help on the command line parameters",
          wxCMD_LINE_VAL_NONE, wxCMD_LINE_OPTION_HELP },
     { wxCMD_LINE_SWITCH, "t", "test", "test switch",
          wxCMD_LINE_VAL_NONE, wxCMD_LINE_OPTION_MANDATORY  },
     { wxCMD_LINE_SWITCH, "s", "silent", "disables the GUI" },

     { wxCMD_LINE_NONE }
};

DECLARE_APP(GameBeanAdvance)