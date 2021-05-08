module apu.fifo;

class Fifo(T) {
    T[]  fifo_data;
    uint fifo_offset;
    uint fifo_offset_mask;
    T    reset_value;

    // size must be power of 2
    this(int size, T reset_value) {
        assert(size & (size - 1) != 0, "Size of FIFO isnt a power of 2.");
        
        fifo_data        = new T[size];
        fifo_offset      = 0;
        fifo_offset_mask = fifo_offset - 1;

        fifo_data[0..size] = reset_value;
    }

    void push(T new_data) {
        fifo_data[fifo_offset] = new_data;
        fifo_offset++;
        fifo_offset &= fifo_offset_mask;
    }

    T pop() {
        T return_value = fifo_data[fifo_offset];
        fifo_data[fifo_offset] = reset_value;
        fifo_offset++;
        fifo_offset &= fifo_offset_mask;
        return return_value;
    }
}