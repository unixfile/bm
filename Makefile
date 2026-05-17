NAME   := bm
PREFIX ?= $(HOME)/.local
BINDIR  = $(PREFIX)/bin

.PHONY: install man test clean

install:
	install -Dm755 bin/$(NAME) $(BINDIR)/$(NAME)

man:
	grep -v '^\[!\[' README.md | pandoc -s -t man \
		-V title=$(NAME) -V section=1 \
		-V date="$(shell date +%Y-%m-%d)" \
		-o $(NAME).1

test:
	bats bm.bats

clean:
	rm -f $(NAME).1
