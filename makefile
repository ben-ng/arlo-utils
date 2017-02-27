.PHONY: test

test:
	./test.sh | diff ./test-expected.txt -
