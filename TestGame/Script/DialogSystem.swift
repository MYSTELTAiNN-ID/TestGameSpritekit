//
//  DialogSystem.swift
//  TestGame
//
//  Created by Syamsuddin Putra Riefli on 10/06/25.
//

struct DialogLine {
    let text: String
    let speaker: String
    let expression: String
}

struct DialogChoice {
    let text: String
    let action: (() -> Void)?
    let followUpDialog: [DialogLine]?
    let followUpChoices: [DialogChoice]?
}

struct NpcData {
    let name: String
    let portraits: [String: String] // expression: image name
    let dialogSequence: [DialogLine]
    let choices: [DialogChoice]?
}

struct NpcDialogTree {
    let npcId: String
    var dialogs: [String: NpcData] // condition or tag: dialog
}

class DialogSystem {
    private var npcDialogDatabase: [String: NpcDialogTree] = [:]
    private var currentDialogSequence: [DialogLine] = []
    private var currentDialogIndex: Int = 0
    private var currentChoices: [DialogChoice]? = nil
    private var currentNpc: NpcData?
    private var playerPortraits: [String: String] = [:]

    var onDialogLineDisplayed: ((DialogLine, String?) -> Void)?
    var onDialogEnded: (() -> Void)?
    var onChoicesPresented: (([DialogChoice]) -> Void)?

    func setPlayerPortraits(_ portraits: [String: String]) {
        playerPortraits = portraits
    }

    func registerDialogTree(_ tree: NpcDialogTree) {
        npcDialogDatabase[tree.npcId] = tree
    }

    func startDialog(npcId: String, state: String = "default") {
        guard let npcTree = npcDialogDatabase[npcId],
              let npc = npcTree.dialogs[state] else {
            print("Dialog not found for NPC: \(npcId), state: \(state)")
            return
        }
        currentNpc = npc
        currentDialogSequence = npc.dialogSequence
        currentDialogIndex = 0
        currentChoices = npc.choices
        showNextDialogLine()
    }

    func showNextDialogLine() {
        guard let npc = currentNpc else { return }

        if currentDialogIndex < currentDialogSequence.count {
            let line = currentDialogSequence[currentDialogIndex]
            let portraitImageName = (line.speaker == npc.name
                                      ? npc.portraits[line.expression]
                                      : playerPortraits[line.expression])
            onDialogLineDisplayed?(line, portraitImageName)
            currentDialogIndex += 1
        } else {
            if let choices = currentChoices, !choices.isEmpty {
                onChoicesPresented?(choices)
            } else {
                endDialog()
            }
        }
    }

    func selectChoice(_ choice: DialogChoice) {
        choice.action?()
        if let followUp = choice.followUpDialog {
            currentDialogSequence = followUp
            currentDialogIndex = 0
            currentChoices = choice.followUpChoices
            showNextDialogLine()
        } else {
            endDialog()
        }
    }

    func endDialog() {
        onDialogEnded?()
        currentDialogSequence = []
        currentDialogIndex = 0
        currentChoices = nil
        currentNpc = nil
    }
}
