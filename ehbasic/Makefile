.PHONY: all profile staging clean
.SUFFIXES: .bin .o .lst .map .s .sym .lbl

EXECUTABLE=ehbasic
TEMPLATE_TOML=emulator-template.toml
PROFILE=$(HOME)/.emma/debugger/profiles/$(EXECUTABLE)
STAGING=../build/$(EXECUTABLE)
LD_CONFIG=$(EXECUTABLE).cfg
BIN_IMAGE=$(EXECUTABLE).bin

MODULES=basic.o

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

basic.o: emma65.s basic.s
	$(AS) $(ASFLAGS) --feature labels_without_colons $< -o $@ -l $*.lst

$(BIN_IMAGE): $(MODULES)
	$(LD) $(LDFLAGS) $^ -o $@ -m $*.map -Ln $*.lbl
