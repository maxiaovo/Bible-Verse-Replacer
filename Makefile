APP_NAME := BibleVerseReplacer
BUILD_DIR := .build
APP_DIR := $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR := $(APP_DIR)/Contents
MACOS_DIR := $(CONTENTS_DIR)/MacOS
RESOURCES_DIR := $(CONTENTS_DIR)/Resources
ARCH := $(shell uname -m)
SOURCES := $(shell find Sources/BibleVerseReplacer -name '*.swift' | sort)
TARGET := $(ARCH)-apple-macos13.0

.PHONY: app run debug data update-data test clean

data:
	python3 Scripts/import_cmn_cu89s.py

update-data:
	python3 Scripts/import_cmn_cu89s.py --refresh

app: data
	rm -rf "$(APP_DIR)"
	mkdir -p "$(MACOS_DIR)" "$(RESOURCES_DIR)"
	cp Info.plist "$(CONTENTS_DIR)/Info.plist"
	rsync -a Resources/ "$(RESOURCES_DIR)/"
	swiftc \
		-target $(TARGET) \
		-O \
		-framework AppKit \
		-framework ApplicationServices \
		-framework Carbon \
		-framework ServiceManagement \
		-framework UserNotifications \
		-o "$(MACOS_DIR)/$(APP_NAME)" \
		$(SOURCES)
	codesign --force --deep --sign - "$(APP_DIR)"

debug: data
	rm -rf "$(APP_DIR)"
	mkdir -p "$(MACOS_DIR)" "$(RESOURCES_DIR)"
	cp Info.plist "$(CONTENTS_DIR)/Info.plist"
	rsync -a Resources/ "$(RESOURCES_DIR)/"
	swiftc \
		-target $(TARGET) \
		-g \
		-framework AppKit \
		-framework ApplicationServices \
		-framework Carbon \
		-framework ServiceManagement \
		-framework UserNotifications \
		-o "$(MACOS_DIR)/$(APP_NAME)" \
		$(SOURCES)
	codesign --force --deep --sign - "$(APP_DIR)"

run: app
	open "$(APP_DIR)"

test: app
	"$(MACOS_DIR)/$(APP_NAME)" --self-test

clean:
	rm -rf "$(BUILD_DIR)"
