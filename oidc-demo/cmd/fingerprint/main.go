package main

import (
	"flag"
	"fmt"
	"oidc-demo/pkg/fingerprinter"
)

func main() {
	server := flag.String("server", "", "server to fingerprint")
	port := flag.Uint("port", 443, "tls port")

	flag.Parse()

	s, err := fingerprinter.Fingerprint(server, port)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(s)
}
