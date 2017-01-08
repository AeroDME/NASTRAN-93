################################################################################
F77=gfortran
AR=ar
FLAGS+=-g -fno-range-check -fno-automatic -std=legacy -Llib
################################################################################
#all:       jobs nastran nasthelp nastplot chkfil ff
all:       jobs nastran
nastran:   obj bin libnas nasinfo bin/nastran.x
nasinfo:   NASINFO
libnas:    lib libnasmis libnasmds libnasmodmis lib/libnas.a
libnasmis: lib lib/libnasmis.a
libnasmds: lib lib/libnasmds.a
libnasmodmis:  lib lib/libnasmodmis.a
nasthelp:  obj bin bin/nasthelp.x
nastplot:  obj bin bin/nastplot.x
chkfil:    obj bin bin/chkfil.x
ff:        obj bin bin/ff.x
OUTPUT:
	mkdir -p OUTPUT
lib:
	mkdir -p lib
obj:
	mkdir -p obj
bin:
	mkdir -p bin
	cp um/*.TXT bin
clean:
	rm -rf bin obj lib
	rm -rf OUTPUT
	rm -f testnas.*
	rm -f dsnames.*
	rm -f NASINFO COS* RSCARDS
	rm -f fort.*
################################################################################
MISOBJ+=$(patsubst mis/%.f,obj/%.o,$(wildcard mis/*.f))
MDSOBJ+=$(patsubst mds/%.f,obj/%.o,$(wildcard mds/*.f))
MODMISBD+=$(patsubst modmis/%.f,obj/%.o,$(wildcard modmis/*.f))
################################################################################
lib/libnasmis.a: $(MISOBJ)
	$(AR) cr $@ $^
lib/libnasmds.a: $(MDSOBJ)
	$(AR) cr $@ $^
lib/libnasmodmis.a: $(MODMISBD)
	$(AR) cr $@ $^
lib/libnas.a: lib/libnasmis.a lib/libnasmds.a lib/libnasmodmis.a
	$(AR) crT $@ $^
bin/nastran.x: obj/nastrn.o
	$(F77) $(FLAGS) $^ -lnas -o $@    # Note that "-lnas" is after "$^"!
bin/nasthelp.x: obj/nasthelp.o
	$(F77) $(FLAGS) $^ -o $@
bin/nastplot.x: obj/nastplot.o
	$(F77) $(FLAGS) $^ -o $@
bin/ff.x: obj/ff.o 
	$(F77) $(FLAGS) $^ -lnas -o $@
bin/chkfil.x: obj/chkfil.o
	$(F77) $(FLAGS) $^ -o $@
NASINFO: sbin/NASINFO
	cp $^ $@
################################################################################
obj/%.o : modmis/%.f
	$(F77) $(FLAGS) -c $< -o $@
obj/%.o : mds/%.f
	$(F77) $(FLAGS) -c $< -o $@
obj/%.o : mis/%.f
	$(F77) $(FLAGS) -c $< -o $@
obj/%.o : src/%.f
	$(F77) $(FLAGS) -c $< -o $@
################################################################################
JOBS+=$(patsubst nid/%.nid,OUTPUT/%.f06,$(wildcard nid/*.nid))
################################################################################
COS=COSDBCL COSDDAM COSDFVA COSHYD1 COSHYD2 COSMFVA
jobs: nastran OUTPUT $(COS) $(JOBS)
################################################################################
COSDBCL: alt/cosdbcl.alt
	ln -s $^ $@
COSDDAM: alt/cosddam.alt
	ln -s $^ $@
COSDFVA: alt/cosdfva.alt
	ln -s $^ $@
COSHYD1: alt/coshyd1.alt
	ln -s $^ $@
COSHYD2: alt/coshyd2.alt
	ln -s $^ $@
COSMFVA: alt/cosmfva.alt
	ln -s $^ $@
################################################################################
OUTPUT/%.f06 : nid/%.nid
	./sbin/nastran.py -o OUTPUT $<
################################################################################
OUTPUT/d01011b.f06: nid/d01011b.nid OUTPUT/d01011a.f06
	ln -s OUTPUT/d01011a.dict RSCARDS
	./sbin/nastran.py -o OUTPUT --OPTPNM OUTPUT/d01011a.nptp $<
	rm -f RSCARDS
OUTPUT/d01011c.f06: nid/d01011c.nid OUTPUT/d01011a.f06
	ln -s OUTPUT/d01011a.dict RSCARDS
	./sbin/nastran.py -o OUTPUT --OPTPNM OUTPUT/d01011a.nptp $<
	rm -f RSCARDS
OUTPUT/d01021b.f06: nid/d01021b.nid OUTPUT/d01021a.f06
	ln -s OUTPUT/d01021a.dict RSCARDS
	./sbin/nastran.py -o OUTPUT --OPTPNM OUTPUT/d01021a.nptp $<
	rm -f RSCARDS
OUTPUT/d11011b.f06: nid/d11011b.nid OUTPUT/d11011a.f06
	ln -s OUTPUT/d11011a.dict RSCARDS
	./sbin/nastran.py -o OUTPUT --OPTPNM OUTPUT/d11011a.nptp $<
	rm -f RSCARDS
OUTPUT/t00001a.f06: nid/t00001a.nid
	./sbin/nastran.py -o OUTPUT --FTN15 nid/t00001a.inp1 --FTN16 nid/t00001a.inp2 $<
OUTPUT/t03111b.f06: nid/t03111b.nid OUTPUT/t03111a.f06
	ln -s OUTPUT/t03111a.dict RSCARDS
	./sbin/nastran.py -o OUTPUT --OPTPNM OUTPUT/t03111a.nptp $<
	rm -f RSCARDS
OUTPUT/t03121b.f06: nid/t03121b.nid OUTPUT/t03121a.f06
	ln -s OUTPUT/t03121a.dict RSCARDS
	./sbin/nastran.py -o OUTPUT --OPTPNM OUTPUT/t03121a.nptp $<
	rm -f RSCARDS
OUTPUT/t03121c.f06: nid/t03121c.nid OUTPUT/t03121a.f06
	ln -s OUTPUT/t03121a.dict RSCARDS
	./sbin/nastran.py -o OUTPUT --OPTPNM OUTPUT/t03121a.nptp $<
	rm -f RSCARDS
OUTPUT/t04021b.f06: nid/t04021b.nid OUTPUT/t04021a.f06
	ln -s OUTPUT/t04021a.dict RSCARDS
	./sbin/nastran.py -o OUTPUT --OPTPNM OUTPUT/t04021a.nptp $<
	rm -f RSCARDS
################################################################################
