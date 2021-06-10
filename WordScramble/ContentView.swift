//
//  ContentView.swift
//  WordScramble
//
//  Created by Rodrigo Cavalcanti on 20/11/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    @State private var scores = [
        3:0,
        4:0,
        5:0,
        6:0,
        7:0,
        8:0
    ]
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)

                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Spacer()
                Section {
                    Text("Your score is:\(score)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    HStack {
                        ForEach(0..<scores.keys.count) { x in
                            if (scores[x+3] ?? 0) > 0 {
                                Image(systemName: "\(x+3).circle")
                                    .foregroundColor(.secondary)
                                Text("\(scores[x+3] ?? 0)   ")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button("Next", action: startGame))
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }

        // valida se a palavra não é repetida, se as letras estão presentes em rootword e se está no dicionário. Se algum falhar, aparecerá um erro.
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        //Estes guards foi adicionado como atividade na aula 31.
        guard answer.count >= 3 else {
            wordError(title: "Word is too small", message: "You can only type words with 3 or more letters.")
            return
        }
        guard answer != rootWord else {
            wordError(title: "This is the title word", message: "You can't use the title word.")
            return
        }
        //insere a palavra nova no index 0 e reseta a variável ligada ao campo de texto.

        usedWords.insert(answer, at: 0)
        //adicionar explicação do score:
        scores.updateValue(((scores[answer.count] ?? 0) + 1), forKey: answer.count)
        newWord = ""
        score = calculeScore()
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                //Adicionado como atividade: Zera a lista de palavras usadas e o score
                usedWords = []
                score = 0
                scores = [
                    3:0,
                    4:0,
                    5:0,
                    6:0,
                    7:0,
                    8:0
                ]
                newWord = ""

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
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
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    //Atalho para copiar o titulo e mensagem para o alerta.
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    //Calcular o score
    func calculeScore() -> Int {
        var totalTemporário = 0
        for word in usedWords {
            totalTemporário += word.count
        }
        return totalTemporário
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
