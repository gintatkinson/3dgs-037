---
issue_id: 6
title: "Counter32 and Counter64 Monotonic Increment and Wraparound Behavior"
type: "user-story"
generation_mode: "subagent"
spec_source: "RFC 9911 Section 3.1 & Section 3.3 / ietf-yang-types@2025-12-22.yang"
---
issue_id: 6

# User Story: Counter32 and Counter64 Monotonic Increment and Wraparound Behavior

## Parent Epic
- [ ] #5 - [[ietf-yang-types]: Common YANG Data Types](https://github.com/gintatkinson/3dgs-037/blob/main/docs/epics/epic-01-ietf-yang-types.md) (Parent Epic for common YANG data types)

## Domain Object Mapping
- **Primary Domain Objects:** `CounterAndGaugeTypes`, `ParentContainer`
- **Actor/Role:** `TelemetryCollector` or `userActor : UserActor`

## BDD Scenario (OOA/OOD Realization)
### Scenario 1: Counter32 Monotonic Increase and Wraparound
**Given** a telemetry data tree node holding a `yang:counter32` value at maximum capacity 4294967295
**When** a telemetry metric increment event is processed by `CounterAndGaugeTypes`
**Then** the `counter32` value MUST wrap around to 0 and continue monotonically increasing.

### Scenario 2: Counter64 High-Capacity Monotonic Increment and Wraparound
**Given** a high-capacity telemetry data tree node holding a `yang:counter64` value at maximum capacity 18446744073709551615
**When** a high-volume telemetry metric increment event is processed by `CounterAndGaugeTypes`
**Then** the `counter64` value MUST wrap around to 0 and resume monotonic incrementing.

## UML Sequence Diagram
```mermaid
sequenceDiagram
    autonumber
    actor userActor as "userActor : UserActor"
    participant counterAndGaugeTypes as "counterAndGaugeTypes : CounterAndGaugeTypes"

    userActor->>counterAndGaugeTypes: validateCounter32(val: Integer)
    alt [val is valid uint32]
        Note over counterAndGaugeTypes: Process 32-bit monotonic increment or wraparound at 4294967295
        counterAndGaugeTypes-->userActor: isValid : Boolean
    else [val is invalid uint32]
        counterAndGaugeTypes-->userActor: isValid : Boolean
    end

    userActor->>counterAndGaugeTypes: validateCounter64(val: Integer)
    alt [val is valid uint64]
        Note over counterAndGaugeTypes: Process 64-bit monotonic increment or wraparound at 18446744073709551615
        counterAndGaugeTypes-->userActor: isValid : Boolean
    else [val is invalid uint64]
        counterAndGaugeTypes-->userActor: isValid : Boolean
    end
```

## UML State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> InitialState
    InitialState --> ActiveMonotonic : "initialize [systemReady == true] / startCounter"
    ActiveMonotonic --> ActiveMonotonic : "increment [val < maxLimit] / updateCounter"
    ActiveMonotonic --> WrappedState : "wrapAround [val == maxLimit] / resetToZero"
    WrappedState --> ActiveMonotonic : "increment [val >= 0] / resumeMonotonic"
    ActiveMonotonic --> DiscontinuityReset : "systemReinit [reinitEvent == true] / resetDiscontinuity"
    DiscontinuityReset --> ActiveMonotonic : "reinitialize [systemReady == true] / restartCounter"
    ActiveMonotonic --> [*]
```

## Operational Context
> "The counter32 type represents a non-negative integer that monotonically increases until it reaches a maximum value of 2^32-1 (4294967295 decimal), when it wraps around and starts increasing again from zero. Counters have no defined 'initial' value, and thus, a single value of a counter has (in general) no information content. Discontinuities in the monotonically increasing value normally occur at re-initialization of the management system and at other times as specified in the description of a schema node using this type."
>
> "The counter64 type represents a non-negative integer that monotonically increases until it reaches a maximum value of 2^64-1 (18446744073709551615 decimal), when it wraps around and starts increasing again from zero. Counters have no defined 'initial' value, and thus, a single value of a counter has (in general) no information content. Discontinuities in the monotonically increasing value normally occur at re-initialization of the management system and at other times as specified in the description of a schema node using this type."

## Required Features Matrix
- [ ] #1 - [[ietf-yang-types]: Counter and Gauge Data Types](https://github.com/gintatkinson/3dgs-037/blob/main/docs/features/feat-01-counter-and-gauge-types.md) (Validates counter32 and counter64 monotonic wraparound semantics)

## Source References
Structural Schema: https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-yang-types%402025-12-22.yang
Normative Specification: https://datatracker.ietf.org/doc/rfc9911/
