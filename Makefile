PROJECT = Diamond.xcodeproj
BUILD_TARGET = Diamond
EXAMPLE_TARGET = DiamondExpample

default: clean setup test

clean:
	xcodebuild clean \
		-project $(PROJECT) \
		-target $(BUILD_TARGET)
setup:
	./script/bootstrap

test:
	xcodebuild \
		-project $(PROJECT) \
		-target $(BUILD_TARGET) \
		-sdk iphonesimulator \
		TEST_AFTER_BUILD=YES \
		TEST_HOST=

test-with-coverage:
	xcodebuild \
		-project $(PROJECT) \
		-target $(BUILD_TARGET) \
		-sdk iphonesimulator \
		-configuration Debug \
		ONLY_ACTIVE_ARCH=NO \
		TEST_AFTER_BUILD=YES \
		TEST_HOST= \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES

send-coverage:
	coveralls \
		 -e DiamondTests,DiamondExpample
