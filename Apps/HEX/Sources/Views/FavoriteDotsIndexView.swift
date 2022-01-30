// FavoriteDotsIndexView.swift
// Copyright (c) 2022 Joe Blau

import ComposableArchitecture
import SwiftUI

struct FavoriteDotsIndexView: View {
    let store: Store<AppState, AppAction>

    // MARK: - Public Properties

    let visualRange: Int = 8

    // MARK: - Drawing Constants

    private let pageDotSize: CGFloat = 12
    private let pageDotSpacing: CGFloat = 12

    private let pimaryStarColor = Color.orange
    private let secondaryStarColor = Color.secondary.opacity(0.6)
    private let primaryColor = Color.accentColor
    private let secondaryColor = Color.secondary.opacity(0.6)

    private let smallScale: CGFloat = 0.6

    // MARK: - Body

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer()
                HStack(spacing: pageDotSpacing) {
                    ForEach(0 ..< viewStore.pageViewDots.numberOfPages, id: \.self) { index in
                        if shouldShowIndex(index) {
                            switch (index, viewStore.pageViewDots.hasMinusOne) {
                            case (0, true):
                                Image(systemName: "star.fill")
                                    .scaleEffect(viewStore.pageViewDots.currentIndex == 0 ? 1 : smallScale)
                                    .frame(width: pageDotSize, height: pageDotSize)
                                    .foregroundColor(viewStore.pageViewDots.currentIndex == 0 ? pimaryStarColor : secondaryStarColor)
                                    .transition(AnyTransition.opacity.combined(with: .scale))
                                    .id(index)
                            default:
                                Circle()
                                    .fill(viewStore.pageViewDots.currentIndex == index ? primaryColor : secondaryColor)
                                    .scaleEffect(viewStore.pageViewDots.currentIndex == index ? 1 : smallScale)
                                    .frame(width: pageDotSize, height: pageDotSize)
                                    .transition(AnyTransition.opacity.combined(with: .scale))
                                    .id(index)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Private Methods

    func shouldShowIndex(_ index: Int) -> Bool {
        let currentIndex = ViewStore(store).pageViewDots.currentIndex
        return ((currentIndex - visualRange) ... (currentIndex + visualRange)).contains(index)
    }
}
