//
//  ContentView.swift
//  Word Scramble
//
//  Created by Jesus Calleja on 29/9/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var userScore = 0
    
    //Error Handling
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = UIColor.white
        UITableView.appearance().backgroundColor = UIColor.white
        UIToolbar.appearance().barTintColor = UIColor.white
    }
    
    struct RoundButton: ButtonStyle {
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(36)
                .font(.title).foregroundColor(.white)
                .background(Circle()
                    .fill(Color.black))
        }
        
    }
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .listRowInsets(EdgeInsets())
                        .font(.system(.body)).foregroundColor(.black)
                       
                }
                .padding()
                .listRowInsets(EdgeInsets())
                .background(Color.white)
               
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
     
                
                Text("Score: \(self.userScore)")
                    .bold()
                    .font(.system(.title))
                    .foregroundColor(Color.black)
                    .frame(alignment: .bottom)
                
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle(Text(rootWord))
        }
        .onSubmit(self.addNewWord)
        .onAppear(perform: self.startGame)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Restart") {
                    self.startGame()
                }
                    .buttonStyle(RoundButton())
            }
        }
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count >= 3 else {
            wordError(title: "Answer too short", message: "Man, don't be lazy, the answers must have at least 3 letters 😉")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Same word is not allowed", message: "Don't play with me smartass")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used alredy", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word is not possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            userScore += answer.count
        }
        newWord = ""
    }
    
    func startGame() {
        self.userScore = 0
        self.usedWords = []
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let words = try? String(contentsOf: fileURL) {
                let allWords = words.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkword"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location  == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
