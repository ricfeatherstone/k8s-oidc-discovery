package main

import (
	"flag"
	"fmt"
	jwt2 "gopkg.in/square/go-jose.v2/jwt"
	"log"
	"oidc-demo/pkg/jwt"
	"strings"
	"time"
)

func main() {
	jwtString := flag.String("jwt", "", "jwt string")

	flag.Parse()

	claims, err := jwt.Claims(jwtString)
	if err != nil {
		log.Fatalln(err)
	}

	var b strings.Builder

	issuer := claims.Issuer

	b.WriteString("Token Claims:\n")
	b.WriteString(fmt.Sprintf("\tIssuer: %s\n", issuer))
	b.WriteString(fmt.Sprintf("\tAudience: %s\n", claims.Audience))
	b.WriteString(fmt.Sprintf("\tSubject: %s\n", claims.Subject))
	b.WriteString(fmt.Sprintf("\tIssuedAt: %s\n", format(claims.IssuedAt)))
	b.WriteString(fmt.Sprintf("\tNotBefore: %s\n", format(claims.NotBefore)))
	b.WriteString(fmt.Sprintf("\tExpiry: %s\n", format(claims.Expiry)))

	log.Println(b.String())
}

func format(date *jwt2.NumericDate) string {
	return date.Time().Format(time.RFC822)
}
