.PHONY: all staging clean

all: staging


staging:
	make -C snake staging

clean:
	make -C snake clean
