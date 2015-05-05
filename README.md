Create the build
================

	osc login
	osc project default
    osc process -f application-template-dockerbuild.yaml | osc create -f -
	osc start-build oppslagstjenesten-build
	osc get builds
	osc build-logs oppslagstjeneste-build-1