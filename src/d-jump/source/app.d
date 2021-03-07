import std.stdio;
import arm_pinky;

void main() {
	for (ubyte i = 0; i < 16; i++) {
		arm_pinky.execute_instruction(i);
	}
}
