package main

import (
	"flag"
	"fmt"
	"log"
	"oidc-demo/pkg/jwt"
	"oidc-demo/pkg/oidc"
	"strings"
)

func main() {
	jwtString := flag.String("jwt", "", "jwt string")

	flag.Parse()

	claims, err := jwt.Claims(jwtString)
	if err != nil {
		log.Fatalln(err)
	}

	issuer := claims.Issuer

	discoveryDoc, err := oidc.LoadOpenIdDiscoveryDocument(issuer)
	if err != nil {
		log.Fatalln(err)
	}

	jsonWebKeySetUri := discoveryDoc.JsonWebKeySetUri
	var b strings.Builder

	b.WriteString("OIDC Discovery Document:\n")
	b.WriteString(fmt.Sprintf("\tJsonWebKeySetUri: %s\n", jsonWebKeySetUri))
	b.WriteString(fmt.Sprintf("\tResponseTypesSupported: %s\n", discoveryDoc.ResponseTypesSupported))
	b.WriteString(fmt.Sprintf("\tSubjectTypesSupported: %s\n", discoveryDoc.SubjectTypesSupported))
	b.WriteString(fmt.Sprintf("\tIdTokenSigningAlgorithmsSupported: %s\n", discoveryDoc.IdTokenSigningAlgorithmsSupported))
	b.WriteString(fmt.Sprintf("\tClaimsSupported: %s\n", discoveryDoc.ClaimsSupported))
	b.WriteString(fmt.Sprintf("\tGrantsSupported: %s\n", discoveryDoc.GrantsSupported))

	jsonWebKeySet, err := oidc.LoadJsonWebKeySet(jsonWebKeySetUri)
	if err != nil {
		log.Fatalln(err)
	}

	for _, jsonWebKey := range jsonWebKeySet.Keys {
		b.WriteString("JSON Web Key:\n")
		b.WriteString(fmt.Sprintf("\tKeyId: %s\n", jsonWebKey.KeyId))
		b.WriteString(fmt.Sprintf("\tKeyType: %s\n", jsonWebKey.KeyType))
		b.WriteString(fmt.Sprintf("\tAlgorithm: %s\n", jsonWebKey.Algorithm))
		b.WriteString(fmt.Sprintf("\tUse: %s\n", jsonWebKey.Use))
		b.WriteString(fmt.Sprintf("\tN: %s\n", jsonWebKey.N))
		b.WriteString(fmt.Sprintf("\tE: %s\n", jsonWebKey.E))
	}

	log.Println(b.String())
}