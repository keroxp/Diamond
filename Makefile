WORKSPACE = Diamond.xcworkspace
BUILD_SCHEME = Diamond
EXAMPLE_TARGET = DiamondExpample

default: clean setup test

clean:
	xcodebuild clean \
		-workspace $(WORKSPACE) \
		-scheme $(BUILD_SCHEME)
setup:
	./script/bootstrap

test:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(BUILD_SCHEME) \
		-sdk iphonesimulator \
		TEST_AFTER_BUILD=YES \
		TEST_HOST=

test-with-coverage:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(BUILD_SCHEME) \
		-sdk iphonesimulator \
		TEST_AFTER_BUILD=YES \
		TEST_HOST= \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES

send-coverage:
	coveralls \
		 -e DiamondTests,DiamondExpample
