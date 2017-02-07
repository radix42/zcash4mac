.PHONY: default
default: winapp ;

APPNAME=zcash4win
BUILD ?= $(shell git rev-list HEAD | wc -l|tr -d [:space:])
SHORTVERSION = 1.0.5
VERSION ?= $(SHORTVERSION)-$(BUILD)
winapp:
	sed -i '.bak' 's/@version@/'"$(VERSION)"'/' src/build/build.xml
	ant -f src/build/build.xml wininst
	mv src/build/build.xml.bak src/build/build.xml
#	cp macosx/first-run.sh $(APPBUNDLEEXE)/
#	cp macosx/logging.properties $(APPBUNDLEEXE)/
#	rm $(APPBUNDLECONTENTS)/PlugIns/jdk1.8.0_77.jdk/Contents/Home/jre/lib/libjfxmedia_qtkit.dylib

#icons: macosx/$(APPNAME)Icon.png appbundle
#	cp macosx/$(APPNAME).icns $(APPBUNDLEICON)/
#	sed -i '' 's/GenericApp.icns/zcash4mac.icns/' $(APPBUNDLECONTENTS)/Info.plist
#	rm $(APPBUNDLERESOURCES)/GenericApp.icns



