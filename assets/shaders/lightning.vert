#version 330

layout(location = 0) in vec3 vertexPosition; // Vertex position
layout(location = 2) in vec2 vertexTexCoord; // Texture coordinates

out vec2 fragTexCoord; // Pass texture coordinates to the fragment shader

uniform mat4 mvp; // Model-View-Projection matrix

void main() {
    fragTexCoord = vertexTexCoord; // Pass texture coordinates through
    gl_Position = mvp * vec4(vertexPosition, 1.0); // Transform vertex position
}
