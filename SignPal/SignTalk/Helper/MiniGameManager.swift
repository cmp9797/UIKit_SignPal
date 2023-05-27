//
//  MiniGameManager.swift
//  SignTalk
//
//  Created by Celine Margaretha on 25/05/23.
//

import Foundation

class MiniGameManager {
    
    //GAME
    var signPoses : [SignPose] = [
        SignPose(name: "C"),
        SignPose(name: "D")
//        SignPose(name: "C"),
//        SignPose(name: "D"),
//        SignPose(name: "E"),
    ]
    
    var question = ""
    
    init(){
        setRandomQuestion()
    }
    
    func setRandomQuestion() {
        question = signPoses.randomElement()!.name
    }
    
    func isCorrect(detectedPose : String) -> Bool {
        print("~\(detectedPose == question) - q:\(question) __  ans:\(detectedPose)")
        if detectedPose == question {
            return true
        }
        
        return false
    }
}
