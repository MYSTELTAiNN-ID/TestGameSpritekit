//
//  DialogData.swift
//  TestGame
//
//  Created by Syamsuddin Putra Riefli on 10/06/25.
//

let playerPortrait: [String: String] = [
    "neutral" : "player_portrait_neutral",
    "angry" : "player_portrait_angry",
    "sad" : "player_portrait_sad",
    "happy" : "player_portrait_happy",
]

let npcSmith = NpcDialogTree(
    npcId: "npc_smith",
    dialogs: [
        "default" : NpcData(
            name: "Smith",
            portraits: [
                "neutral" : "npc_smith_neutral",
                "angry" : "npc_smith_angry",
                "sad" : "npc_smith_sad",
                "happy" : "npc_smith_happy"
            ],
            dialogSequence: [
                DialogLine(text: "Hello there!", speaker: "Smith", expression: "happy"),
                DialogLine(text: "What can I do for you?", speaker: "Smith", expression: "neutral")
            ],
            choices: [
                DialogChoice(text: "I want to buy some weapons.",
                             action: nil,
                             followUpDialog: [
                                DialogLine(text: "I want to buy some weapons.", speaker: "Player", expression: "neutral"),
                                DialogLine(text: "I'm sorry, I don't have any weapons for sale right now.", speaker: "Smith", expression: "sad"),
                                DialogLine(text: "Come back later.", speaker: "Smith", expression: "neutral"),
                             ],
                             followUpChoices: nil),
                DialogChoice(text: "I want to upgrade my current weapon.",
                             action: nil,
                             followUpDialog: [
                                DialogLine(text: "I want to upgrade my current weapon.", speaker: "Player", expression: "neutral"),
                                DialogLine(text: "I'm sorry, I don't have any materials to upgrade your weapon right now.", speaker: "Smith", expression: "sad"),
                                DialogLine(text: "Come back later.", speaker: "Smith", expression: "neutral"),
                             ],
                             followUpChoices: nil),
                DialogChoice(text: "Later.",
                             action: nil,
                             followUpDialog: [
                                DialogLine(text: "Later.", speaker: "Player", expression: "neutral"),
                                DialogLine(text: "Come back if you need help.", speaker: "Smith", expression: "neutral")
                             ],
                             followUpChoices: nil)
            ]
        ),
        "quest_01" : NpcData(
            name: "Smith",
            portraits: [
                "neutral" : "npc_smith_neutral",
                "angry" : "npc_smith_angry",
                "sad" : "npc_smith_sad",
                "happy" : "npc_smith_happy"
            ],
            dialogSequence: [
                DialogLine(text: "Hello there!", speaker: "Smith", expression: "happy"),
                DialogLine(text: "What can I do for you?", speaker: "Smith", expression: "neutral")
            ],
            choices: [
                DialogChoice(text: "Actually, I heard that you need some help with something.",
                             action: nil,
                             followUpDialog: [
                                DialogLine(text: "Actually, I heard that you need some help with something.", speaker: "Player", expression: "neutral"),
                                DialogLine(text: "Can you tell me more about it?", speaker: "Player", expression: "neutral"),
                                DialogLine(text: "Ah, about that, huh?", speaker: "Smith", expression: "neutral"),
                                DialogLine(text: "About 2 days ago, my daughter was playing with her friends.", speaker: "Smith", expression: "neutral"),
                                DialogLine(text: "But, at noon, only her friends come back to the village.", speaker: "Smith", expression: "neutral"),
                                DialogLine(text: "They say that my daughter help them to distract some monster in forest.", speaker: "Smith", expression: "sad"),
                                DialogLine(text: "I know that she has her mother trait's, but i can't help but worry about her because she didn't go back to home.", speaker: "Smith", expression: "sad"),
                                DialogLine(text: "Can you help me to find her?, I really need your help. Of course, you can take a reward if you find her.", speaker: "Smith", expression: "sad"),
                             ],
                             followUpChoices: [
                                DialogChoice(text: "Of course, I can help you!",
                                             action: nil,
                                             followUpDialog: [
                                                DialogLine(text: "Of course, I can help you!", speaker: "Player", expression: "neutral"),
                                                DialogLine(text: "Do you know which way the kids come back from forest?", speaker: "Player", expression: "neutral"),
                                                DialogLine(text: "Ah, yes, it's north from here.", speaker: "Smith", expression: "neutral"),
                                                DialogLine(text: "You will see a path with big trees on the left side.", speaker: "Smith", expression: "neutral"),
                                                DialogLine(text: "I see. Thank you for the information.", speaker: "Player", expression: "neutral"),
                                                DialogLine(text: "I will help as soon as I can.", speaker: "Player", expression: "neutral"),
                                             ],
                                             followUpChoices: nil),
                                DialogChoice(text: "I'm sorry, I can't help you.",
                                             action: nil,
                                             followUpDialog: [
                                                DialogLine(text: "I'm sorry, I can't help you.", speaker: "Player", expression: "neutral"),
                                                DialogLine(text: "I understand.", speaker: "Smith", expression: "neutral")
                                             ],
                                            followUpChoices: nil
                                            )
                             ]
                            ),
                DialogChoice(text: "Later.",
                             action: nil,
                             followUpDialog: [
                                DialogLine(text: "Later.", speaker: "Player", expression: "neutral"),
                                DialogLine(text: "Come back if you need help.", speaker: "Smith", expression: "happy")
                             ],
                             followUpChoices: nil)
            ]
        )
    ]
)

//let npcEdquiries = NpcDialogTree(
//    npcId: "npc_edquiries",
//    dialogs: [
//        "default" : NpcData(
//            name: "Edquiries",
//            portraits: [
//                "neutral" : "npc_edquiries_neutral",
//                "happy" : "npc_edquiries_happy",
//                "sad" : "npc_edquiries_sad",
//                "angry" : "npc_edquiries_angry"
//            ],
//            dialogSequence: <#[DialogLine]#>,
//            choices: <#[DialogChoice]?#>)
//    ]
//)
