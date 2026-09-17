shader_type canvas_item;

uniform sampler2D spritesheet: filter_nearest, source_color;

uniform float frequency: hint_range(0.0, 1.0) = 0.5;
uniform float speed = 5.0;
uniform vec2 size = vec2(15.0, 10.0);
uniform vec2 direction = vec2(0.2, 1.0);

const float hframes = 18.0;
const float vframes = 9.0;

//frame 77 -> col 5, row 4
const float big_drop_col = 5.0;
const float big_drop_row = 4.0;

//frame 78 -> col 6, row 4
const float small_drop_col = 6.0;
const float small_drop_row = 4.0;

float random(vec2 uv){
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 scrolled_uv = (UV * size) - (direction * speed * TIME);
	
	scrolled_uv.y += random(vec2(floor(scrolled_uv.x), 0.0));
	
	vec2 cell_id =floor(scrolled_uv);
	vec2 local_uv = fract(scrolled_uv);
	
	vec2 rand = vec2(random(cell_id), random(cell_id + vec2(1.0, -1.0)));
	
	if (rand.x > frequency){
		COLOR = vec4(0.0);
	} else{
		float current_col = small_drop_col;
		float current_row = small_drop_row;
		
		if (rand.y <= 0.3333){
			current_col = big_drop_col;
			current_row = big_drop_row;
		}
		
		vec2 sheet_uv = vec2((current_col + local_uv.x) / hframes, (current_row + local_uv.y) / vframes);
		
		COLOR = texture(spritesheet, sheet_uv);
	}
}
