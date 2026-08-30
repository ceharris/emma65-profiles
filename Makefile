.PHONY: all staging clean


TARGET_BASE=../emma65
STAGING_DIR=build
TEMPLATES_DIR="src/emulator/config/templates"

all: staging
	tar -C $(STAGING_DIR) -cf - . | tar -C $(TARGET_BASE)/$(TEMPLATES_DIR) -xf -

staging:
	make -C rain staging 
	make -C ehbasic staging
	make -C snake staging

clean:
	make -C rain staging
	make -C ehbasic clean
	make -C snake clean
	-rm -fr $(STAGING_DIR)
