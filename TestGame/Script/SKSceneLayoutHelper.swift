//
//  SKSceneLayoutHelper.swift
//  TestGame
//
//  Created by Syamsuddin Putra Riefli on 07/06/25.
//  Source ChatGPT
//

import SpriteKit

enum HorizontalAlignment {
    case left
    case center
    case right
}

enum VerticalAlignment {
    case top
    case center
    case bottom
}

extension SKScene {
    
    func layoutNodesVertically(
        _ nodes: [SKNode],
        spacing: CGFloat = 20,
        center: CGPoint? = nil,
        alignment: HorizontalAlignment = .center,
        padding: CGFloat = 20
    ) {
        let totalHeight = nodes.reduce(0) { $0 + $1.frame.height } + spacing * CGFloat(nodes.count - 1)
        let startY = (center?.y ?? frame.midY) + totalHeight / 2

        var currentY = startY

        for node in nodes {
            let nodeWidth = node.frame.width
            let xPos: CGFloat

            switch alignment {
            case .center:
                xPos = center?.x ?? frame.midX
            case .left:
                xPos = frame.minX + nodeWidth / 2 + padding
            case .right:
                xPos = frame.maxX - nodeWidth / 2 - padding
            }

            node.position = CGPoint(x: xPos, y: currentY - node.frame.height / 2)
            currentY -= node.frame.height + spacing
        }
    }

    func layoutNodesHorizontally(
        _ nodes: [SKNode],
        spacing: CGFloat = 20,
        center: CGPoint? = nil,
        alignment: VerticalAlignment = .center,
        padding: CGFloat = 20
    ) {
        let totalWidth = nodes.reduce(0) { $0 + $1.frame.width } + spacing * CGFloat(nodes.count - 1)
        let startX = (center?.x ?? frame.midX) - totalWidth / 2

        var currentX = startX

        for node in nodes {
            let nodeHeight = node.frame.height
            let yPos: CGFloat

            switch alignment {
            case .center:
                yPos = center?.y ?? frame.midY
            case .top:
                yPos = frame.maxY - nodeHeight / 2 - padding
            case .bottom:
                yPos = frame.minY + nodeHeight / 2 + padding
            }

            node.position = CGPoint(x: currentX + node.frame.width / 2, y: yPos)
            currentX += node.frame.width + spacing
        }
    }

    // Optional: Anchor-positioning helper
    func positionNode(
        _ node: SKNode,
        at anchor: String,
        padding: CGPoint = CGPoint(x: 20, y: 20)
    ) {
        let nodeSize = (node as? SKSpriteNode)?.size ?? node.frame.size

        let xPos: CGFloat
        let yPos: CGFloat

        switch anchor {
        case "topLeft":
            xPos = frame.minX + nodeSize.width / 2 + padding.x
            yPos = frame.maxY - nodeSize.height / 2 - padding.y
        case "topRight":
            xPos = frame.maxX - nodeSize.width / 2 - padding.x
            yPos = frame.maxY - nodeSize.height / 2 - padding.y
        case "bottomLeft":
            xPos = frame.minX + nodeSize.width / 2 + padding.x
            yPos = frame.minY + nodeSize.height / 2 + padding.y
        case "bottomRight":
            xPos = frame.maxX - nodeSize.width / 2 - padding.x
            yPos = frame.minY + nodeSize.height / 2 + padding.y
        case "center":
            xPos = frame.midX
            yPos = frame.midY
        case "centerLeft":
            xPos = frame.minX + nodeSize.width / 2 + padding.x
            yPos = frame.midY
        case "centerRight":
            xPos = frame.maxX - nodeSize.width / 2 - padding.x
            yPos = frame.midY
        case "topCenter":
            xPos = frame.midX
            yPos = frame.maxY - nodeSize.height / 2 - padding.y
        case "bottomCenter":
            xPos = frame.midX
            yPos = frame.minY + nodeSize.height / 2 + padding.y
        default:
            xPos = frame.midX
            yPos = frame.midY
        }

        node.position = CGPoint(x: xPos, y: yPos)
    }
}
