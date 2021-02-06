#include "gamebeanadvance.h"
#include "main.h"

IMPLEMENT_APP(GameBeanAdvance)

bool GameBeanAdvance::OnInit() {
    // call default behaviour (mandatory)
    if (!wxApp::OnInit())
        return false;

    // some application-dependent treatments...

    // Show the frame
    frame->CreateStatusBar();
    frame->Show(TRUE);
    SetTopWindow(frame);
    
    return true;
}

int GameBeanAdvance::OnExit() {
    // clean up
    return 0;
}

int GameBeanAdvance::OnRun() {
    int exitcode = wxApp::OnRun();
    //wxTheClipboard->Flush();
    if (exitcode!=0)
        return exitcode;
}

void GameBeanAdvance::OnInitCmdLine(wxCmdLineParser& parser) {
    parser.SetDesc(g_cmdLineDesc);
    // must refuse '/' as parameter starter or cannot use "/path" style paths
    parser.SetSwitchChars(wxT("-"));
    
    MyFrame* frame = new MyFrame();
    this->frame = frame;
    gba = new GBA(frame);
}

bool GameBeanAdvance::OnCmdLineParsed(wxCmdLineParser& parser) {
    wxString file_name;

    if (parser.Found(wxT("f"), &file_name)) {
        gba->run((const char*) file_name.mb_str(wxConvUTF8));
    }

    return true;
}