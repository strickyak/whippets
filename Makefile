all:
	bash -exo pipefail -c 'bash run-hasty.bash    hasty/[a-z]*.d' 2>&1 | tee _out
all-trace:
	bash -exo pipefail -c 'bash run-hasty.bash -t hasty/[a-z]*.d' 2>&1 | tee _out

clean:
	rm -f $$(find * -type f -name ',*')  # comma temp files
	rm -f $$(find * -type f -name '_*')  # under temp files
