package oidc

import (
	"encoding/json"
	"io"
	"net/http"
	"strings"
)

const (
	pathSeparator   = "/"
	wellKnownSuffix = ".well-known/openid-configuration"
)

type OpenIdDiscoveryDocument struct {
	Issuer                            string   `json:"issuer"`
	JsonWebKeySetUri                  string   `json:"jwks_uri"`
	ResponseTypesSupported            []string `json:"response_types_supported"`
	SubjectTypesSupported             []string `json:"subject_types_supported"`
	IdTokenSigningAlgorithmsSupported []string `json:"id_token_signing_alg_values_supported"`
	ClaimsSupported                   []string `json:"claims_supported,omitempty"`
	GrantsSupported                   []string `json:"grant_types,omitempty"`
}

func LoadOpenIdDiscoveryDocument(baseURL string) (*OpenIdDiscoveryDocument, error) {
	if !strings.HasSuffix(baseURL, pathSeparator) {
		baseURL = baseURL + pathSeparator
	}
	baseURL = baseURL + wellKnownSuffix

	resp, err := http.Get(baseURL)
	if err != nil {
		return nil, err
	}
	defer func(c io.ReadCloser) {
		_ = c.Close()
	}(resp.Body)

	config := new(OpenIdDiscoveryDocument)
	if err = jsonDecodeBody(resp, config); err != nil {
		return nil, err
	}

	return config, nil
}

type JsonWebKey struct {
	KeyId     string `json:"kid"`
	KeyType   string `json:"kty"`
	Algorithm string `json:"alg"`
	Use       string `json:"use"`
	N         string `json:"n"`
	E         string `json:"e"`
}

type JsonWebKeySet struct {
	Keys []*JsonWebKey `json:"keys"`
}

func LoadJsonWebKeySet(url string) (*JsonWebKeySet, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer func(c io.ReadCloser) {
		_ = c.Close()
	}(resp.Body)

	keySet := new(JsonWebKeySet)
	if err = jsonDecodeBody(resp, keySet); err != nil {
		return nil, err
	}

	return keySet, nil
}

func jsonDecodeBody(resp *http.Response, v interface{}) error {
	return json.NewDecoder(resp.Body).Decode(v)
}
