SRC=psm
OUT=vhd

BASE=cli
CLI=$(BASE).$(OUT)
SOURCES=$(BASE).$(SRC) *.$(SRC)

TEMPLATE_FILE=my_ROM_template.vhd

.PHONEY: FORCE

all: $(CLI)
FORCE:

$(BASE).hex: $(SOURCES) buildtime.psm
	cp ./ROM_form ./ROM_form.vhd &&\
	wine kcpsm6.exe $< &&\
	rm $(CLI)
	mv ./ROM_form.vhd ./ROM_form

buildtime.psm: FORCE
	./buildTime -o buildtime.psm

$(CLI): $(BASE).hex $(TEMPLATE_FILE)
	./hex2vhdl --hexfile $< \
                   --template $(TEMPLATE_FILE) \
                   --outpath ./ \
                   --memsize 2048 \
                   --name $(BASE)
	./hex2script --hexfile $< \
                   --outfile ./Reprogram.script \
                   --memsize 2048 \
                   --baseNode CHANGEME

clean:
	@rm -f *.fmt       > /dev/null
	@rm -f *.hex       > /dev/null
	@rm -f $(CLI)      > /dev/null
	@rm -f *.txt       > /dev/null
	@rm -f *~          > /dev/null
	@rm -f $(BASE).log > /dev/null


