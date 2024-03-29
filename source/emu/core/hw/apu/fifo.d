module hw.apu.fifo;

import std.stdio;

final class Fifo(T) {

    // size must be power of 2
    this(int size, T reset_value) {        
        this.fifo_data          = new T[size];
        this.fifo_data[0..size] = reset_value;


        this.offset_mask        = size - 1;
        this.reset_value        = reset_value;

        reset();
    }

    // pushing to a full fifo does nothing
    void push(T new_data) {
        if (size == fifo_data.length) {
            return;
        }

        size++;
        fifo_data[push_offset] = new_data;
        push_offset++;
        push_offset &= offset_mask;
    }

    // popping from an empty fifo returns null
    T pop() {
        if (size == 0) 
            return reset_value;
        
        size--;
        T return_value = fifo_data[pop_offset];
        fifo_data[pop_offset] = reset_value;
        pop_offset++;
        pop_offset &= offset_mask;
        return return_value;
    }

    bool is_full() {
        return size == fifo_data.length;
    }

    void reset() {
        this.fifo_data[0..fifo_data.length] = reset_value;

        this.push_offset        = 0;
        this.pop_offset         = 0;
        this.size               = 0;
    }

public:
    uint size;

private:
    T[]  fifo_data;
    uint push_offset;
    uint pop_offset;

    uint offset_mask;
    T    reset_value;
}