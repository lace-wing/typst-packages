clean:
	find src/ -type f -name '*.pdf' -exec rm -f {} +
	# rm -f template/*.pdf
	rm -f test/*.pdf

repo: clean
	rm -rf ~/src/my-typst/lacy-wings/*
	cp -r * ~/src/my-typst/lacy-wings/

