//
//  TextToSpeech.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 05/11/2024.
//

import Foundation
import AVFoundation


class TextToSpeech {
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        // Set the language to British English
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        
        // Optional: Customize the speech rate (0.0 - 1.0)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        synthesizer.speak(utterance)
    }
}


