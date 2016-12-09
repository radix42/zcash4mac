.PHONY: default
default: macapp ;

APPNAME=ZCashSwingWalletUI
APPBUNDLE=build/osxapp/ZCashSwingWalletUI.app
APPBUNDLECONTENTS=$(APPBUNDLE)/Contents
APPBUNDLEEXE=$(APPBUNDLECONTENTS)/MacOS
APPBUNDLERESOURCES=$(APPBUNDLECONTENTS)/Resources
APPBUNDLEICON=$(APPBUNDLECONTENTS)/Resources
appbundle: 
	ant -f src/build/build.xml osxbundle
	mkdir -p $(APPBUNDLE)/Contents/Frameworks
	cp macosx/first-run.sh $(APPBUNDLEEXE)/
	cp macosx/logging.properties $(APPBUNDLEEXE)/

icons: macosx/$(APPNAME)Icon.png appbundle
#	rm -rf macosx/$(APPNAME).iconset
#	mkdir -p macosx/$(APPNAME).iconset
#	sips -z 16 16     macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_16x16.png
#	sips -z 32 32     macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_16x16@2x.png
#	sips -z 32 32     macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_32x32.png
#	sips -z 64 64     macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_32x32@2x.png
#	sips -z 128 128   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_128x128.png
#	sips -z 256 256   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_128x128@2x.png
#	sips -z 256 256   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_256x256.png
#	sips -z 512 512   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_256x256@2x.png
#	sips -z 512 512   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_512x512.png
#	cp macosx/$(APPNAME)Icon.png macosx/$(APPNAME).iconset/icon_512x512@2x.png
#	iconutil -c icns -o macosx/$(APPNAME).icns macosx/$(APPNAME).iconset
	cp macosx/$(APPNAME).icns $(APPBUNDLEICON)/
	sed -i.bak 's/GenericApp.icns/ZCashSwingWalletUI.icns/' $(APPBUNDLECONTENTS)/Info.plist
	rm $(APPBUNDLECONTENTS)/Info.plist.bak
	rm $(APPBUNDLERESOURCES)/GenericApp.icns

zcash-bin: appbundle
	cp macosx/zcash/src/zcashd $(APPBUNDLEEXE)/zcashd
	cp macosx/zcash/src/zcash-cli $(APPBUNDLEEXE)/zcash-cli
	dylibbundler -of -b -x $(APPBUNDLEEXE)/zcashd -d $(APPBUNDLE)/Contents/Frameworks/ -p @executable_path/../Frameworks/
	dylibbundler -of -b -x $(APPBUNDLEEXE)/zcash-cli -d $(APPBUNDLE)/Contents/Frameworks/ -p @executable_path/../Frameworks/

macapp: zcash-bin icons

################################################################################
# Customizable variables for dmg generation
################################################################################

NAME ?= $(APPNAME)
VERSION ?= 1.0.3

SOURCE_DIR ?= build/osxapp
SOURCE_FILES ?= $(NAME).app

TEMPLATE_DMG ?= template.dmg
TEMPLATE_SIZE ?= 250m

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
