//
//  WordSuggestions.swift
//  Haptic
//
//  Created by Joe Manto on 1/17/19.
//  Copyright © 2019 joemanto. All rights reserved.
//

import UIKit

extension String{
    public func removingCharacters(in set:CharacterSet) -> String{
        let filtered = unicodeScalars.lazy.filter{
            !set.contains($0)
        }
        return String(String.UnicodeScalarView(filtered))
        }
    }

class WordSuggestions: NSObject {

    private var WORDCOUNT:[String:Int] = [:]
    private var alphabet = "abcdefghijklmnopqrstuvwxyz"

    struct WordRecord {
        var currentWord = ""
        var location = 0
        var range = 0
    }

    var currentRecord = WordRecord()

    override init() {
        super.init()
        var fileContent = loadBigData(name: "bigData", type: "txt")
        fileContent = fileContent.lowercased()
        WORDCOUNT = getWordCounts(context: fileContent)
    }


    private func getWordCounts(context:String) -> [String:Int]{
        var result:[String:Int] = [:]
        let matched = matches(for: "[a-z]+", in: context)
        for match in matched{
            if result[match] != nil{
                result[match] = result[match]! + 1
            }else{
                result[match] = 1
            }
        }
        return result
    }

    func correct(word1:String) -> String{
        let word = word1.lowercased()
        if(WORDCOUNT[word] != nil){
            return word1
        }


        var maxCount = 0
        var correctWord = word
        let editDistance1Words = editDistance1(word: word)
        var editDistance2Words:[String] = []

        for edit1Word in editDistance1Words{
            editDistance2Words.append(contentsOf: editDistance1(word: edit1Word))
        }

        for edit1Word in editDistance1Words{
            if WORDCOUNT[edit1Word] != nil{
                if(WORDCOUNT[edit1Word]! > maxCount){
                    maxCount = WORDCOUNT[edit1Word]!
                    correctWord = edit1Word
                }
            }
        }

        var maxCount2 = 0
        var correctWord2 = correctWord

        for edit2Word in editDistance2Words{
            if WORDCOUNT[edit2Word] != nil{
                maxCount2 = WORDCOUNT[edit2Word]!
                correctWord2 = edit2Word
            }
        }

        if word.count < 6{
            if maxCount2 > 100*maxCount{
                return correctWord2
            }
            return correctWord
        }else{
            if maxCount2 > 4*maxCount{
                return correctWord2
            }
            return correctWord
        }
    }

   private func editDistance1(word:String) -> [String]{
        var results:[String] = [];

        for c in stride(from: 0, to: word.count+1, by: 1){
            for letter in alphabet{
                var newWord = word
                let insertIndex = word.index(word.startIndex, offsetBy: c)
                newWord.insert(letter, at: insertIndex)
                results.append(newWord)
            }
        }

        if(word.count > 1){
            for c in stride(from: 0, to: word.count-1, by: 1){
                var newWord = word
                let removeIndex = word.index(word.startIndex, offsetBy: c)
                newWord.remove(at: removeIndex)
                results.append(newWord)
            }
        }

        if(word.count > 1){
            for c in stride(from: 0, to: word.count-1, by: 1){
                var newWord = word
                let removeIndex = word.index(word.startIndex, offsetBy: c)
                let insertIndex = word.index(word.startIndex, offsetBy: c+1)
                let temp = newWord.remove(at: removeIndex)
                newWord.insert(temp, at: insertIndex)
                results.append(newWord)
            }
        }
        for c in stride(from: 0, to: word.count, by: 1){
            for letter in alphabet{
                var newWord = word
                let removeIndex = word.index(word.startIndex, offsetBy: c)
                let insertIndex = word.index(word.startIndex, offsetBy: c)
                newWord.remove(at: removeIndex)
                newWord.insert(letter, at: insertIndex)
                results.append(newWord)
            }
        }
        return results
    }

    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    private func loadBigData(name:String,type:String) -> String{
        var contents:String = ""
        if let filePath = Bundle.main.path(forResource: name, ofType: "txt") {
            do{
                contents = try String(contentsOfFile: filePath)
            } catch {
                print("Contents could not be loaded")
            }
        }else{
            print("File \(name) not file")
        }
        return contents
    }


    
}
