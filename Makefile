CC      = g++
CFLAGS  = -std=c++17

SRC_DIR = src
OBJ_DIR = out

all: gba

clean:
	rm $(OBJ_DIR)/*.o
	rm gba

gba: $(OBJ_DIR)/gba.o $(OBJ_DIR)/memory.o $(OBJ_DIR)/util.o $(OBJ_DIR)/jumptable.o
	$(CC) -o gba $(OBJ_DIR)/*.o

$(OBJ_DIR)/gba.o: $(SRC_DIR)/gba.cpp $(SRC_DIR)/gba.h $(OBJ_DIR)/memory.o $(OBJ_DIR)/jumptable.o
	g++ -c $(SRC_DIR)/gba.cpp -o $(OBJ_DIR)/gba.o

$(OBJ_DIR)/memory.o: $(SRC_DIR)/memory.cpp
	g++ -c $(SRC_DIR)/memory.cpp -o $(OBJ_DIR)/memory.o

$(OBJ_DIR)/util.o: $(SRC_DIR)/util.cpp
	g++ -c $(SRC_DIR)/util.cpp -o $(OBJ_DIR)/util.o

$(OBJ_DIR)/jumptable.o: $(SRC_DIR)/jumptable/jumptable.cpp $(SRC_DIR)/jumptable/test-jumptable.cpp
	cd $(SRC_DIR)/jumptable && python make-jumptable.py
	g++ -c $(SRC_DIR)/jumptable/jumptable.cpp -o $(OBJ_DIR)/jumptable.o