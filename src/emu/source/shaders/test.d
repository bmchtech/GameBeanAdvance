module shader.test;

import bindbc.opengl;

const GLchar* vertex_shader = 
"#version 330 core

in vec2 vPosition;
out vec2 tex_coord;

void main()
{
    gl_Position = vec4(vPosition, 0.0, 1.0);
    tex_coord   = (vPosition + 1.0) / 2.0;
    tex_coord.y *= -1.0;
}";

const GLchar* fragment_shader = 
"#version 330

in vec3 fs_color;
in vec2 tex_coord;
uniform sampler2D texture2D;

out vec4 color_out;

void main()
{
    color_out = texture(texture2D, tex_coord);
}";