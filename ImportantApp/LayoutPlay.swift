//
//  Layout.swift
//  ImportantApp
//
//  Created by Sebastian Bolling on 2022-06-09.
//

import SwiftUI

struct LayoutPlay: View {
   @State var pets: [Pet]
    var isThreeWayTie: Bool

    var body: some View {
        StackedButtons(pets: $pets)
    }
}

struct Layout_Previews: PreviewProvider {
    static var previews: some View {
        LayoutPlay(pets: Pet.exampleData, isThreeWayTie: false)
    }
}

struct MyEqualWidthHStack: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        // Return a size.
        guard !subviews.isEmpty else { return .zero }

        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }

        return CGSize(
            width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
            height: maxSize.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        // Place child views.
        guard !subviews.isEmpty else { return }

        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)

        let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var x = bounds.minX + maxSize.width / 2

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: x, y: bounds.midY),
                anchor: .center,
                proposal: placementProposal)
            x += maxSize.width + spacing[index]
        }
    }

    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height))
        }

        return maxSize
    }

    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal)
        }
    }
}


struct Buttons: View {
    @Binding var pets: [Pet]

    var body: some View {
        ForEach($pets) { $pet in
            Button {
                pet.votes += 1
            } label: {
                Text(pet.type)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}


struct Pet: Identifiable, Equatable {
    let type: String
    var votes: Int = 0
    var id: String { type }

    static var exampleData: [Pet] = [
        Pet(type: "Katt", votes: 25),
        Pet(type: "Hund", votes: 9),
        Pet(type: "Valhaj", votes: 16)
    ]
}

struct StackedButtons: View {
    @Binding var pets: [Pet]

    var body: some View {
        ViewThatFits {
            MyEqualWidthHStack {
                Buttons(pets: $pets)
            }
            VStack {
                Buttons(pets: $pets)
            }
        }
    }
}

struct MyRadialLayout: Layout {

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    )  -> CGSize {
        // Take whatever space is offered.
        return proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let radius = min(bounds.size.width, bounds.size.height) / 3.0
        let angle = Angle.degrees(360.0 / Double(subviews.count)).radians

        let ranks = subviews.map { subview in
            subview[Rank.self]
        }
        let offset: Double = 10 //getOffset(ranks)

        for (index, subview) in subviews.enumerated() {
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index) + offset))
            point.x += bounds.midX
            point.y += bounds.midY
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}

private struct Rank: LayoutValueKey {
    static let defaultValue: Int = 1
}

extension View {
    func rank(_ value: Int) -> some View {
        layoutValue(key: Rank.self, value: value)
    }
}
