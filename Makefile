.PHONY: all clean distclean setup build doc install test
all: build

J ?= 2

setup.data: setup.bin
	./setup.bin -configure

setup.ml: _oasis
	oasis setup

distclean: setup.data setup.bin
	./setup.bin -distclean $(OFLAGS)
	$(RM) setup.bin

setup: setup.data

build: setup.data  setup.bin
	./setup.bin -build -j $(J) $(OFLAGS)

clean:
	ocamlbuild -clean
	rm -f setup.data setup.bin main.js

doc: setup.data setup.bin
	./setup.bin -doc -j $(J) $(OFLAGS)

setup.bin: setup.ml
	ocamlopt.opt -o $@ $< || ocamlopt -o $@ $< || ocamlc -o $@ $<
	$(RM) setup.cmx setup.cmi setup.o setup.cmo

install:
	./setup.bin -install

uninstall:
	./setup.bin -uninstall

reinstall:
	./setup.bin -uninstall
	./setup.bin -install

.PHONY: run
run:
	(cd example; cohttp-server-lwt)

VERSION = $(shell grep '^Version:' _oasis | sed 's/Version: *//')
NAME    = $(shell grep 'Name:' _oasis    | sed 's/Name: *//')
ARCHIVE = https://github.com/djs55/ocaml-c3/archive/v$(VERSION).tar.gz

release:
	git tag -a v$(VERSION) -m "Version $(VERSION)."
	git push upstream v$(VERSION)
	$(MAKE) pr

pr:
	opam publish prepare $(NAME).$(VERSION) $(ARCHIVE)
	OPAMYES=1 opam publish submit $(NAME).$(VERSION) && rm -rf $(NAME).$(VERSION)

iocamljs:
	jsoo_mktop -dont-export-unit unix -export-package iocamljs-kernel \
		-export-package c3 -export-package c3.notebook \
		-export-package lwt -export-package js_of_ocaml \
		-jsopt +weak.js -jsopt +toplevel.js -o iocaml.byte
	cat *.cmis.js \
		`opam config var lib`/iocamljs-kernel/kernel.js iocaml.js > \
		iocaml_c3.js
	-rm -f iocaml.js *.cmis.js

