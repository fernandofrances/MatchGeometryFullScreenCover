import SwiftUI
import Charts

struct DummyChart: View {
    var body: some View {
        Chart {
            ForEach(0..<50, id: \.self) { index in
                LineMark(x: .value("X", index),
                         y: .value("Y", index))
                .interpolationMethod(.catmullRom)
            }
            PointMark(x: .value("X", 20),
                      y: .value("Y", 10))
        }
    }
}

struct ContentView: View {
    @State var selectedItem: Int?
    @Namespace var namespace
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    Header(selectedItem: $selectedItem)
                        .padding(.bottom, 32)
                    ForEach(0..<4) { index in
                        ScrollView(.horizontal) {
                            OverView(
                                namespace: namespace,
                                id: index,
                                selectedItem: $selectedItem
                            ) {
                                DummyChart()
                            }
                            .blur(radius: selectedItem != nil ? (selectedItem == index ? 0 : 5) : 0)
                            .opacity(selectedItem != nil ? (selectedItem == index ? 1 : 0) : 1)
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.55, bounce: 0.2)) {
                                    selectedItem = index
                                }
                            }
                        }.scrollClipDisabled()
                    }
                }
            }
            
            if let selectedItem = selectedItem {
                DetailView(
                    id: selectedItem,
                    namespace: namespace,
                    selectedItem: $selectedItem,
                    content: {
                        DummyChart()
                    }, detailedContent: {
                        VStack(spacing: 24) {
                            Text("What is workload, and why does it matter?")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus euismod quis purus nec feugiat. Sed mi erat, sagittis sed mollis nec, bibendum sit amet mauris. Sed pellentesque, sapien ut faucibus venenatis, sem leo cursus purus, in posuere sem odio id lacus. In eget fringilla nulla. Aenean a nisi sit amet metus feugiat ultricies luctus vel purus. Vivamus cursus lobortis leo vitae placerat. Vestibulum ut eleifend ipsum, at congue lectus. Nullam mollis purus at eros ultricies lobortis. Pellentesque cursus id ante elementum vehicula Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus euismod quis purus nec feugiat. Sed mi erat, sagittis sed mollis nec, bibendum sit amet mauris. Sed pellentesque, sapien ut faucibus venenatis, sem leo cursus purus, in posuere sem odio id lacus. In eget fringilla nulla. Aenean a nisi sit amet metus feugiat ultricies luctus vel purus. Vivamus cursus lobortis leo vitae placerat. Vestibulum ut eleifend ipsum, at congue lectus. Nullam mollis purus at eros ultricies lobortis. Pellentesque cursus id ante elementum vehicula")
                                .font(.system(size: 16, weight: .regular))
                                .lineSpacing(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    })
            }
        }
    }
}

struct Header: View {
    @Binding var selectedItem: Int?
    public init(selectedItem: Binding<Int?>) {
        self._selectedItem = selectedItem
    }
    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 12) {
                Text("\(Image(systemName: "chevron.left"))")
                    .font(.system(size: 12))
                    .padding(10)
                    .background(
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.gray.opacity(0.3))
                    )
                Text("TimeLine")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("3:34pm")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.gray)
            }
            .padding(.trailing, 6)
            
            HStack(alignment: .firstTextBaseline) {
                Text("\(Text("Functional Training with Rafa").foregroundStyle(.black)) \(Text("• 24 min").foregroundStyle(.gray))")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(Image(systemName: "ellipsis"))")
                    .font(.system(size: 12))
                    .padding(10)
                    .background(
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.gray.opacity(0.3))
                    )
            }
            .padding(.horizontal, 6)
        }
        .offset(y: selectedItem != nil ? 20 : 0)
        .blur(radius: selectedItem != nil ? 5 : 0)
        .opacity(selectedItem != nil ? 0 : 1)
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }
}

struct OverView<Content: View>: View {
    var namespace: Namespace.ID
    var id: Int
    @Binding var selectedItem: Int?
    @ViewBuilder let content: Content
    
    public init(
        namespace: Namespace.ID,
        id: Int,
        selectedItem: Binding<Int?>,
        @ViewBuilder content: () -> Content
    ) {
        self.namespace = namespace
        self.id = id
        self._selectedItem = selectedItem
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 32) {
            content
                .matchedGeometryEffect(id: "content" + "\(id)", in: namespace)
                .frame(height: 200)
            VStack(spacing: 16) {
                Text("At 40%, your effort maxed out below your potential")
                    .font(.system(size: 22, weight: .bold))
                    .matchedGeometryEffect(id: "title" + "\(id)", in: namespace)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("More about why this matters...")
                    .matchedGeometryEffect(id: "subtitle" + "\(id)", in: namespace)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.trailing, 40)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .matchedGeometryEffect(id: "background" + "\(id)", in: namespace)
                .foregroundStyle(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(lineWidth: 1)
                        .matchedGeometryEffect(id: "backgroundStroke" + "\(id)", in: namespace)
                        .foregroundStyle(.gray.opacity(0.3))
                )
        )
        .padding(.horizontal, 16)
        .frame(width: UIScreen.main.bounds.width)
    }
}


struct DetailView<Content: View, DetailedContent: View>: View {
    var namespace: Namespace.ID
    var id: Int
    
    @State var animate: Bool = false
    @State var scrollOffset: Double = 0.0
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedItem: Int?
    @ViewBuilder let content: Content
    @ViewBuilder let detailedContent: DetailedContent
    
    public init(
        id: Int,
        namespace: Namespace.ID,
        selectedItem: Binding<Int?>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detailedContent: () -> DetailedContent
    ) {
        self.id = id
        self.namespace = namespace
        self._selectedItem = selectedItem
        self.content = content()
        self.detailedContent = detailedContent()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewOffset { offset in
                scrollOffset = offset
                print(offset)
                if offset > 130 {
                    dismissAnimation()
                }
            } content: {
                VStack {
                    if animate {
                        HStack(spacing: 12) {
                            Text("\(Image(systemName: "chevron.left"))")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(chevronForegroundStyle)
                                .padding(10)
                                .background(
                                    Circle()
                                        .foregroundStyle(.black)
                                        .opacity(chevronBackgroundOpacity)
                                )
                                .background(
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(.gray.opacity(0.3))
                                )
                                .scaleEffect(chevronScale, anchor: .center)
                                .rotationEffect(.degrees(chevronRotation), anchor: .center)
                                .animation(.smooth, value: chevronForegroundStyle)
                                .onTapGesture {
                                    dismissAnimation()
                                }
                            Text("Workout Activity")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .opacity(titleOpacity)
                                .padding(.leading, headerHorizontalOffset)
                        }
                        .offset(x: headerHorizontalOffset, y: headerVerticalOffset)
                        .transition(.move(edge: .top))
                        .padding(.horizontal, 24)
                    }
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: 400)
                    
                    detailedContent
                        .offset(y: animate ? detailOffset : UIScreen.main.bounds.size.height)
                        .padding(.horizontal, 24)
                }
                
            }
            .contentMargins(.bottom, 60, for: .scrollContent)
            
            Rectangle()
                .foregroundStyle(
                    .linearGradient(.init(colors: [.red, .red, .clear]), startPoint: .top, endPoint: .bottom)
                )
                .frame(height: 360)
                .ignoresSafeArea()
                .opacity(gradientOpacity)
            
            VStack(spacing: 32) {
                content
                    .matchedGeometryEffect(id: "content" + "\(id)", in: namespace)
                    .frame(height: 200)
                ZStack {
                    Text("At 40%, your effort maxed out below your potential")
                        .font(.system(size: 22, weight: .bold))
                        .matchedGeometryEffect(id: "title" + "\(id)", in: namespace)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("More about why this matters...")
                        .matchedGeometryEffect(id: "subtitle" + "\(id)", in: namespace)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0)
                }
                .padding(.trailing, 40)
                .opacity(contentTextOpacity)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .matchedGeometryEffect(id: "background" + "\(id)", in: namespace)
                    .foregroundStyle(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(lineWidth: 1)
                            .matchedGeometryEffect(id: "backgroundStroke" + "\(id)", in: namespace)
                            .foregroundStyle(.gray.opacity(0.3))
                    )
            )
            .shadow(
                color: .gray.opacity(shadowOpacity), radius: 10
            )
            .padding(.horizontal, 16)
            .padding(.top, 60)
            .scaleEffect(x: scaleEffectX, y: scaleEffectY, anchor: .leading)
            //.scaleEffect(contentScaleEffect, anchor: .leading)
            .offset(y: contentOffset)
            .allowsHitTesting(false)
        }
        .background(
            Rectangle()
                .foregroundStyle(.white)
                .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.spring(duration: 0.55, bounce: 0.2)) {
                animate = true
            }
        }
    }
    
    var chevronForegroundStyle: Color {
        scrollOffset < 50 ? .black : .white
    }
    
    var chevronBackgroundOpacity: Double {
        return min(1, scrollOffset/100)
    }
    
    var headerHorizontalOffset: Double {
        return max(0, min(10, scrollOffset/10))
    }
    
    var chevronScale: Double {
        return max(1, min(1.5, (1 + scrollOffset/150)))
    }
    
    var chevronRotation: Double {
        return max(0, min(90, scrollOffset))
    }
    
    var titleOpacity: Double {
        max(0.54, scrollOffset/60)
    }
    
    var contentTextOpacity: Double {
        1 + scrollOffset/42
    }
    
    var shadowOpacity: Double {
        min(1, -scrollOffset/42)
    }
    
    var gradientOpacity: Double {
        min(1, -scrollOffset/84)
    }
    
    var detailOffset: Double {
        return max(0, scrollOffset) / 2
    }
    
    var headerVerticalOffset: Double {
        return -max(0, scrollOffset) / 2
    }
    
    var contentOffset: Double {
        return max(-42, scrollOffset)
    }
    
    var contentScaleEffect: Double {
        let maxShrink: CGFloat = 100.0
        let scalingFactor = max(1 + min(scrollOffset/2, 0) / maxShrink, 0.8)
        return min(scalingFactor, 1.0)
    }
    
    var scaleEffectY: Double {
        return 1
    }
    
    var scaleEffectX: Double {
        return 1
    }
    
    func dismissAnimation() {
        withAnimation(.spring(duration: 0.55, bounce: 0.2)) {
            animate = false
            selectedItem = nil
        }
    }
}

#Preview {
    ContentView()
}
