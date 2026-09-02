.PHONY: typecheck demo cardano-check cardano-build

typecheck:
	npm run typecheck

demo:
	npm run demo

cardano-check:
	aiken check

cardano-build:
	aiken build
