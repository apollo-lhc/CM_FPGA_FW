SRC=psm
OUT=vhd

BASE=cli
CLI=$(BASE).$(OUT)
SOURCES=$(BASE).$(SRC) *.$(SRC)

all: $(CLI)

$(CLI): $(SOURCES)
	cp ./ROM_form ./ROM_form.vhd &&\
	wine kcpsm6.exe $< &&\
	mv ./ROM_form.vhd ./ROM_form

clean:
	@rm -f *.fmt       > /dev/null
	@rm -f *.hex       > /dev/null
	@rm -f $(CLI)      > /dev/null
	@rm -f *.txt       > /dev/null
	@rm -f *~          > /dev/null
	@rm -f $(BASE).log > /dev/null
