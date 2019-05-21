.PHONY: docs test clean gh-pages

test:
	pytest src --doctest-modules --verbose
	pytest --cov=src --cov-report html:htmlcov tests --verbose
	pycodestyle tests
	pycodestyle src

docs: html

html: apidocs
	echo ".. Note, this was autogenerated, all changes will vanish...\n" > docs/api-methods.rst
	echo "Available JSON-RPC methods\n==========================\n\n" >> docs/api-methods.rst
	echo ".. attention::\n" >> docs/api-methods.rst
	echo "    Only supported for Python versions 3.6 and above\n\n" >> docs/api-methods.rst
	benchmarkstt-tools api --list-methods >> docs/api-methods.rst
	cd docs/ && make clean html

clean:
	cd docs/ && make clean

gh-pages: docs
	TMPDIR=`mktemp -d` || exit 1; \
	trap 'rm -rf "$$TMPDIR"' EXIT; \
	echo $$TMPDIR; \
	GITORIGIN=https://github.com/ebu/benchmarkstt.git ; \
	git clone "$$GITORIGIN" -b gh-pages --single-branch "$$TMPDIR"; \
	rm -r "$$TMPDIR/"*; \
	cp -r docs/build/html/* "$$TMPDIR"; \
	cd "$$TMPDIR" ;\
	touch .nojekyll; \
	git add -A && git commit -a -m 'update docs' && git push --set-upstream origin gh-pages

apidocs:
	ls docs/modules/|grep '.rst$$' && rm docs/modules/*.rst || echo "no .rst files to clean"
	sphinx-apidoc -f -e -o docs/modules/ src/benchmarkstt/ && rm docs/modules/modules.rst
