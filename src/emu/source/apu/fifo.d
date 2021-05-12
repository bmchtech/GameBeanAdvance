module apu.fifo;

class Fifo(T) {

    // size must be power of 2
    this(int size, T reset_value) {
        assert((size & (size - 1)) == 0, "Size of FIFO isnt a power of 2.");
        
        this.fifo_data          = new T[size];
        this.fifo_data[0..size] = reset_value;

        this.push_offset        = 0;
        this.pop_offset         = 0;

        this.offset_mask        = size - 1;
        this.reset_value        = reset_value;
    }

    // pushing to a full fifo does nothing
    void push(T new_data) {
        if (size() == fifo_data.length)
            return;

        fifo_data[push_offset] = new_data;
        push_offset++;
        push_offset &= offset_mask;
    }

    // popping from an empty fifo returns null
    T pop() {
        if (size() == 0) 
            return reset_value;
        
        T return_value = fifo_data[pop_offset];
        fifo_data[pop_offset] = reset_value;
        pop_offset++;
        pop_offset &= offset_mask;
        return return_value;
    }

    int size() {
        return push_offset - pop_offset;
    }

    bool is_full() {
        return size() == fifo_data.length;
    }

private:
    T[]  fifo_data;
    uint push_offset;
    uint pop_offset;

    uint offset_mask;
    T    reset_value;
}