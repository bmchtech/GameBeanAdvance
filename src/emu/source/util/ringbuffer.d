module ringbuffer;

class RingBuffer(T) {
    T[] buffer;
    int current_index;

    this(int size) {
        current_index = 0;
        buffer[size];
    }

    void add(T element) {
        buffer[current_index] = element;
        current_index++;
    }

    T[] get() {
        T[buffer.length] return_buffer;

        for (int i = 0; i < buffer.length; i++) {
            return_buffer[i] = buffer[(i + current_index) % buffer.length];
        }

        return return_buffer;
    }
}