#version 330 core

in vec2 vPosition;
out vec2 tex_coord;

void main() {
    gl_Position = vec4(vPosition, 0.0, 1.0);
    tex_coord   = (vPosition + 1.0) / 2.0;
    tex_coord.y *= -1.0;
}