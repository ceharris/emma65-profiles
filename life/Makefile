.PHONY: all profile staging clean
.SUFFIXES: .bin .hex .lbl .lst .map .o .s .s19 .sym .tmp

EXECUTABLE=life
TEMPLATE_TOML=emulator-template.toml
PROFILE=$(HOME)/.emma/debugger/profiles/$(EXECUTABLE)
STAGING=../build/$(EXECUTABLE)
LD_CONFIG=$(EXECUTABLE).cfg
BIN_IMAGE=$(EXECUTABLE).bin

INCLUDES=$(LD_CONFIG) delay.h.s display.h.s life.h.s variables.h.s 
MODULES=main.o life.o delay.o display.o variables.o isr.o vectors.o

AS=ca65
ASFLAGS=-g --cpu W65C02
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
delay.o: delay.s $(INCLUDES)
display.o: display.s $(INCLUDES)
isr.o: isr.s $(INCLUDES)
life.o: life.s $(INCLUDES)
variables.o: variables.s $(INCLUDES)
vectors.o: vectors.s $(INCLUDES)

$(BIN_IMAGE): $(MODULES)
	$(LD) $(LDFLAGS) $^ -o $@ -m $*.map -Ln $*.lbl

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@ -l $*.lst

%.o: ../lib/%.s
	$(AS) $(ASFLAGS) $< -o $@ -l $*.lst

	
