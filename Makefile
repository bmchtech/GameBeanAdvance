CC             = g++
CFLAGS         = -c -g

SRC_DIR        = src
OBJ_DIR        = out

TEST_CATCH_DIR = tests/catch
TEST_SRC_DIR   = tests

OBJS           = $(OBJ_DIR)/*.o
EXE_OBJ        = $(OBJ_DIR)/main.o
OBJS_TEST      = $(filter-out $(EXE_OBJ), $(OBJS))

all: gba test

clean:
	rm -f $(OBJS)
	rm -f gba
	rm -f test



# GBA

gba: $(OBJ_DIR)/main.o $(OBJ_DIR)/memory.o $(OBJ_DIR)/util.o $(OBJ_DIR)/jumptable.o
	$(CC) $(OBJS) -o gba 

$(OBJ_DIR)/main.o: $(OBJ_DIR)/gba.o
	$(CC) $(CFLAGS) $(SRC_DIR)/main.cpp -o $(OBJ_DIR)/main.o

$(OBJ_DIR)/gba.o: $(SRC_DIR)/gba.cpp $(SRC_DIR)/gba.h $(OBJ_DIR)/memory.o $(OBJ_DIR)/jumptable.o
	$(CC) $(CFLAGS) $(SRC_DIR)/gba.cpp -o $(OBJ_DIR)/gba.o

$(OBJ_DIR)/memory.o: $(SRC_DIR)/memory.cpp
	$(CC) $(CFLAGS) $(SRC_DIR)/memory.cpp -o $(OBJ_DIR)/memory.o

$(OBJ_DIR)/util.o: $(SRC_DIR)/util.cpp
	$(CC) $(CFLAGS) $(SRC_DIR)/util.cpp -o $(OBJ_DIR)/util.o

$(OBJ_DIR)/jumptable.o: $(SRC_DIR)/jumptable/jumptable.cpp $(SRC_DIR)/jumptable/jumptable-thumb.cpp $(OBJ_DIR)/util.o $(OBJ_DIR)/memory.o
	cd $(SRC_DIR)/jumptable && python make-jumptable.py
	$(CC) $(CFLAGS) $(SRC_DIR)/jumptable/jumptable.cpp -o $(OBJ_DIR)/jumptable.o



# Tests
test: CFLAGS += -D TEST

test: $(OBJ_DIR)/gba.o $(OBJ_DIR)/catchmain.o $(OBJ_DIR)/expected_output.o $(OBJ_DIR)/cpu_state.o
	$(CC) $(TEST_SRC_DIR)/tests.cpp $(OBJS_TEST) -o test

$(OBJ_DIR)/catchmain.o: $(OBJ_DIR)/gba.o
	$(CC) $(CFLAGS) $(TEST_CATCH_DIR)/catchmain.cpp -o $(OBJ_DIR)/catchmain.o

$(OBJ_DIR)/expected_output.o: $(OBJ_DIR)/util.o
	$(CC) $(CFLAGS) $(TEST_SRC_DIR)/expected_output.cpp -o $(OBJ_DIR)/expected_output.o 

$(OBJ_DIR)/cpu_state.o: $(TEST_SRC_DIR)/cpu_state.cpp $(TEST_SRC_DIR)/cpu_state.h
	$(CC) $(CFLAGS) $(TEST_SRC_DIR)/cpu_state.cpp -o $(OBJ_DIR)/cpu_state.o