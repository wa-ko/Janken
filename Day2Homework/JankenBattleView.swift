import SwiftUI
import Foundation

struct JankenBattleView: View {
    @State var finish = false
    @State var showSheet = false
    @State var computerHand: Hand? = nil
    @State var playerHand: Hand? = nil
    @State var result = GameCount(win: 0, lose: 0, draw: 0)
    
    struct GameCount {
        var win: Int
        var lose: Int
        var draw: Int
    }
    
    enum GameResult {
        case win
        case lose
        case draw
    }
    
    enum Hand: CaseIterable {
        case gu
        case choki
        case pa

        var imageName: String {
            "janken_\(self)"
        }

        static func nextHand(from currentHand: Hand?) -> Hand {
            guard let currentHand = currentHand,
                  let currentIndex = allCases.firstIndex(of: currentHand)
            else {
                return .gu
            }
            let nextIndex = (currentIndex + 1) % allCases.count
            return allCases[nextIndex]
        }
    }
    
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack{
            Spacer()
            if finish {
                Text(judgementText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .shadow(radius: 5))
                    .padding(.bottom, 20)
            }
            Spacer()
            Image(computerHand?.imageName ?? "default_image")
                .resizable()
                .scaledToFit()
                .onReceive(timer) { _ in
                    if !finish {
                        computerHand = Hand.nextHand(from: computerHand)
                    }
                }
            Spacer()
            HStack {
                ForEach(Hand.allCases, id: \.self) { hand in
                    Button(action: {
                        playerHandSelected(hand)
                    }) {
                        Image(hand.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }
                    .frame(width: 120, height: 100)
                    .background(buttonColor(hand: hand))
                    .clipShape(Circle())
                    .disabled(finish)
                }

            }
            
            if finish {
                HStack {
                    Button {
                        reset()
                    } label: {
                        Text("再戦する")
                    }
                    Button{
                        showSheet.toggle()
                    } label: {
                        Text("結果を見る")
                    }.sheet(isPresented: $showSheet, content: {
                        VStack{
                            Text("結果")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text("勝ち : \(result.win)")
                            Text("負け : \(result.lose)")
                            Text("あいこ : \(result.draw)")
                        }
                    })
                }
            }
        }
    }
    
    func determineResult(playerHand: Hand?, computerHand: Hand?) -> GameResult {
        switch (playerHand, computerHand) {
        case (.gu, .choki), (.choki, .pa), (.pa, .gu):
            return .win
        case (.gu, .pa), (.choki, .gu), (.pa, .choki):
            return .lose
        default:
            return .draw
        }
    }
    
    var judgementText: String {
        switch determineResult(playerHand: playerHand,computerHand: computerHand) {
        case .win:
            return "勝ち!"
        case .lose:
            return "負け!"
        case .draw:
            return "あいこ!"
        }
    }
    
    func playerHandSelected(_ hand: Hand) {
        playerHand = hand
        finish = true
        
        switch determineResult(playerHand: playerHand, computerHand: computerHand) {
        case .win:
            result.win += 1
        case .lose:
            result.lose += 1
        case .draw:
            result.draw += 1
        }
    }
    
    func reset() {
        finish = false
        computerHand = nil
        playerHand = nil
    }
    
    func buttonColor(hand: Hand) -> Color {
        switch hand {
        case .gu:
            return .red
        case .choki:
            return .green
        case .pa:
            return .blue
        }
    }
    
}

struct JankenBattleView_Previews: PreviewProvider {
    static var previews: some View {
        JankenBattleView()
    }
}
