.PHONY: all test clean

CFLAGS         = -c -g --std=c++2a
CXX            = $(shell wx-config --cxx)
GCC            = g++

SRC_DIR        = src
OBJ_DIR        = out

TEST_CATCH_DIR = tests/catch
TEST_SRC_DIR   = tests

OBJS           = $(OBJ_DIR)/catchmain.o $(OBJ_DIR)/cpu_state.o $(OBJ_DIR)/expected_output.o $(OBJ_DIR)/gba.o $(OBJ_DIR)/jumptable-thumb.o $(OBJ_DIR)/jumptable-arm.o $(OBJ_DIR)/main.o $(OBJ_DIR)/memory.o $(OBJ_DIR)/util.o $(OBJ_DIR)/arm7tdmi.o $(OBJ_DIR)/gamebeanadvance.o $(OBJ_DIR)/ppu.o
EXE_GBA_OBJ    = $(OBJ_DIR)/main.o $(OBJ_DIR)/gamebeanadvance.o
EXE_TEST_OBJ   = $(OBJ_DIR)/catchmain.o $(OBJ_DIR)/cpu_state.o $(OBJ_DIR)/expected_output.o
OBJS_TEST      = $(filter-out $(EXE_GBA_OBJ),  $(OBJS))
OBJS_GBA       = $(filter-out $(EXE_TEST_OBJ), $(OBJS))

all: gba test

clean:
	rm -f $(OBJS)
	rm -f gba
	rm -f test



# GBA

gba: $(OBJ_DIR)/main.o $(OBJ_DIR)/memory.o $(OBJ_DIR)/util.o $(OBJ_DIR)/jumptable-thumb.o $(OBJ_DIR)/jumptable-arm.o $(OBJ_DIR)/ppu.o
	$(CXX) -g `wx-config --libs` $(OBJS_GBA) -o gba 

$(OBJ_DIR)/ppu.o: $(SRC_DIR)/ppu.*
	$(GCC) $(CFLAGS) $(SRC_DIR)/ppu.cpp -o $(OBJ_DIR)/ppu.o

$(OBJ_DIR)/gamebeanadvance.o: $(SRC_DIR)/gui/gamebeanadvance.* $(OBJ_DIR)/gba.o
	$(CXX) $(CFLAGS) -g `wx-config --cxxflags` $(SRC_DIR)/gui/gamebeanadvance.cpp -o $(OBJ_DIR)/gamebeanadvance.o

$(OBJ_DIR)/main.o: $(SRC_DIR)/gui/main.cpp $(OBJ_DIR)/gba.o $(OBJ_DIR)/gamebeanadvance.o
	$(CXX) $(CFLAGS) -g `wx-config --cxxflags` $(SRC_DIR)/gui/main.cpp -o $(OBJ_DIR)/main.o

$(OBJ_DIR)/gba.o: $(SRC_DIR)/gba.cpp $(SRC_DIR)/gba.h $(OBJ_DIR)/memory.o $(OBJ_DIR)/jumptable-thumb.o $(OBJ_DIR)/jumptable-arm.o $(OBJ_DIR)/arm7tdmi.o
	$(GCC) $(CFLAGS) $(SRC_DIR)/gba.cpp -o $(OBJ_DIR)/gba.o

$(OBJ_DIR)/memory.o: $(SRC_DIR)/memory.cpp $(OBJ_DIR)/util.o
	$(GCC) $(CFLAGS) $(SRC_DIR)/memory.cpp -o $(OBJ_DIR)/memory.o

$(OBJ_DIR)/util.o: $(SRC_DIR)/util.cpp
	$(GCC) $(CFLAGS) $(SRC_DIR)/util.cpp -o $(OBJ_DIR)/util.o

$(OBJ_DIR)/jumptable-thumb.o: $(SRC_DIR)/jumptable/jumptable-thumb-config.cpp $(OBJ_DIR)/util.o $(OBJ_DIR)/memory.o $(SRC_DIR)/jumptable/make-jumptable.py
	cd $(SRC_DIR)/jumptable && python3 make-jumptable.py jumptable-thumb-config.cpp jumptable-thumb.cpp jumptable-thumb.h 16 8 jumptable_thumb JUMPTABLE_THUMB_H uint16_t instruction_thumb
	$(GCC) $(CFLAGS) $(SRC_DIR)/jumptable/jumptable-thumb.cpp -o $(OBJ_DIR)/jumptable-thumb.o

$(OBJ_DIR)/jumptable-arm.o: $(SRC_DIR)/jumptable/jumptable-arm.jpp $(OBJ_DIR)/util.o $(OBJ_DIR)/memory.o $(SRC_DIR)/jumptable/make-jumptable.py
	cd $(SRC_DIR)/jumptable && ../cpp-jump/compile jumptable-arm.jpp ../jumptable/jumptable-arm
	$(GCC) $(CFLAGS) $(SRC_DIR)/jumptable/jumptable-arm.cpp -o $(OBJ_DIR)/jumptable-arm.o

$(OBJ_DIR)/arm7tdmi.o: $(SRC_DIR)/arm7tdmi.cpp $(SRC_DIR)/arm7tdmi.h $(OBJ_DIR)/memory.o
	$(GCC) $(CFLAGS) $(SRC_DIR)/arm7tdmi.cpp -o $(OBJ_DIR)/arm7tdmi.o

# Tests
test: CFLAGS += -D TEST

test: $(OBJ_DIR)/gba.o $(OBJ_DIR)/memory.o $(OBJ_DIR)/catchmain.o $(OBJ_DIR)/expected_output.o $(OBJ_DIR)/cpu_state.o $(OBJ_DIR)/jumptable-arm.o $(OBJ_DIR)/jumptable-thumb.o $(OBJ_DIR)/util.o $(OBJ_DIR)/arm7tdmi.o $(OBJ_DIR)/ppu.o
	$(GCC) -g --std=c++11 $(TEST_SRC_DIR)/tests.cpp $(OBJS_TEST) -o test
	cd ./tests/asm; make all

$(OBJ_DIR)/catchmain.o:
	$(GCC) -c -g --std=c++11 $(TEST_CATCH_DIR)/catchmain.cpp -o $(OBJ_DIR)/catchmain.o

$(OBJ_DIR)/expected_output.o: $(OBJ_DIR)/util.o $(TEST_SRC_DIR)/expected_output.cpp
	$(GCC) $(CFLAGS) $(TEST_SRC_DIR)/expected_output.cpp -o $(OBJ_DIR)/expected_output.o 

$(OBJ_DIR)/cpu_state.o: $(TEST_SRC_DIR)/cpu_state.cpp $(TEST_SRC_DIR)/cpu_state.h $(OBJ_DIR)/arm7tdmi.o
	$(GCC) $(CFLAGS) $(TEST_SRC_DIR)/cpu_state.cpp -o $(OBJ_DIR)/cpu_state.o
