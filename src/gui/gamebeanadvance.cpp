#include "gamebeanadvance.h"

IMPLEMENT_APP(GameBeanAdvance)

bool GameBeanAdvance::OnInit()
{
    // call default behaviour (mandatory)
    if (!wxApp::OnInit())
        return false;

    // some application-dependent treatments...

    // Show the frame
    wxFrame *frame = new wxFrame((wxFrame*) NULL, -1, _T("Hello wxWidgets World"));
    frame->CreateStatusBar();
    frame->SetStatusText(_T("Hello World"));
    frame->Show(TRUE);
    SetTopWindow(frame);
    return true;
}

int GameBeanAdvance::OnExit()
{
    // clean up
    return 0;
}

int GameBeanAdvance::OnRun()
{
    int exitcode = wxApp::OnRun();
    //wxTheClipboard->Flush();
    if (exitcode!=0)
        return exitcode;
}

void GameBeanAdvance::OnInitCmdLine(wxCmdLineParser& parser)
{
    parser.SetDesc (g_cmdLineDesc);
    // must refuse '/' as parameter starter or cannot use "/path" style paths
    parser.SetSwitchChars (wxT("-"));
}

bool GameBeanAdvance::OnCmdLineParsed(wxCmdLineParser& parser)
{
    silent_mode = parser.Found(wxT("s"));

    // to get at your unnamed parameters use
    wxArrayString files;
    for (int i = 0; i < parser.GetParamCount(); i++)
    {
            files.Add(parser.GetParam(i));
    }

    // and other command line parameters

    // then do what you need with them.

    return true;
}