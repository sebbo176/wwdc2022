//
//  ContentView.swift
//  ImportantApp
//
//  Created by Sebastian Bolling on 2022-06-08.
//

import SwiftUI
import Combine

struct GridWithAnimatedSFSymbolPlay: View {

    var body: some View {
        ViewThatFits{
            SymbolGrid()
        }
    }
}


// MARK: - Dancing Symbol Grid

struct SymbolSquare: View {
    let color: Color
    let imageName: String
    var image: some View {
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var body: some View {
        image
            .background {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        .ellipticalGradient(
                            color
                                .gradient
                        )
                    )
            }
    }
}

/// If `true`, the party will commence.
private let startTheParty = true

private let partySymbols = ["party.popper", "balloon", "balloon.2", "birthday.cake", "hands.sparkles", "shareplay"]

struct DancingSymbolSquare: View {
    let color: Color
    let imageName: String

    /// Allows staggered dancing — doesn't look quite as nice.
    let seed: Int
    private let timer = Timer.publish(every: 0.234378662, on: .main, in: .default)
    @State private var cancellable: Cancellable? = nil
    @State private var heavy = false
    @State var fontSize = 20 as CGFloat

    var body: some View {
        SymbolSquare(color: color, imageName: imageName)
            .font(.body.weight(heavy ? .black : .thin))
            .onReceive(timer) { date in
                if heavy {
                    withAnimation(.easeOut(duration: 0.468757324 - 0.1)) {
                        heavy.toggle()
                    }
                } else {
                    withAnimation(.easeIn(duration: 0.1)) {
                        heavy.toggle()
                    }
                }
            }
            .onAppear {
                if startTheParty {
                    DispatchQueue.main.asyncAfter(deadline: .now()  + Double(seed) * 0.25) {
                        cancellable = timer.connect()
                    }
                }
            }
            .drawingGroup(opaque: true)
    }
}

struct SymbolGrid: View {
    var body: some View {
        Grid {
            GridRow {
                DancingSymbolSquare(color: .yellow, imageName:partySymbols[0], seed: 0)
                DancingSymbolSquare(color: .green, imageName: partySymbols[1], seed: 0)
            }

            GridRow {
                DancingSymbolSquare(color: .indigo, imageName: partySymbols[2], seed: 0)
                DancingSymbolSquare(color: .purple, imageName: partySymbols[3],  seed: 0)
            }
            GridRow {
                DancingSymbolSquare(color: .cyan, imageName: partySymbols[4], seed: 0)
                DancingSymbolSquare(color: .mint, imageName: partySymbols[5],  seed: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GridWithAnimatedSFSymbolPlay_Previews: PreviewProvider {
    static var previews: some View {
        GridWithAnimatedSFSymbolPlay()
    }
}
