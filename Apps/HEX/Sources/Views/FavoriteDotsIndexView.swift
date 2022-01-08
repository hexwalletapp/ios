import SwiftUI

struct FavoriteDotsIndexView: View {
    
    // MARK: - Public Properties
    
    let hasMinusOne: Bool
    let numberOfPages: Int
    let currentIndex: Int
    let visualRange: Int = 4
    
    // MARK: - Drawing Constants
    
    private let pageDotSize: CGFloat = 12
    private let pageDotSpacing: CGFloat = 12
    
    private let pimaryHeartColor = Color.orange
    private let secondaryHeartColor = Color.orange.opacity(0.6)
    private let primaryColor = Color.accentColor
    private let secondaryColor = Color.accentColor.opacity(0.6)
    
    private let smallHeartScale: CGFloat = 0.5
    private let smallScale: CGFloat = 0.6
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: pageDotSpacing) {
                ForEach(0..<numberOfPages) { index in
                    if shouldShowIndex(index) {
                        switch (index, hasMinusOne) {
                        case (0, true):
                            Image(systemName: "star.fill")
                                .scaleEffect(currentIndex == 0 ? 1 : smallHeartScale)
                                .frame(width: pageDotSize, height: pageDotSize)
                                .foregroundColor(currentIndex == 0 ? pimaryHeartColor : secondaryHeartColor)
                                .transition(AnyTransition.opacity.combined(with: .scale))
                                .id(index)
                        default:
                            Circle()
                                .fill(currentIndex == index ? primaryColor : secondaryColor)
                                .scaleEffect(currentIndex == index ? 1 : smallScale)
                                .frame(width: pageDotSize, height: pageDotSize)
                                .transition(AnyTransition.opacity.combined(with: .scale))
                                .id(index)
                        }
                    }
                }
            }.padding(.bottom, 9)
        }
    }
    
    
    // MARK: - Private Methods
    
    func shouldShowIndex(_ index: Int) -> Bool {
        ((currentIndex - visualRange)...(currentIndex + visualRange)).contains(index)
    }
}
