#
# Makefile for building AgaOS
#
# Requires:
#
# smake (SAS/C, GNU make currently not supported)
# PhxAss (aminet)
# rm (GNU, GeekGadgets distro)
# join (AmigaOS)
# rx (AmigaOS)
#
# When converting to GCC-type a.out library:
#
# hunk2aout
# ar
#
# Extra programs when building examples:
#
# PhxLnk (latest version prefered)
#
# Extra programs to generate documentation:
#
# autodoc (NDK)
# ADtoHT (aminet)
# rename (AmigaOS)

#
# Used paths
#

OBJDIR = obj
SRCDIR = src
BINDIR = bin

#
# Programs
#

PHXASS = SYS:C/PhxAss
PHXLNK = SYS:C/PhxLnk
RX = SYS:RexxC/RX
ADTOHT = SYS:C/ADtoHT
RM = rm -f
RENAME = rename
AUTODOC = SYS:C/autodoc
AR = ar
JOIN = SYS:C/join

GCCSTART=$(BINDIR)/crt0.o

#
#.c.o:
#	gcc -c $< -o $@ -I. -O2 -fstrength-reduce -fomit-frame-pointer
#

OBJS = $(SRCDIR)/math.o $(SRCDIR)/libraries.o $(SRCDIR)/input.o \
$(SRCDIR)/file.o $(SRCDIR)/fade.o $(SRCDIR)/copper.o $(SRCDIR)/vector.o \
$(SRCDIR)/vbl.o $(SRCDIR)/system.o $(SRCDIR)/startup.o $(SRCDIR)/screen.o \
$(SRCDIR)/mem.o $(SRCDIR)/audio.o

#
# Output: Generating standard library
#
$(BINDIR)/agaos.lib: $(OBJS)
#	$(MAKE) -C $(SRCDIR) -f Makefile all
	$(JOIN) $(OBJS) as $@

gcclib: $(BINDIR)/libagaos.a extra/crt0.S
	gcc -c -o $(BINDIR)/crt0.o extra/crt0.S

$(BINDIR)/libagaos.a: $(BINDIR)/agaos.lib
	hunk2aout $<
	$(RM) $@
	$(AR) r $@ obj.*
	$(RM) obj.*

examples: $(OBJDIR)/examples/example.o $(OBJDIR)/examples/vectortest.o $(OBJDIR)/examples/ctest.o
	$(PHXLNK) TO $(BINDIR)/examples/example FROM $(OBJDIR)/examples/example.o LIB $(BINDIR)/agaos.lib KICK1
	$(PHXLNK) TO $(BINDIR)/examples/vectortest FROM $(OBJDIR)/examples/vectortest.o LIB $(BINDIR)/agaos.lib KICK1
	gcc -o $(BINDIR)/examples/ctest $(GCCSTART) $(OBJDIR)/examples/ctest.o -Lbin -lagaos -nostartfiles -noixemul -nostdlib

$(OBJDIR)/examples/example.o: $(SRCDIR)/examples/example.s
	$(PHXASS) FROM $< TO $@ OPT ! NOEXE DS DL
$(OBJDIR)/examples/vectortest.o: $(SRCDIR)/examples/vectortest.s
	$(PHXASS) FROM $< TO $@ OPT ! NOEXE DS DL
$(OBJDIR)/examples/ctest.o: $(SRCDIR)/examples/ctest.c
	gcc -c $< -o $@ -I. -O2 -fstrength-reduce -fomit-frame-pointer

$(SRCDIR)/math.o:
	$(MAKE) -C $(SRCDIR) math.o
$(SRCDIR)/libraries.o:
	$(MAKE) -C $(SRCDIR) libraries.o
$(SRCDIR)/input.o:
	$(MAKE) -C $(SRCDIR) input.o
$(SRCDIR)/file.o:
	$(MAKE) -C $(SRCDIR) file.o
$(SRCDIR)/fade.o:
	$(MAKE) -C $(SRCDIR) fade.o
$(SRCDIR)/copper.o:
	$(MAKE) -C $(SRCDIR) copper.o
$(SRCDIR)/vector.o:
	$(MAKE) -C $(SRCDIR) vector.o
$(SRCDIR)/vbl.o:
	$(MAKE) -C $(SRCDIR) vbl.o
$(SRCDIR)/system.o:
	$(MAKE) -C $(SRCDIR) system.o
$(SRCDIR)/startup.o:
	$(MAKE) -C $(SRCDIR) startup.o
$(SRCDIR)/screen.o:
	$(MAKE) -C $(SRCDIR) screen.o
$(SRCDIR)/mem.o:
	$(MAKE) -C $(SRCDIR) mem.o
$(SRCDIR)/audio.o:
	$(MAKE) -C $(SRCDIR) audio.o

autodoc:
	$(MAKE) -C $(SRCDIR) autodoc
	$(AUTODOC) -I -s -t7 src/agaos.s > agaos.doc
	$(ADTOHT) DOC "" HDOC "" INC $(SRCDIR)/ HINC $(SRCDIR)/ >NIL:
	@$(RM) agaos.guide
	@$(RENAME) agaos agaos.guide
	@$(RM) $(SRCDIR)/agaos.s

clean: objclean
	$(RM) $(BINDIR)/*.lib $(BINDIR)/examples/* $(BINDIR)/*.o $(BINDIR)/*.a

objclean:
	$(MAKE) -C $(SRCDIR) objclean

package:
	$(RM) ../agaos.lha
	echo "cd /*nlha a -r -e agaos.lha agaos" > T:.agaos_archiver
	execute T:.agaos_archiver
	$(RM) T:.agaos_archiver
