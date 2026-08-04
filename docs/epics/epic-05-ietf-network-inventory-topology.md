---
title: "[ietf-network-inventory-topology]: Network Inventory Topology Mapping"
issue_id: 64
type: "epic"
generation_mode: "subagent"
spec_source: "Project Constitution"
labels: ["epic", "network-inventory-topology"]
---

# Epic: [ietf-network-inventory-topology]: Network Inventory Topology Mapping

## 1. Context
This Epic establishes the network inventory topology mapping specification defined in the standard network inventory topology specification and its corresponding YANG module `ietf-network-inventory-topology.yang`. It specifies the structured mapping between logical network topology entities defined in `ietf-network` and `ietf-network-topology` (network topology base model) and physical network inventory entities defined in `ietf-network-inventory`.

The `ietf-network-inventory-topology` model extends standard logical network topology representations by providing explicit augmentations across four key structural dimensions:
1. **Network Topology Type Augmentation**: Introduces the `inventory-topology` presence container under `/nw:networks/nw:network/nw:network-types` to explicitly identify networks that carry physical inventory mapping metadata.
2. **Node Inventory Mapping**: Augments `/nw:networks/nw:network/nw:node` with `inventory-mapping-attributes` containing an `ne-ref` leafref to associate logical nodes with physical network elements in the inventory.
3. **Termination Point Inventory Mapping**: Augments `/nw:networks/nw:network/nw:node/nt:termination-point` with `inventory-mapping-attributes` containing a `port-ref` leafref and a `port-breakout` container with `breakout-channel` assignments to map logical interface endpoints to physical hardware ports and breakout channels.
4. **Link Inventory Mapping**: Augments `/nw:networks/nw:network/nt:link` with `inventory-mapping-attributes` containing a `link-type` leaf to represent the underlying physical transmission media or connectivity classification.

## 2. Requirements & Checklist
- [ ] #60 - [ietf-network-inventory-topology: Network Inventory Topology Type Augment](https://github.com/gintatkinson/3dgs-037/blob/main/docs/features/feat-17-network-inventory-topology-type-augment.md) (inventory-topology presence container)
- [ ] #61 - [ietf-network-inventory-topology: Node Inventory Mapping Augment](https://github.com/gintatkinson/3dgs-037/blob/main/docs/features/feat-18-node-inventory-mapping-augment.md) (inventory-mapping-attributes, ne-ref)
- [ ] #62 - [ietf-network-inventory-topology: Termination Point Inventory Mapping Augment](https://github.com/gintatkinson/3dgs-037/blob/main/docs/features/feat-19-termination-point-inventory-mapping-augment.md) (inventory-mapping-attributes, port-ref, port-breakout, breakout-channel)
- [ ] #63 - [ietf-network-inventory-topology: Link Inventory Mapping Augment](https://github.com/gintatkinson/3dgs-037/blob/main/docs/features/feat-20-link-inventory-mapping-augment.md) (inventory-mapping-attributes, link-type)

### Associated Use Cases & User Stories

#### Associated Use Cases
- [ ] #69 - [Physical Underlay Network Topology Type Discovery, Activation, and Base Network Topology Augmentation Verification](https://github.com/gintatkinson/3dgs-037/blob/main/docs/use-cases/uc-17-network-inventory-topology-type-discovery-and-activation.md) (Provides physical underlay network topology type discovery and presence container activation verification)
- [ ] #70 - [Logical Node to Physical Network Element (NE) Inventory Mapping and 1:1 Correlation](https://github.com/gintatkinson/3dgs-037/blob/main/docs/use-cases/uc-18-node-to-physical-network-element-mapping.md) (Provides logical node to physical network element inventory mapping and 1:1 leafref correlation)
- [ ] #71 - [Port Component Leafref Binding, Port Breakout Mode Configuration (4x10G, 2x50G), and Child TP Management](https://github.com/gintatkinson/3dgs-037/blob/main/docs/use-cases/uc-19-termination-point-component-binding-and-breakout-management.md) (Provides termination point port component leafref binding, port breakout mode configuration, and child TP management)
- [ ] #72 - [Underlay Link Physical Media Classification, Leased Fiber/Wireless Media Resolution, and Fallback Handling](https://github.com/gintatkinson/3dgs-037/blob/main/docs/use-cases/uc-20-link-media-classification-and-passive-inventory-resolution.md) (Provides underlay link physical media classification, leased fiber/wireless media resolution, and fallback handling)

#### Associated User Stories
- [ ] #65 - [[ietf-network-inventory-topology]: Physical Underlay Topology Network Type Discovery, Activation, and Network Topology Augmentation Verification](https://github.com/gintatkinson/3dgs-037/blob/main/docs/user-stories/us-24-inventory-topology-type-activation.md) (Provides physical underlay topology network type discovery and presence container augmentation)
- [ ] #66 - [[ietf-network-inventory-topology]: Logical Node to Physical Network Element (NE) Leafref Mapping, 1:1 Correlation, and Unmapped Node Fallback](https://github.com/gintatkinson/3dgs-037/blob/main/docs/user-stories/us-25-node-inventory-element-mapping.md) (Provides logical node to physical network element leafref mapping and correlation)
- [ ] #67 - [[ietf-network-inventory-topology]: Port Component Leafref Binding, Port Breakout Capability Configuration (e.g. 4x10G, 2x50G), Child TP Numbering, and Speed/Duplex Alignment](https://github.com/gintatkinson/3dgs-037/blob/main/docs/user-stories/us-26-termination-point-component-and-breakout-mode.md) (Provides termination point port-ref binding and port breakout channelization)
- [ ] #68 - [[ietf-network-inventory-topology]: Underlay Link Media Type Classification (copper, fiber, coax, microwave, wlan, leased-fiber, unknown), Unset vs Unknown Evaluation, and Passive Inventory Resolution](https://github.com/gintatkinson/3dgs-037/blob/main/docs/user-stories/us-27-link-inventory-media-type-classification.md) (Provides underlay link media type classification and passive inventory resolution)

## 3. Architecture

### Subsystem Component Definition
```mermaid
classDiagram
    class SubsystemComponent {
        <<component>>
        +Boolean augmentNetworkTopologyType() "[1]"
        +Boolean mapNodeInventory(String nodeId, String neRef) "[1]"
        +Boolean mapTerminationPointInventory(String nodeId, String tpId, String portRef) "[1]"
        +Boolean mapLinkInventory(String linkId, String linkType) "[1]"
    }
    class InventoryTopology {
        +Boolean isInventoryTopology "[1]"
    }
    class NodeInventoryMapping {
        +String neRef "[0..1]"
    }
    class TerminationPointInventoryMapping {
        +String portRef "[0..1]"
    }
    class LinkInventoryMapping {
        +String linkType "[0..1]"
    }
    SubsystemComponent "1" *-- "0..1" InventoryTopology : inventoryTopology
    SubsystemComponent "1" *-- "0..*" NodeInventoryMapping : nodeMapping
    SubsystemComponent "1" *-- "0..*" TerminationPointInventoryMapping : tpMapping
    SubsystemComponent "1" *-- "0..*" LinkInventoryMapping : linkMapping
```

## System-Level UML Class Diagram
```mermaid
classDiagram
    class SubsystemComponent {
        <<component>>
        +Boolean augmentNetworkTopologyType() "[1]"
        +Boolean mapNodeInventory(String nodeId, String neRef) "[1]"
        +Boolean mapTerminationPointInventory(String nodeId, String tpId, String portRef) "[1]"
        +Boolean mapLinkInventory(String linkId, String linkType) "[1]"
    }
    class InventoryTopology {
        +Boolean isInventoryTopology "[1]"
    }
    class NodeInventoryMapping {
        +String neRef "[0..1]"
    }
    class TerminationPointInventoryMapping {
        +String portRef "[0..1]"
    }
    class PortBreakout {
        +Integer breakoutChannel "[0..1]"
    }
    class LinkInventoryMapping {
        +String linkType "[0..1]"
    }
    SubsystemComponent "1" *-- "0..1" InventoryTopology : inventoryTopology
    SubsystemComponent "1" *-- "0..*" NodeInventoryMapping : nodeMapping
    SubsystemComponent "1" *-- "0..*" TerminationPointInventoryMapping : tpMapping
    TerminationPointInventoryMapping "1" *-- "0..1" PortBreakout : portBreakout
    SubsystemComponent "1" *-- "0..*" LinkInventoryMapping : linkMapping
```

## State Machine Definitions
Describe operational transitions for mapping logical network topology objects to physical network inventory assets. The subsystem begins in the `Unmapped` state. Calling `augmentNetworkTopologyType()` transitions the network to `TopologyTypeAugmented` when the presence container `inventory-topology` is present. Nodes are linked to physical network elements (`ne-ref`) transitioning to `NodeInventoryMapped`. Termination points map to component ports (`port-ref`) and optional breakout channels (`breakout-channel`) reaching `TerminationPointInventoryMapped`. Finally, logical links associate with physical link types (`link-type`) transitioning to `LinkInventoryMapped`.

## System State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> Unmapped
    Unmapped --> TopologyTypeAugmented : "augmentTopologyType() / initializePresenceContainer"
    TopologyTypeAugmented --> NodeInventoryMapped : "mapNodeInventory(nodeId, neRef) / linkNetworkElement"
    NodeInventoryMapped --> TerminationPointInventoryMapped : "mapTerminationPointInventory(tpId, portRef) / linkPhysicalPort"
    TerminationPointInventoryMapped --> LinkInventoryMapped : "mapLinkInventory(linkId, linkType) / linkPhysicalMedia"
    LinkInventoryMapped --> [*]
```

## 4. Operational Considerations
The network inventory topology mapping model provides unified correlation between logical abstraction models (such as TE topologies, L2/L3 VPN topologies, or optical transport topologies) and concrete physical hardware assets:
- **Cross-Layer Traceability**: `ne-ref` and `port-ref` leafrefs establish direct cross-layer pointer relationships between logical topology nodes/termination points and physical network element/component instances in the `ietf-network-inventory` database.
- **Channelization & Port Breakouts**: `port-breakout` and `breakout-channel` attributes support multi-channel optical interfaces (e.g. 400G interfaces broken down into 4x100G breakout channels), ensuring fine-grained mapping down to individual sub-ports.
- **Physical Link Media Classification**: `link-type` attributes distinguish physical interconnect types (e.g., single-mode fiber, multi-mode fiber, DAC copper, or virtual cross-connects) to aid physical path computation and optical impairment calculation.

## 5. Security & Governance
Topology mapping data bridges abstract logical networks with physical facility hardware and cable plant layouts, making it subject to strict security policies:
- **Access Control & Integrity**: Modifications to `inventory-mapping-attributes` must be restricted to authorized topology controllers and inventory management engines to prevent physical route manipulation.
- **Cross-Domain Privacy & Confidentiality**: Multi-tenant virtual network topologies must not expose physical inventory reference details (`ne-ref`, `port-ref`) to external tenants where hardware location or co-location sharing could compromise physical security.

## Specification Context
The Network Inventory Topology model (`ietf-network-inventory-topology`) extends generic network topology data models (`ietf-network` and `ietf-network-topology`, network topology base model) to anchor abstract network topology elements onto physical inventory assets.

The model defines four augmentations:
1. `augment "/nw:networks/nw:network/nw:network-types"` adds `inventory-topology`, indicating that a network instance contains physical inventory mapping attributes.
2. `augment "/nw:networks/nw:network/nw:node"` adds `inventory-mapping-attributes` with `ne-ref`, referencing a network element in `ietf-network-inventory`.
3. `augment "/nw:networks/nw:network/nw:node/nt:termination-point"` adds `inventory-mapping-attributes` with `port-ref` and optional `port-breakout/breakout-channel`, referencing a physical port component.
4. `augment "/nw:networks/nw:network/nt:link"` adds `inventory-mapping-attributes` with `link-type`, indicating the physical link media type.

## 6. Source References
Structural Schema: https://github.com/gintatkinson/3dgs-037/blob/main/yang/ietf-network-inventory-topology.yang (Clause: Section 5)
Normative Specification: https://datatracker.ietf.org/doc/html/draft-ietf-ivy-network-inventory-topology (Clause: Section 4)
