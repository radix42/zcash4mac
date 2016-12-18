.PHONY: default
default: macapp ;

APPNAME=zcash4mac
APPBUNDLE=build/osxapp/zcash4mac.app
APPBUNDLECONTENTS=$(APPBUNDLE)/Contents
APPBUNDLEEXE=$(APPBUNDLECONTENTS)/MacOS
APPBUNDLERESOURCES=$(APPBUNDLECONTENTS)/Resources
APPBUNDLEICON=$(APPBUNDLECONTENTS)/Resources
BUILD ?= $(shell git rev-list HEAD | wc -l|tr -d [:space:])
SHORTVERSION = 1.0.4
VERSION ?= $(SHORTVERSION)-$(BUILD)
appbundle: zcash-bin
	sed -i '.bak' 's/@version@/'"$(VERSION)"'/' src/build/build.xml
	sed -i '.bak' 's/@shortversion@/'"$(SHORTVERSION)"'/; s/@build@/'"$(BUILD)"'/' package/macosx/Info.plist
	ant -f src/build/build.xml osxbundle
	mv src/build/build.xml.bak src/build/build.xml
	mv package/macosx/Info.plist.bak package/macosx/Info.plist
#	mkdir -p $(APPBUNDLE)/Contents/Frameworks
#	cp macosx/first-run.sh $(APPBUNDLEEXE)/
#	cp macosx/logging.properties $(APPBUNDLEEXE)/
#	rm $(APPBUNDLECONTENTS)/PlugIns/jdk1.8.0_77.jdk/Contents/Home/jre/lib/libjfxmedia_qtkit.dylib

icons: macosx/$(APPNAME)Icon.png appbundle
	cp macosx/$(APPNAME).icns $(APPBUNDLEICON)/
	sed -i '' 's/GenericApp.icns/zcash4mac.icns/' $(APPBUNDLECONTENTS)/Info.plist
	rm $(APPBUNDLERESOURCES)/GenericApp.icns

zcash-bin:
	cp macosx/zcash/src/zcashd macosx/zcashd
	cp macosx/zcash/src/zcash-cli macosx/zcash-cli
	dylibbundler -of -b -x macosx/zcashd -d macosx/ -p @executable_path/
	dylibbundler -of -b -x macosx/zcash-cli -d macosx/ -p @executable_path/

macapp: appbundle

################################################################################
# Customizable variables for dmg generation
################################################################################

NAME ?= $(APPNAME)




SOURCE_DIR ?= build/osxapp
SOURCE_FILES ?= $(NAME).app

TEMPLATE_DMG ?= template.dmg
TEMPLATE_SIZE ?= 200m

################################################################################
# DMG building. No editing should be needed beyond this point.
################################################################################

MASTER_DMG=$(NAME)-$(VERSION).dmg
WC_DMG=wc.dmg
WC_DIR=wc

.PHONY: dmg
dmg: $(MASTER_DMG)

$(TEMPLATE_DMG): $(TEMPLATE_DMG).bz2
	bunzip2 -k $<

$(TEMPLATE_DMG).bz2: 
	@echo
	@echo --------------------- Generating empty template --------------------
	mkdir template
	hdiutil create -fs HFSX -layout SPUD -size $(TEMPLATE_SIZE) "$(TEMPLATE_DMG)" -srcfolder template -format UDRW -volname "$(NAME)" -quiet
	rmdir template
	bzip2 "$(TEMPLATE_DMG)"
	@echo

$(WC_DMG): $(TEMPLATE_DMG)
	cp $< $@

$(MASTER_DMG): $(WC_DMG) $(addprefix $(SOURCE_DIR)/,$(SOURCE_FILES))
	@echo
	@echo --------------------- Creating Disk Image --------------------
	mkdir -p $(WC_DIR)
	hdiutil attach "$(WC_DMG)" -noautoopen -quiet -mountpoint "$(WC_DIR)"
	for i in $(SOURCE_FILES); do  \
		rm -rf "$(WC_DIR)/$$i"; \
		ditto -rsrc "$(SOURCE_DIR)/$$i" "$(WC_DIR)/$$i"; \
	done
	#rm -f "$@"
	#hdiutil create -srcfolder "$(WC_DIR)" -format UDZO -imagekey zlib-level=9 "$@" -volname "$(NAME) $(VERSION)" -scrub -quiet
	WC_DEV=`hdiutil info | grep "$(WC_DIR)" | grep "Apple_HFS" | awk '{print $$1}'` && \
	hdiutil detach $$WC_DEV -quiet -force
	rm -f "$(MASTER_DMG)"
	hdiutil convert "$(WC_DMG)" -quiet -format UDZO -imagekey zlib-level=9 -o "$@"
	rm -rf $(WC_DIR)
	@echo

.PHONY: clean
clean:
	-rm -rf $(TEMPLATE_DMG) $(MASTER_DMG) $(WC_DMG)
