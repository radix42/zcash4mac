.PHONY: default
default: winapp ;

APPNAME=winzec
BUILD ?= $(shell git rev-list HEAD | wc -l|tr -d [:space:])
SHORTVERSION = 1.0.12
VERSION ?= $(SHORTVERSION)-$(BUILD)
winapp:
	cp src/build/build.xml src/build/build.xml.bak
	cp package/windows/winzec.iss package/windows/winzec.iss.bak
	sed -i "s/@version@/$(VERSION)/g" src/build/build.xml
	sed -i "s/@version@/$(VERSION)/g" package/windows/winzec.iss
	ant -f src/build/build.xml wininst
	mv src/build/build.xml.bak src/build/build.xml
	mv package/windows/winzec.iss.bak package/windows/winzec.iss

