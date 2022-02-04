module shader.test;

import bindbc.opengl;

const GLchar* vertex_shader = 
"#version 330 core

in vec2 vPosition;
out vec2 tex_coord;

void main() {
    gl_Position = vec4(vPosition, 0.0, 1.0);
    tex_coord   = (vPosition + 1.0) / 2.0;
    tex_coord.y *= -1.0;
}";

const GLchar* fragment_shader = 
"#version 330

in vec3 fs_color;
in vec2 tex_coord;
uniform sampler2D texture2D;

// algorithm developed by Near and Talarubi:
// https://near.sh/articles/video/color-emulation
vec4 color_correct(vec4 color) {
    float lcdGamma = 4.0, outGamma = 2.2;
    float lb = pow(color.b / 31.0, lcdGamma);
    float lg = pow(color.g / 31.0, lcdGamma);
    float lr = pow(color.r / 31.0, lcdGamma);

    vec3 color_without_gamma = vec3(
        pow((  0.0 * lb +  50.0 * lg + 255.0 * lr) / 255.0, 1.0 / outGamma) * (65535.0 / 280.0),
        pow(( 30.0 * lb + 230.0 * lg +  10.0 * lr) / 255.0, 1.0 / outGamma) * (65535.0 / 280.0),
        pow((220.0 * lb +  10.0 * lg +  50.0 * lr) / 255.0, 1.0 / outGamma) * (65535.0 / 280.0)
    );

    vec3 color_with_gamma = pow(color_without_gamma, vec3(1.0 / outGamma));
    return vec4(color_with_gamma, 1.0);
}

out vec4 color_out;

void main() {
    color_out = color_correct(texture(texture2D, tex_coord));
}";