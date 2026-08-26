.PHONY: all profile staging clean
.SUFFIXES: .bin .hex .lbl .lst .map .o .s .s19 .sym .tmp

EXECUTABLE=matrix
TEMPLATE_TOML=emulator-template.toml
PROFILE=$(HOME)/.emma/debugger/profiles/$(EXECUTABLE)
STAGING=../build/$(EXECUTABLE)
LD_CONFIG=$(EXECUTABLE).cfg
BIN_IMAGE=$(EXECUTABLE).bin

INCLUDES=$(LD_CONFIG) display.h.s rand.h.s variables.h.s 
MODULES=main.o matrix.o rand.o variables.o isr.o vectors.o

AS=ca65
ASFLAGS=-g --cpu 65C02
LD=ld65
LDFLAGS=--config $(LD_CONFIG)

all: staging

profile: $(BIN_IMAGE)
	-mkdir -p $(PROFILE)
	cp $(BIN_IMAGE) $(PROFILE)/program.bin
	cp $(EXECUTABLE).lbl $(PROFILE)/program.lbl

staging: $(BIN_IMAGE)
	-mkdir -p $(STAGING)
	cp $(BIN_IMAGE) $(STAGING)/program.bin
	cp $(EXECUTABLE).lbl $(STAGING)/program.lbl
	cp $(TEMPLATE_TOML) $(STAGING)/emulator-template.toml

clean:
	-rm -f *.bin *.hex *.lbl *.lst *.map *.o *.s19 *.sym *.tmp


main.o: main.s $(INCLUDES)
isr.o: isr.s $(INCLUDES)
matrix.o: matrix.s $(INCLUDES)
rand.o: rand.s $(INCLUDES)
variables.o: variables.s $(INCLUDES)
vectors.o: vectors.s $(INCLUDES)

$(BIN_IMAGE): $(MODULES)
	$(LD) $(LDFLAGS) $^ -o $@ -m $*.map -Ln $*.lbl

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@ -l $*.lst

%.o: ../lib/%.s
	$(AS) $(ASFLAGS) $< -o $@ -l $*.lst

	
