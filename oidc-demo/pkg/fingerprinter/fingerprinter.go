package fingerprinter

import (
	"bytes"
	"crypto/sha1"
	"crypto/tls"
	"fmt"
)

func Fingerprint(server *string, port *uint) (string, error) {
	conn, err := tls.Dial("tcp", fmt.Sprintf("%s:%d", *server, *port), &tls.Config{})
	defer func(conn *tls.Conn) {
		if err := conn.Close(); err != nil {
			panic(err)
		}
	}(conn)
	if err != nil {
		return "", err
	}

	certs := conn.ConnectionState().PeerCertificates
	cert := certs[len(certs)-1]

	fingerprint := sha1.Sum(cert.Raw)

	var buf bytes.Buffer
	for _, v := range fingerprint {
		fmt.Fprintf(&buf, "%02x", v)
	}

	return buf.String(), nil
}
