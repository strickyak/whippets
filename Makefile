all:
	bash run-hasty.bash    hasty/[a-z]*.d  2>&1 | tee /tmp/whip
all-trace:
	bash run-hasty.bash -t hasty/[a-z]*.d  2>&1 | tee /tmp/whip

clean:
	rm -f $$(find * -type f -name ',*')  # comma temp files
	rm -f $$(find * -type f -name '_*')  # under temp files
