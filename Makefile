.PHONY: default
default: winapp ;

APPNAME=zcash4win
BUILD ?= $(shell git rev-list HEAD | wc -l|tr -d [:space:])
SHORTVERSION = 1.0.5
VERSION ?= $(SHORTVERSION)-$(BUILD)
winapp:
	cp src/build/build.xml src/build/build.xml.bak
	cp package/windows/zcash4win.iss package/windows/zcash4win.iss.bak
	sed -i "s/@version@/$(VERSION)/g" src/build/build.xml
	sed -i "s/@version@/$(VERSION)/g" package/windows/zcash4win.iss
	ant -f src/build/build.xml wininst
	mv src/build/build.xml.bak src/build/build.xml
	mv package/windows/zcash4win.iss.bak package/windows/zcash4win.iss

