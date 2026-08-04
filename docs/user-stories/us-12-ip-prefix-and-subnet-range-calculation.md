---
issue_id: 26
title: "[ietf-inet-types]: IPv4 and IPv6 Prefix Notation Parsing, Subnet Mask Calculation, and Prefix-Length Bound Enforcement"
type: "user-story"
generation_mode: "subagent"
spec_source: "RFC 6021 Section 3 / ietf-inet-types@2013-07-15.yang"
---

# User Story: [ietf-inet-types]: IPv4 and IPv6 Prefix Notation Parsing, Subnet Mask Calculation, and Prefix-Length Bound Enforcement

## Parent Epic
- [ ] #24 - [ietf-inet-types: Common Internet Data Types](https://github.com/gintatkinson/3dgs-037/blob/main/docs/epics/epic-02-ietf-inet-types.md) (Validates prefix length boundaries, subnet mask derivations, and canonical network address formatting across IPv4 and IPv6 address families)

## Domain Object Mapping
- **Primary Domain Objects:** `IpPrefix`, `Ipv4Prefix`, `Ipv6Prefix`, `IpVersion`
- **Actor/Role:** `userActor : UserActor`

## BDD Scenario (OOA/OOD Realization)
**Given** an unparsed IP prefix string in CIDR notation (IPv4 or IPv6)
**When** `userActor` submits `prefixString` to `ipv4Prefix` or `ipv6Prefix` for validation and subnet mask calculation
**Then** `ipv4Prefix` or `ipv6Prefix` validates prefix length bounds (0..32 for IPv4, 0..128 for IPv6), determines the IP version, calculates the subnet mask bitmask from the prefix length, and zeroes out host bits to canonicalize the network prefix address.

## UML Sequence Diagram
```mermaid
sequenceDiagram
    autonumber
    actor userActor as "userActor : UserActor"
    participant ipv4Prefix as "ipv4Prefix : Ipv4Prefix"
    participant ipv6Prefix as "ipv6Prefix : Ipv6Prefix"

    userActor->>ipv4Prefix: determineIpVersion(ipString: String)
    ipv4Prefix-->userActor: ipVersion : String
    alt [ipVersion == "ipv4"]
        userActor->>ipv4Prefix: validateIpPrefix(prefixString: String)
        alt ["prefixLength >= 0 && prefixLength <= 32"]
            ipv4Prefix-->userActor: isValid : Boolean
        else ["prefixLength < 0 || prefixLength > 32"]
            ipv4Prefix-->userActor: status : Status
        end
    else [ipVersion == "ipv6"]
        userActor->>ipv6Prefix: validateIpPrefix(prefixString: String)
        alt ["prefixLength >= 0 && prefixLength <= 128"]
            ipv6Prefix-->userActor: isValid : Boolean
        else ["prefixLength < 0 || prefixLength > 128"]
            ipv6Prefix-->userActor: status : Status
        end
    end
```

## UML State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> UnparsedPrefix
    UnparsedPrefix --> DeterminingVersion : "submitPrefix / determineIpVersion"
    DeterminingVersion --> ValidatingIPv4Bounds : "versionDetermined [ipVersion == ipv4] / checkIPv4Length"
    DeterminingVersion --> ValidatingIPv6Bounds : "versionDetermined [ipVersion == ipv6] / checkIPv6Length"
    ValidatingIPv4Bounds --> SubnetMaskCalculated : "boundsValid [0 <= prefixLength <= 32] / calculateSubnetMask"
    ValidatingIPv4Bounds --> InvalidPrefix : "boundsInvalid [prefixLength < 0 || prefixLength > 32] / setError"
    ValidatingIPv6Bounds --> SubnetMaskCalculated : "boundsValid [0 <= prefixLength <= 128] / calculateSubnetMask"
    ValidatingIPv6Bounds --> InvalidPrefix : "boundsInvalid [prefixLength < 0 || prefixLength > 128] / setError"
    SubnetMaskCalculated --> CanonicalPrefixAddress : "canonicalize [hostBitsPresent == true] / zeroHostBits"
    CanonicalPrefixAddress --> [*]
    InvalidPrefix --> [*]
```

## Operational Context
> "The ip-prefix type represents an IP prefix and is IP version-neutral. The format of the ip-prefix string is identical to the format of the ipv4-prefix or ipv6-prefix string."
> — RFC 6021 Section 3 (`ip-prefix`)

> "The ipv4-prefix type represents an IPv4 prefix. The normalized format is an IPv4 address (dotted-quad notation) followed by a slash ('/') and a decimal number between 0 and 32 that specifies the number of significant bits."
> — RFC 6021 Section 3 (`ipv4-prefix`)

> "The ipv6-prefix type represents an IPv6 prefix. The normalized format is an IPv6 address (hexadecimal colon-separated notation) followed by a slash ('/') and a decimal number between 0 and 128 that specifies the number of significant bits."
> — RFC 6021 Section 3 (`ipv6-prefix`)

## Required Features Matrix
- [ ] #20 - [ietf-inet-types: IP Address Data Types](https://github.com/gintatkinson/3dgs-037/blob/main/docs/features/feat-05-ip-address-types.md) (Validates IPv4/v6 prefix length bounds 0..32 and 0..128, subnet mask MSB calculation, and zero-host-bits canonicalization)

## Source References
Structural Schema: https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-inet-types%402013-07-15.yang
Normative Specification: https://datatracker.ietf.org/doc/rfc6021/

> [!WARNING]
> **Mermaid Block Closing Constraints & Code Fence Integrity:**
> - Every Mermaid diagram MUST be strictly closed with ```` ``` ```` on a new line. Leaking Mermaid blocks or stray/unclosed code fences will fail downstream validation checks.
> - Ensure there are no stray backticks or unmatched code fences in the document.
> - **All Mermaid syntax constraints are defined in `rules/platform-independence.md` and MUST be observed in full** — including the prohibition on semicolons in `Note` and message text, colons in class members and note strings, stereotypes on relationship lines, and curly braces in class member lines.
