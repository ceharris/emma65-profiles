.PHONY: all profile staging clean
.SUFFIXES: .bin .hex .lbl .lst .map .o .s .s19 .sym .tmp

EXECUTABLE=lcd
TEMPLATE_TOML=emulator-template.toml
PROFILE=$(HOME)/.emma/debugger/profiles/$(EXECUTABLE)
STAGING=../build/$(EXECUTABLE)
LD_CONFIG=$(EXECUTABLE).cfg
BIN_IMAGE=$(EXECUTABLE).bin

INCLUDES=$(LD_CONFIG) lcd8.h.s variables.h.s via.h.s
MODULES=main.o lcd8.o via.o isr.o variables.o vectors.o

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
lcd8.o: lcd8.s $(INCLUDES)
isr.o: isr.s $(INCLUDES)
variables.o: variables.s $(INCLUDES)
vectors.o: vectors.s $(INCLUDES)
via.o: via.s $(INCLUDES)


$(BIN_IMAGE): $(MODULES)
	$(LD) $(LDFLAGS) $^ -o $@ -m $*.map -Ln $*.lbl

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@ -l $*.lst

%.o: ../lib/%.s
	$(AS) $(ASFLAGS) $< -o $@ -l $*.lst

	
