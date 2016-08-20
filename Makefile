HS = $(shell find src -type f -name '*.hs')
# Dummy target
CHS = $(subst hs,chs,$(HS))

LIQUID ?= stack exec liquid --

all: check build

build:
	stack build

check: $(CHS)

%.chs: %.hs
	$(LIQUID) -i src $<

clean:
	find . -type d -name '.liquid' -exec rm -rf {} \+
	stack clean

.PHONY: build check clean
