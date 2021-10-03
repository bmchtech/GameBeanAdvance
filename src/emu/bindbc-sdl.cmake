include(UseD)
add_d_conditions(VERSION GL_AllowDeprecated default Have_bindbc_sdl Have_bindbc_loader DEBUG )
include_directories(/home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/)
include_directories(/home/xdrie/.dub/packages/bindbc-loader-1.0.1/bindbc-loader/source/)
add_library(bindbc-sdl 
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/package.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdl.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlassert.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlatomic.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlaudio.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlblendmode.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlclipboard.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlcpuinfo.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlerror.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlevents.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlfilesystem.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlgamecontroller.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlgesture.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlhaptic.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlhints.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdljoystick.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlkeyboard.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlkeycode.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlloadso.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdllog.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlmessagebox.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlmouse.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlmutex.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlpixels.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlplatform.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlpower.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlrect.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlrender.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlrwops.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlscancode.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlsensor.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlshape.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlstdinc.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlsurface.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlsystem.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlsyswm.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlthread.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdltimer.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdltouch.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlversion.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlvideo.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/bind/sdlvulkan.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/config.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/dynload.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/image.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/mixer.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/net.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/package.d
    /home/xdrie/.dub/packages/bindbc-sdl-1.0.1/bindbc-sdl/source/bindbc/sdl/ttf.d
)
target_link_libraries(bindbc-sdl bindbc-loader dl)
set_target_properties(bindbc-sdl PROPERTIES TEXT_INCLUDE_DIRECTORIES "")
