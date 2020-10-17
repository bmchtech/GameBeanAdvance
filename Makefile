.PHONY: all test clean

CC             = g++
CFLAGS         = -c -g

SRC_DIR        = src
OBJ_DIR        = out

TEST_CATCH_DIR = tests/catch
TEST_SRC_DIR   = tests

OBJS           = $(OBJ_DIR)/catchmain.o $(OBJ_DIR)/cpu_state.o $(OBJ_DIR)/expected_output.o $(OBJ_DIR)/gba.o $(OBJ_DIR)/jumptable-thumb.o $(OBJ_DIR)/jumptable-arm.o $(OBJ_DIR)/main.o $(OBJ_DIR)/memory.o $(OBJ_DIR)/util.o $(OBJ_DIR)/arm7tdmi.o
EXE_GBA_OBJ    = $(OBJ_DIR)/main.o
EXE_TEST_OBJ   = $(OBJ_DIR)/catchmain.o $(OBJ_DIR)/cpu_state.o $(OBJ_DIR)/expected_output.o
OBJS_TEST      = $(filter-out $(EXE_GBA_OBJ),  $(OBJS))
OBJS_GBA       = $(filter-out $(EXE_TEST_OBJ), $(OBJS))

all: gba test

clean:
	rm -f $(OBJS)
	rm -f gba
	rm -f test



# GBA

gba: $(OBJ_DIR)/main.o $(OBJ_DIR)/memory.o $(OBJ_DIR)/util.o $(OBJ_DIR)/jumptable-thumb.o $(OBJ_DIR)/jumptable-arm.o
	$(CC) -g $(OBJS_GBA) -o gba 

$(OBJ_DIR)/main.o: $(OBJ_DIR)/gba.o
	$(CC) $(CFLAGS) $(SRC_DIR)/main.cpp -o $(OBJ_DIR)/main.o

$(OBJ_DIR)/gba.o: $(SRC_DIR)/gba.cpp $(SRC_DIR)/gba.h $(OBJ_DIR)/memory.o $(OBJ_DIR)/jumptable-thumb.o $(OBJ_DIR)/jumptable-arm.o $(OBJ_DIR)/arm7tdmi.o
	$(CC) $(CFLAGS) $(SRC_DIR)/gba.cpp -o $(OBJ_DIR)/gba.o

$(OBJ_DIR)/memory.o: $(SRC_DIR)/memory.cpp
	$(CC) $(CFLAGS) $(SRC_DIR)/memory.cpp -o $(OBJ_DIR)/memory.o

$(OBJ_DIR)/util.o: $(SRC_DIR)/util.cpp
	$(CC) $(CFLAGS) $(SRC_DIR)/util.cpp -o $(OBJ_DIR)/util.o

$(OBJ_DIR)/jumptable-thumb.o: $(SRC_DIR)/jumptable/jumptable-thumb-config.cpp $(OBJ_DIR)/util.o $(OBJ_DIR)/memory.o $(SRC_DIR)/jumptable/make-jumptable.py
	cd $(SRC_DIR)/jumptable && python make-jumptable.py jumptable-thumb-config.cpp jumptable-thumb.cpp jumptable-thumb.h 16 8 jumptable_thumb JUMPTABLE_THUMB_H uint16_t instruction_thumb
	$(CC) $(CFLAGS) $(SRC_DIR)/jumptable/jumptable-thumb.cpp -o $(OBJ_DIR)/jumptable-thumb.o

$(OBJ_DIR)/jumptable-arm.o: $(SRC_DIR)/jumptable/jumptable-arm-config.cpp $(OBJ_DIR)/util.o $(OBJ_DIR)/memory.o $(SRC_DIR)/jumptable/make-jumptable.py
	cd $(SRC_DIR)/jumptable && python make-jumptable.py jumptable-arm-config.cpp jumptable-arm.cpp jumptable-arm.h 32 12 jumptable_arm JUMPTABLE_ARM_H uint32_t instruction_arm
	$(CC) $(CFLAGS) $(SRC_DIR)/jumptable/jumptable-arm.cpp -o $(OBJ_DIR)/jumptable-arm.o

$(OBJ_DIR)/arm7tdmi.o: $(SRC_DIR)/arm7tdmi.cpp $(OBJ_DIR)/memory.o
	$(CC) $(CFLAGS) $(SRC_DIR)/arm7tdmi.cpp -o $(OBJ_DIR)/arm7tdmi.o

# Tests
test: CFLAGS += -D TEST

test: $(OBJ_DIR)/gba.o $(OBJ_DIR)/catchmain.o $(OBJ_DIR)/expected_output.o $(OBJ_DIR)/cpu_state.o $(OBJ_DIR)/jumptable-arm.o $(OBJ_DIR)/jumptable-thumb.o $(OBJ_DIR)/util.o $(OBJ_DIR)/arm7tdmi.o
	$(CC) -g $(TEST_SRC_DIR)/tests.cpp $(OBJS_TEST) -o test
	cd ./tests/asm; make all

$(OBJ_DIR)/catchmain.o:
	$(CC) $(CFLAGS) $(TEST_CATCH_DIR)/catchmain.cpp -o $(OBJ_DIR)/catchmain.o

$(OBJ_DIR)/expected_output.o: $(OBJ_DIR)/util.o
	$(CC) $(CFLAGS) $(TEST_SRC_DIR)/expected_output.cpp -o $(OBJ_DIR)/expected_output.o 

$(OBJ_DIR)/cpu_state.o: $(TEST_SRC_DIR)/cpu_state.cpp $(TEST_SRC_DIR)/cpu_state.h $(OBJ_DIR)/arm7tdmi.o
	$(CC) $(CFLAGS) $(TEST_SRC_DIR)/cpu_state.cpp -o $(OBJ_DIR)/cpu_state.o
