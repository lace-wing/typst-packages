clean:
	find src/ -type f -name '*.pdf' -exec rm -f {} +
	rm -f template/*.pdf
	rm -f test/*.pdf

docs:
	typst compile docs/manual.typ docs/manual.pdf
	# typst compile --pages=1 --input theme=light docs/thumbnail.typ docs/thumbnail-light.svg
	# typst compile --pages=1 --input theme=dark docs/thumbnail.typ docs/thumbnail-dark.svg
	typst compile --pages=1 --input theme=light docs/thumbnail.typ docs/thumbnail.png

repo: docs clean
	rm -rf ~/src/my-typst/lacy-ieee-spectrum/*
	cp -r * ~/src/my-typst/lacy-ieee-spectrum/

