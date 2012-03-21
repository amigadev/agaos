
OBJS =  math.o libraries.o input.o file.o fade.o copper.o vector.o vbl.o system.o startup.o screen.o mem.o audio.o



PHXASS = SYS:C/PhxAss
JOIN = SYS:C/Join
RM = rm -f

.s.o:
	$(PHXASS) FROM $< TO $@ OPT ! NOEXE DL DS I /

all: $(OBJS)

audio.o: audio/Streaming.o
	$(JOIN) $*/*.o as $@

math.o: math/SetupMath.o math/RemoveMath.o
	$(JOIN) $*/*.o as $@

libraries.o: libraries/OpenLibraries.o libraries/CloseLibraries.o
	$(JOIN) $*/*.o as $@

input.o: input/RemoveInputHandler.o input/InstallInputHandler.o input/InputHandler.o
	$(JOIN) $*/*.o as $@

file.o: file/FileLoad.o
	$(JOIN) $*/*.o as $@

fade.o: fade/LoadColors.o fade/GeneratePalettes.o fade/DoFade.o fade/BeginFade.o
	$(JOIN) $*/*.o as $@

copper.o: copper/WriteCopperPtrs.o copper/BuildDisplay.o
	$(JOIN) $*/*.o as $@

vector.o: vector/Translate.o vector/Scale.o vector/Rotate.o vector/Multiply.o vector/Invert.o vector/Identity.o vector/Apply.o
	$(JOIN) $*/*.o as $@

vbl.o: vbl/WaitVBL.o vbl/SetupVBL.o vbl/RemoveVBLHook.o vbl/RemoveVBL.o vbl/MainVBLInterrupt.o vbl/InstallCopper.o vbl/AttachVBLHook.o
	$(JOIN) $*/*.o as $@

system.o: system/CheckSystem.o
	$(JOIN) $*/*.o as $@

startup.o: startup/Startup.o startup/Shutdown.o
	$(JOIN) $*/*.o as $@

screen.o: screen/InstallScreen.o screen/RemoveScreen.o
	$(JOIN) $*/*.o as $@

mem.o: mem/SetupMemory.o mem/RemoveMemory.o mem/MemFree.o mem/MemCopy.o mem/MemClear.o mem/MemAlloc.o
	$(JOIN) $*/*.o as $@

objclean:
	$(RM) copper/*.o fade/*.o file/*.o input/*.o libraries/*.o
	$(RM) math/*.o mem/*.o screen/*.o startup/*.o system/*.o
	$(RM) vbl/*.o vector/*.o audio/*.o *.o

autodoc:
	$(JOIN) to agaos.s copper/*.s fade/*.s file/*.s input/*.s libraries/*.s math/*.s mem/*.s screen/*.s startup/*.s system/*.s vbl/*.s vector/*.s audio/*.s
