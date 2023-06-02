//
//  MiniGameManager.swift
//  SignTalk
//
//  Created by Celine Margaretha on 25/05/23.
//

import Foundation

class GameManager {
    
    //GAME
    var signPoseQuestionList : [String] = [
        "A",
        "B",
        "C",
        "D",
        "E"
    ]
    
    var question = ""
    
    init(){
        setRandomQuestion()
    }
    
    func setRandomQuestion() {
        question = signPoseQuestionList.randomElement()!
    }
    
    func isCorrect(detectedPose : String) -> Bool {
//        print("-> \(detectedPose == question) - q:\(question) __  ans:\(detectedPose)")
        
        if detectedPose == question {
            return true
        }
        
        return false
    }
}
