PROJECT = Diamond.xcodeproj
BUILD_SCHEME = Diamond
EXAMPLE_TARGET = DiamondExpample
iOSUNIVERSAL = Diamond-iOS

default: clean setup test-with-coverage

clean:
	xcodebuild clean \
		-project $(PROJECT) \
		-scheme $(BUILD_SCHEME)
setup:
	./script/bootstrap

test-with-coverage:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(BUILD_SCHEME) \
		-sdk iphonesimulator \
		TEST_AFTER_BUILD=YES \
		TEST_HOST= \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES

send-coverage:
	coveralls \
		 -e DiamondTests,DiamondExpample

ios-universal:
	xctool \
		-project $(PROJECT) \
		-scheme $(iOSUNIVERSAL) \
