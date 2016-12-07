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

icons: macosx/$(APPNAME)Icon.png appbundle
	rm -rf macosx/$(APPNAME).iconset
	mkdir -p macosx/$(APPNAME).iconset
	sips -z 16 16     macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_16x16.png
	sips -z 32 32     macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_16x16@2x.png
	sips -z 32 32     macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_32x32.png
	sips -z 64 64     macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_32x32@2x.png
	sips -z 128 128   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_128x128.png
	sips -z 256 256   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_128x128@2x.png
	sips -z 256 256   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_256x256.png
	sips -z 512 512   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_256x256@2x.png
	sips -z 512 512   macosx/Icon.png --out macosx/$(APPNAME).iconset/icon_512x512.png
	cp macosx/$(APPNAME)Icon.png macosx/$(APPNAME).iconset/icon_512x512@2x.png
	iconutil -c icns -o macosx/$(APPNAME).icns macosx/$(APPNAME).iconset
	cp macosx/$(APPNAME).icns $(APPBUNDLEICON)/
	sed -i. 's/GenericApp.icns/ZCashSwingWalletUI.icns/' $(APPBUNDLECONTENTS)/Info.plist
	rm $(APPBUNDLERESOURCES)/GenericApp.icns

flock: appbundle
	cp -f macosx/flock $(APPBUNDLEEXE)/flock

zcash-bin: appbundle
	cp macosx/zcash/src/zcashd $(APPBUNDLEEXE)/zcashd
	cp macosx/zcash/src/zcash-cli $(APPBUNDLEEXE)/zcash-cli
	cp macosx/zcash/zcutil/fetch-params.sh $(APPBUNDLEEXE)/
	dylibbundler -of -b -x $(APPBUNDLEEXE)/zcashd -d $(APPBUNDLE)/Contents/Frameworks/ -p @executable_path/../Frameworks/
	dylibbundler -of -b -x $(APPBUNDLEEXE)/zcash-cli -d $(APPBUNDLE)/Contents/Frameworks/ -p @executable_path/../Frameworks/

macapp: zcash-bin icons