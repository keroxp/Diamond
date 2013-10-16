WORKSPACE = Diamond.xcworkspace
PROJECT = Diamond.xcodeproj
TEST_SCHEME = DiamondTests
BUILD_TARGET = Diamond
EXAMPLE_TARGET = DiamondExpample

default: clean test

clean:
	xcodebuild clean \
		-workspace $(WORKSPACE) \
		-scheme $(TEST_SCHEME)

test:
	./script/bootstrap
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(TEST_SCHEME) \
		-sdk iphonesimulator \
		TEST_AFTER_BUILD=YES \
		TEST_HOST=

test-with-coverage:
	./script/bootstrap
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(TEST_SCHEME) \
			-sdk iphonesimulator \
			TEST_AFTER_BUILD=YES \
			TEST_HOST= \
			GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
			GCC_GENERATE_TEST_COVERAGE_FILES=YES

send-coverage:
	coveralls \
		 -e DiamondTests,DiamondExpample
