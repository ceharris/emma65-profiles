.PHONY: all profile staging clean
.SUFFIXES: .bin .hex .lbl .lst .map .o .s .s19 .sym .tmp

EXECUTABLE=snake
TEMPLATE_TOML=emulator-template.toml
PROFILE=$(HOME)/.emma/debugger/profiles/$(EXECUTABLE)
STAGING=../build/$(EXECUTABLE)
LD_CONFIG=$(EXECUTABLE).cfg
BIN_IMAGE=$(EXECUTABLE).bin

INCLUDES=$(LD_CONFIG) ascii.h.s delay.h.s display.h.s keys.h.s model.h.s prng.h.s \
	state.h.s timer.h.s
MODULES=snake.o console.o delay.o display.o keys.o model.o prng.o state.o \
	timer.o vectors.o

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

console.o: console.s $(INCLUDES)
delay.o: delay.s $(INCLUDES)
display.o: display.s $(INCLUDES)
keys.o: keys.s $(INCLUDES)
model.o: model.s $(INCLUDES)
prng.o: prng.s $(INCLUDES)
snake.o: snake.s $(INCLUDES)
timer.o: timer.s $(INCLUDES)
vectors.o: vectors.s $(INCLUDES)

$(BIN_IMAGE): $(MODULES)
	$(LD) $(LDFLAGS) $^ -o $@ -m $*.map -Ln $*.lbl

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@ -l $*.lst

%.o: ../lib/%.s
	$(AS) $(ASFLAGS) $< -o $@ -l $*.lst

	
