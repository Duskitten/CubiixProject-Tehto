shader_type canvas_item;

uniform sampler2D character_a;
uniform sampler2D character_b;

uniform float position : hint_range(0, 1, 0.001) = 0.5;
uniform int stepIntensify = 1;
uniform int sheet_columns = 1;
uniform int sheet_rows = 1;
void fragment() {
	vec2 sprite_sheet_size = vec2(textureSize(TEXTURE,0));
    vec2 frame_size;
    frame_size.x = sprite_sheet_size.x/float(sheet_columns);
    frame_size.y = sprite_sheet_size.y/float(sheet_rows);
    vec2 current_point = sprite_sheet_size * UV;
    float row = floor(current_point.y / frame_size.y);
    float column = floor(current_point.x / frame_size.x);
    vec2 max_point = (frame_size * vec2(column, row)) + frame_size;
    vec2 new_uv = 1.0 - (max_point - current_point) / frame_size;
	float newpos = round(smoothstep(0,1,(position + new_uv.y) / 2.0));
	vec4 newcolora = texture(character_b,UV);
	vec4 newcolorb = texture(character_a,UV);
	COLOR = mix(newcolora,newcolorb,newpos); 
}