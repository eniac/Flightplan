all: eager.pdf chain.pdf

%.pdf: %.dot
	dot $^ -Kfdp -Tpdf -o $@
