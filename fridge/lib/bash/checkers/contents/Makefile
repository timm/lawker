
SHELL = /bin/sh

PLAYER_SRC = vc-define.awk vc-run.awk vc-board.awk vc-util.awk

srcdir = .
testdir = test

TRANSCRIPT = ./transcript
DEBUG_OUTPUT = ./debug

.PHONY: all play play_deps clean clobber results run% test_connected
.SUFFIXES: .awk .sh

all: vc1 vc2 vc3 vc4 vc5

## GNU Make has a great implicit "Rule" that converts *.sh to
## executable programs

vc%.awk: $(PLAYER_SRC) vc%-ai.awk
	cat $^ > $@

vc%.sh: vc%.awk gawk2sh.bash
	$(srcdir)/gawk2sh.bash $< '-v my_color=$$1' > $@

board.sh: board.awk gawk2sh.bash
	$(srcdir)/gawk2sh.bash $< '-v player1=$$1 -v player2=$$2' > $@

play_deps: board $(PLAYER1) $(PLAYER2)
	@test "$(srcdir)/$(PLAYER1)" != "" \
	  || echo PLAYER1 not specified. \
	    && test "$(srcdir)/$(PLAYER1)" != ""
	@test "$(srcdir)/$(PLAYER2)" != "" \
	  || echo PLAYER2 not specified. \
	    && test "$(srcdir)/$(PLAYER2)" != ""

play: play_deps
	$(srcdir)/board $(srcdir)/$(PLAYER1) $(srcdir)/$(PLAYER2) 2> $(DEBUG_OUTPUT) \
          | tee $(TRANSCRIPT) | grep -e '^-' -e 'Number of plays:'
#          || cat $(DEBUG_OUTPUT)

### TESTS

${testdir}/is_connected.awk: vc-define.awk vc-board.awk ${testdir}/vc-board-run.awk vc-util.awk
	cat $^ > $@

${testdir}/is_connected.sh: ${testdir}/is_connected.awk gawk2sh.bash
	$(srcdir)/gawk2sh.bash $< > $@

test_connected: ${testdir}/is_connected
	sed -e 's/#DEBUG //' ${testdir}/board1 | $(srcdir)/$<
	sed -e 's/#DEBUG //' ${testdir}/board2 | $(srcdir)/$<
	sed -e 's/#DEBUG //' ${testdir}/board3 | $(srcdir)/$<
	sed -e 's/#DEBUG //' ${testdir}/board4 | $(srcdir)/$<

run%: play_deps # RunX is a way to test different heuristics. note: $* == X
	for i in `seq 1 $*`; do \
		$(MAKE) $(MFLAGS) PLAYER1=$(PLAYER1) PLAYER2=$(PLAYER2) play \
		  && cp $(TRANSCRIPT) $(TRANSCRIPT)$${i}a \
		  && cp $(DEBUG_OUTPUT) $(DEBUG_OUTPUT)$${i}a \
		  && $(MAKE) $(MFLAGS) PLAYER1=$(PLAYER2) PLAYER2=$(PLAYER1) play \
		  && cp $(TRANSCRIPT) $(TRANSCRIPT)$${i}b \
		  && cp $(DEBUG_OUTPUT) $(DEBUG_OUTPUT)$${i}b; \
	done;

results:
	@grep -h -e '^-' -e '^Number' $(TRANSCRIPT)*[ab] \
	  | gawk '/^-/ {gsub(/[)(]/, "", $$6); player = $$6; winner = $$5;} /^Number/ { n_plays = gensub(/[^0-9]*([0-9]*)$$/, "\\1", 1); print player, n_plays, winner;}' \
	  | sort -k 1,1 -k 2,2rn;

### CLEAN

clean:
	$(RM) $(DEBUG_OUTPUT)* $(TRANSCRIPT)*
	$(RM) board
	$(RM) vc1 vc2 vc3 vc4
	$(RM) ${testdir}/is_connected
	$(RM) *~ # Emacs back-ups

clobber: clean
	## Files are under version control.
	$(RM) *.awk ${testdir}/*.awk
	$(RM) gawk2sh.bash
	$(RM) Makefile
