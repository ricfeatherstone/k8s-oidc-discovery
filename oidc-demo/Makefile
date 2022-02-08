build-tools:
	for i in fingerprint claims oidc-discovery; do \
		go build -o bin/$$i cmd/$$i/main.go; \
	done
