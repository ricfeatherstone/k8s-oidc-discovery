package jwt

import (
	"gopkg.in/square/go-jose.v2/jwt"
)

func Claims(jwtString *string) (*jwt.Claims, error) {
	claims := &jwt.Claims{}
	token, err := jwt.ParseSigned(*jwtString)
	if err != nil {
		return nil, err
	}

	if err = token.UnsafeClaimsWithoutVerification(claims); err != nil {
		return nil, err
	}

	return claims, nil
}
