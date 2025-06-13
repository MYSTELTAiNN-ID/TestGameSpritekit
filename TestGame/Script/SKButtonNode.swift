//
//  SKButtonNode.swift
//  TestGame
//
//  Created by Syamsuddin Putra Riefli on 07/06/25.
//  Source: ChatGPT (Because i can't code Swift) and some changes edited by me
//


import SpriteKit
import AVFoundation

class SKButtonNode: SKSpriteNode {
    private let labelNode = SKLabelNode()
    private var clickSound: SKAction?
    
    var isEnabled: Bool = true {
        didSet {
            self.alpha = isEnabled ? 1.0 : 0.5
            self.isUserInteractionEnabled = isEnabled
        }
    }
    
    var action: (() -> Void)?

    init(texture: SKTexture?,color: SKColor = .clear , size: CGSize, title: String, fontSize: CGFloat = 18, fontColor: SKColor = .white, verticalAlignment: SKLabelVerticalAlignmentMode = .center, horizontalAlignment: SKLabelHorizontalAlignmentMode = .center, soundName: String? = nil, action: (() -> Void)? = nil) {
        self.action = action
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
        
        // Label setup
        labelNode.text = title
        labelNode.fontName = "AvenirNext-Bold"
        labelNode.fontSize = fontSize
        labelNode.fontColor = fontColor
        labelNode.verticalAlignmentMode = verticalAlignment
        labelNode.horizontalAlignmentMode = horizontalAlignment
        labelNode.numberOfLines = 0
        labelNode.preferredMaxLayoutWidth = size.width * 0.85
        labelNode.zPosition = 1
        
        var labelPosition = CGPoint.zero

        switch horizontalAlignment {
        case .left:
            labelPosition.x = -size.width / 2 + 10  // 10 = padding
        case .right:
            labelPosition.x = size.width / 2 - 10
        default: // .center
            labelPosition.x = 0
        }

        switch verticalAlignment {
        case .top:
            labelPosition.y = size.height / 2 - fontSize
        case .bottom:
            labelPosition.y = -size.height / 2 + fontSize / 2
        default: // .center
            labelPosition.y = 0
        }
        labelNode.position = labelPosition
        addChild(labelNode)
        
        labelNode.removeFromParent()
        addChild(labelNode)
        
        let labelHeight = labelNode.frame.height
        let verticalPadding: CGFloat = 10
        let adjustedHeight = labelHeight + verticalPadding
        let adjustedSize = CGSize(width: size.width, height: adjustedHeight)
        self.size = adjustedSize
        
        // Load sound if provided
        if let sound = soundName {
            clickSound = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            let pressIn = SKAction.scale(to: 0.95, duration: 0.1)
            let pressOut = SKAction.scale(to: 1.0, duration: 0.1)
            run(SKAction.sequence([pressIn, pressOut]))
            
            if let sound = clickSound {
                run(sound)
            }
            
            action?()
        }
    }

    func setTitle(_ title: String) {
        labelNode.text = title
        resizeButtonHeight()
    }
    
    func resizeButtonHeight(){
        let labelHeight = labelNode.frame.height
        let padding: CGFloat = 20
        self.size.height = labelHeight + padding
    }

    func setFontSize(_ size: CGFloat) {
        labelNode.fontSize = size
    }

    func setFontColor(_ color: SKColor) {
        labelNode.fontColor = color
    }
}
