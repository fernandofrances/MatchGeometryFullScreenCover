import SwiftUI
public struct ScrollViewOffset<Content: View>: View {
    let onOffsetChange: (CGFloat) -> Void
    let onBottomOffsetChange: (CGFloat) -> Void
    let content: () -> Content
    
    public init(
        onOffsetChange: @escaping (CGFloat) -> Void,
        onBottomOffsetChange: @escaping (CGFloat) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onBottomOffsetChange = onBottomOffsetChange
        self.onOffsetChange = onOffsetChange
        self.content = content
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            offsetReader
            bottomOffsetReader
            content()
                .padding(.top, -8)
        }
        .coordinateSpace(name: "frameLayer")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChange)
        .onPreferenceChange(BottomOffsetPreferenceKey.self, perform: onBottomOffsetChange)
    }
    
    var bottomOffsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: BottomOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("frameLayer")).maxY
                )
        }
        .frame(height: 0)
    }
    
    var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("frameLayer")).minY
                )
        }
        .frame(height: 0)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

private struct BottomOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
