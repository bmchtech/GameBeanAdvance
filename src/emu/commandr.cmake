include(UseD)
add_d_conditions(VERSION GL_AllowDeprecated default Have_commandr DEBUG )
include_directories(/home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/)
add_library(commandr 
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/args.d
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/completion/bash.d
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/help.d
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/option.d
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/package.d
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/parser.d
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/program.d
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/utils.d
    /home/xdrie/.dub/packages/commandr-0.2.0/commandr/source/commandr/validators.d
)
target_link_libraries(commandr  )
set_target_properties(commandr PROPERTIES TEXT_INCLUDE_DIRECTORIES "")
