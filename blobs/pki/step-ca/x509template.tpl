{
    "subject": {{ toJson .Insecure.CR.Subject }},
    "dnsNames": {{ toJson .Insecure.CR.DNSNames }},
{{- if typeIs "*rsa.PublicKey" .Insecure.CR.PublicKey }}
    "keyUsage": ["keyEncipherment", "digitalSignature"],
{{- else }}
    "keyUsage": ["digitalSignature"],
{{- end }}
    "basicConstraints": {
        "isCA": false,
        "maxPathLen": 0
    },
    "extKeyUsage": ["serverAuth", "clientAuth"],
    "issuingCertificateURL": {{ toJson "http://pki.snct.rmntn.net/w1/w1.crt" }},
    "policyIdentifiers": [ "2.23.140.1.2.1" ]
}
