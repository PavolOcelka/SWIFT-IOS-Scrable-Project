//
//  ContentView.swift
//  Scrabble
//
//  Created by Pavol Ocelka on 18/01/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State var allWords = [String]()
    
    @State private var score = 0
    
    var body: some View {
        ZStack{
            VStack{
                
                HStack{
                    Text(rootWord)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color(red: 239, green: 227, blue: 194))
                    Spacer()
                    Text(String(score))
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color(red: 239, green: 227, blue: 194))
                        .padding()
                }
                .padding()
                ZStack{
                    Color(red: 62, green: 123, blue: 39)
                    List{
                        Section{
                            TextField("Enter your word", text: $newWord)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        
                        Section{
                            ForEach(usedWords, id: \.self) { word in
                                HStack{
                                    Image(systemName: "\(word.count).circle")
                                    Text(word)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .ignoresSafeArea()
                
                
                
                .onSubmit{
                    addNewWord()
                }
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) { } message: {Text(errorMessage)}
            }
            .background(Color(red: 18, green: 53, blue: 36))
            
            
            VStack{
                Spacer()
                Button(action: {
                    withAnimation{
                        score = 0
                        rootWord = allWords.randomElement() ?? "ERROR!!!"
                        usedWords = [String]()
                    }
                }) {
                    Text("Shuffle").bold()
                }
                .frame(width: 200, height: 50)
                .foregroundStyle(Color(red: 239, green: 227, blue: 194))
                .background(Color(red: 18, green: 53, blue: 36))
                .clipShape(.capsule)
                .padding(.bottom, 50)
            }
        }
    }
    
     func startGame() {
        if let startWordsURL = Bundle.main.path(forResource: "start", ofType: "txt"){
            if let startWords = try? String(contentsOfFile: startWordsURL, encoding: .utf8){
                allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "ERROR!!!"
                return
            }
        }
        
        fatalError("Could not load file from the bundle.")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isORiginal(word: answer) else {
            wordError(title: "Word not possible", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cant spell that from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized!", message: "You cant make them up")
            return
        }
        
        
        withAnimation{
            score += answer.count
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func isORiginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf8.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

extension Color {
    // Method returns a custom color
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> Color {
        return .init(red: red / 255, green: green / 255, blue: blue / 255)
    }
}

#Preview {
    ContentView()
}
