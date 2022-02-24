module util.pointerpool;

final class PointerPool(T, size_t POOL_SIZE) {
    alias Pointer = T*;
    alias Pool    = Pointer[POOL_SIZE];
    
    Pool[] pools;
    Pool*  current_pool;

    size_t pointer_index = 0;

    this() {
        create_new_pool();
    }

    void create_new_pool() {
        pools ~= new Pool;
        current_pool = &pools[$];
    }

    Pointer get_pointer() {
        if (pointer_index > POOL_SIZE) create_new_pool();
        return pools[pointer_index++];
    }
}