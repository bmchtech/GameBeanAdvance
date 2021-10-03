include(UseD)
add_d_conditions(VERSION GL_AllowDeprecated default Have_bindbc_loader DEBUG )
include_directories(/home/xdrie/.dub/packages/bindbc-loader-1.0.1/bindbc-loader/source/)
add_library(bindbc-loader 
    /home/xdrie/.dub/packages/bindbc-loader-1.0.1/bindbc-loader/source/bindbc/loader/package.d
    /home/xdrie/.dub/packages/bindbc-loader-1.0.1/bindbc-loader/source/bindbc/loader/sharedlib.d
    /home/xdrie/.dub/packages/bindbc-loader-1.0.1/bindbc-loader/source/bindbc/loader/system.d
)
target_link_libraries(bindbc-loader  dl)
set_target_properties(bindbc-loader PROPERTIES TEXT_INCLUDE_DIRECTORIES "")
