---
issue_id: 27
title: "[ietf-inet-types]: RFC 1034 / RFC 1123 Domain Name Syntax Validation, FQDN Length Restrictions, and RFC 3986 URI Parsing"
type: "user-story"
generation_mode: "subagent"
spec_source: "RFC 6021 Section 3 / ietf-inet-types@2013-07-15.yang"
---

# User Story: [ietf-inet-types]: RFC 1034 / RFC 1123 Domain Name Syntax Validation, FQDN Length Restrictions, and RFC 3986 URI Parsing

## Parent Epic
- [ ] #24 - [ietf-inet-types: Common Internet Data Types](https://github.com/gintatkinson/3dgs-037/blob/main/docs/epics/epic-02-ietf-inet-types.md) (Parent Epic specification for common Internet data types)

## Domain Object Mapping
- **Primary Domain Objects:** `DomainName`, `Host`, `Uri`, `DomainNameAndHostTypes`
- **Actor/Role:** `userActor : UserActor`

## BDD Scenario (OOA/OOD Realization)

### Scenario 1: RFC 1034 / RFC 1123 Domain Name Syntax and Canonicalization
**Given** a DNS domain name input string `"SubDomain.Example.COM."` provided for `domain-name` validation
**When** `validateDomainName(input: String)` is evaluated on `DomainName` and `canonicalizeDomainName(input: String)` is invoked
**Then** format validation returns `true` verifying US-ASCII label and length constraints, and the canonical lowercase representation `"subdomain.example.com."` is produced.

### Scenario 2: FQDN Total Wire Length Limit Rejection (Exceeding 253 Characters)
**Given** a domain name string exceeding the 253-character textual representation limit (255-octet DNS wire format)
**When** `validateDomainName(input: String)` is evaluated on `DomainName`
**Then** validation returns `false` rejecting the payload for violating FQDN length restrictions.

### Scenario 3: Individual Label Length Boundary Rejection (Exceeding 63 Characters)
**Given** a domain name string containing a label exceeding 63 characters or invalid non-ASCII characters
**When** `validateDomainName(input: String)` is evaluated on `DomainName`
**Then** validation returns `false` enforcing label syntax boundaries.

### Scenario 4: Host Type Union Matching for IP Addresses and Domain Names
**Given** a host identifier string `"192.0.2.1"` or `"server.example.com"` provided for `host` validation
**When** `validateHost(input: String)` is evaluated on `Host`
**Then** union discrimination succeeds matching either IP address format or DNS domain name format and returns `true`.

### Scenario 5: Invalid Host Identifier Rejection
**Given** an malformed host string `"invalid_host_@#$%.com"` that is neither a valid IP address nor a valid domain name
**When** `validateHost(input: String)` is evaluated on `Host`
**Then** validation returns `false` rejecting the input.

### Scenario 6: RFC 3986 URI Parsing and Syntax Normalization
**Given** an unnormalized URI string `"HTTP://USER:PASS@EXAMPLE.COM:8080/path/%7Euser/default.html"`
**When** `normalizeUri(input: String)` is evaluated on `Uri`
**Then** scheme and host components are lowercased, unreserved percent-encoded characters are decoded, and normalized URI `"http://USER:PASS@example.com:8080/path/~user/default.html"` is returned.

### Scenario 7: Zero-Length and Non-ASCII URI Rejection
**Given** an empty URI string `""` or a URI containing unencoded non-ASCII Unicode characters
**When** `normalizeUri(input: String)` is evaluated on `Uri`
**Then** validation fails and error status is returned.

## UML Sequence Diagram
```mermaid
sequenceDiagram
    autonumber
    actor userActor as "userActor : UserActor"
    participant domainNameSpec as "domainNameSpec : DomainName"
    participant hostSpec as "hostSpec : Host"
    participant uriSpec as "uriSpec : Uri"

    userActor->>domainNameSpec: isValidSyntax(input: String)
    alt [isValidSyntax == true]
        domainNameSpec-->userActor: isValid : Boolean
        userActor->>domainNameSpec: getCanonicalDomainName(input: String)
        domainNameSpec-->userActor: canonicalName : String
    else [isValidSyntax == false]
        domainNameSpec-->userActor: isValid : Boolean
    end

    userActor->>hostSpec: validateHostFormat(input: String)
    alt [isValidHost == true]
        hostSpec-->userActor: isValid : Boolean
    else [isValidHost == false]
        hostSpec-->userActor: isValid : Boolean
    end

    userActor->>uriSpec: isValidUriSyntax(input: String)
    alt [isValidUriSyntax == true]
        uriSpec-->userActor: isValid : Boolean
        userActor->>uriSpec: getNormalizedUri(input: String)
        uriSpec-->userActor: normalizedUri : String
    else [isValidUriSyntax == false]
        uriSpec-->userActor: isValid : Boolean
    end
```

## UML State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> UnvalidatedInput
    UnvalidatedInput --> ValidatingDomainName : "validateDomainName [hasInput == true] / inspectLabelAndLength"
    ValidatingDomainName --> DomainNameCanonical : "canonicalizeDomainName [isValidSyntax == true] / convertToLowercaseAscii"
    ValidatingDomainName --> SyntaxError : "failValidation [isValidSyntax == false] / raiseDomainSyntaxError"
    DomainNameCanonical --> ValidatingHost : "validateHost [hasHostInput == true] / evaluateUnionType"
    ValidatingHost --> HostVerified : "confirmHost [isValidHost == true] / matchIpOrDomain"
    ValidatingHost --> SyntaxError : "failHostValidation [isValidHost == false] / raiseHostFormatError"
    HostVerified --> NormalizingUri : "normalizeUri [hasUriInput == true] / applyRfc3986Normalization"
    NormalizingUri --> UriNormalized : "completeUriNormalization [isValidUri == true] / produceNormalizedUri"
    NormalizingUri --> SyntaxError : "failUriValidation [isValidUri == false] / raiseUriError"
    UriNormalized --> [*]
    SyntaxError --> [*]
```

## Operational Context
> "The domain-name type represents a DNS domain name. The name SHOULD be fully qualified whenever possible. Internet domain names are only loosely specified. Section 3.5 of RFC 1034 recommends a syntax (modified in Section 2.1 of RFC 1123). The pattern above is intended to allow for current practice in domain name use, and some possible future expansion... The encoding of DNS names in the DNS protocol is limited to 255 characters. Since the encoding consists of labels prefixed by a length bytes and there is a trailing NULL byte, only 253 characters can appear in the textual dotted notation... Domain-name values use the US-ASCII encoding. Their canonical format uses lowercase US-ASCII characters. Internationalized domain names MUST be A-labels as per RFC 5890."
> — RFC 6021 Section 3 / ietf-inet-types@2013-07-15.yang

> "The host type represents either an IP address or a DNS domain name."
> — RFC 6021 Section 3 / ietf-inet-types@2013-07-15.yang

> "The uri type represents a Uniform Resource Identifier (URI) as defined by STD 66. Objects using the uri type MUST be in US-ASCII encoding, and MUST be normalized as described by RFC 3986 Sections 6.2.1, 6.2.2.1, and 6.2.2.2. All unnecessary percent-encoding is removed, and all case-insensitive characters are set to lowercase except for hexadecimal digits, which are normalized to uppercase as described in Section 6.2.2.1... A zero-length URI is not a valid URI. This can be used to express 'URI absent' where required."
> — RFC 6021 Section 3 / ietf-inet-types@2013-07-15.yang

## Required Features Matrix
- [ ] #21 - [ietf-inet-types: Domain Name and Host Data Types](https://github.com/gintatkinson/3dgs-037/blob/main/docs/features/feat-06-domain-name-and-host-types.md) (Validates DNS domain name label/total length limits, host union discrimination, and RFC 3986 URI syntax normalization)

## Source References
Structural Schema: https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-inet-types%402013-07-15.yang
Normative Specification: https://datatracker.ietf.org/doc/rfc6021/
