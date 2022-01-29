PREFIX ?= /usr

all:

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@mkdir -p $(DESTDIR)$(PREFIX)/lib/canary
	@mkdir -p $(DESTDIR)$(PREFIX)/var/canary
	@mkdir -p $(DESTDIR)$(PREFIX)/etc/canary
	@cp -p bin/canary $(DESTDIR)$(PREFIX)/bin
	@cp -p lib/canary/* $(DESTDIR)$(PREFIX)/lib/canary
	@cp -p etc/canary/* $(DESTDIR)$(PREFIX)/etc/canary

uninstall:
	@rm -f $(DESTDIR)$(PREFIX)/bin/canary
	@rm -rf $(DESTDIR)$(PREFIX)/lib/canary
