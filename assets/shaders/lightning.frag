#version 330

in vec2 fragTexCoord;    // Texture coordinates passed from the vertex shader
out vec4 fragColor;      // Output fragment color

uniform sampler2D texture0; // The texture sampler

void main() {
    // Sample the texture and set it as the fragment color
    fragColor = texture(texture0, fragTexCoord);
}
