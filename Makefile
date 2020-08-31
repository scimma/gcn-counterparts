CPURL    := https://gcn.gsfc.nasa.gov/counterpart_tbl.html
CPTABLE  := counterpart_tbl.html
CPDIR    := cpdir
HOPTOPIC := kafka://dev.hop.scimma.org/lvc-counterpart

all: $(CPDIR)

.PHONY := publish

$(CPTABLE):
	curl -s -o $(CPTABLE) $(CPURL)

$(CPDIR): $(CPTABLE)
	mkdir $(CPDIR)
	cat $< |./scripts/parseCounterparts.pl

publish:
	cd $(CPDIR) && ls | sort | xargs hop publish $(HOPTOPIC)

clean:
	rm -rf $(CPDIR)
	rm -f $(CPTABLE)
