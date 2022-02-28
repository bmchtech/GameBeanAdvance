module util.pointerpool;

final class PointerPool(T, size_t POOL_SIZE) {
    alias Pool = T*;
    
    Pool[] pools;
    Pool current_pool;

    size_t pointer_index = 0;

    this() {
        create_new_pool();
    }

    void create_new_pool() {
        pools ~= new T(POOL_SIZE);
        current_pool = pools[pools.length - 1];
    }

    T* get_pointer() {
        if (pointer_index > POOL_SIZE) create_new_pool();
        return &current_pool[pointer_index++];
    }
}