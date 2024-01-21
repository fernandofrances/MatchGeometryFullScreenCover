import SwiftUI
import Charts

struct DummyChart: View {
    @GestureState private var selectedElement: Int?
    let items: [Int]
    init() {
        var values = [Int]()
        for i in 0..<50 {
            values.append(i)
        }
        self.items = values
    }
    var body: some View {
        Chart {
            ForEach(items, id: \.self) { index in
                LineMark(x: .value("X", index),
                         y: .value("Y", index))
                .interpolationMethod(.catmullRom)
            }
            PointMark(
                x: .value("X", selectedElement ?? 0),
                y: .value("Y", selectedElement ?? 0)
            )
            .symbol(Circle()
                .strokeBorder(style: .init(lineWidth: 1))
            )
            .symbolSize(CGSize(width: 7, height: 7))
            .foregroundStyle(.blue)
        }
        .chartOverlay(content: spatialTapOverlay)
    }
    
    private func spatialTapOverlay(_ proxy: ChartProxy) -> some View {
        GeometryReader { geo in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .gesture(
                    SpatialTapGesture()
                        .sequenced(before: DragGesture(minimumDistance: 10)
                                .updating($selectedElement, body: { value, state, _ in
                                    let origin = geo[proxy.plotAreaFrame].origin
                                    let location = CGPoint(
                                        x: value.location.x - origin.x,
                                        y: value.location.y - origin.y
                                    )
                                    
                                    let (position, workload) = proxy.value(at: location, as: (Int, Double).self) ?? (0, 0)
                                    let newSelectedElement = min(items.count - 1, max(0, position))
                                    if newSelectedElement != selectedElement {
                                        state = newSelectedElement
                                    }
                                })
                        )
                )
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
                    InfoTickerView()
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
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus euismod quis purus nec feugiat. Sed mi erat, sagittis sed mollis nec, bibendum sit amet mauris. Sed pellentesque, sapien ut faucibus venenatis, sem leo cursus purus, in posuere sem odio id lacus. In eget fringilla nulla. Aenean a nisi sit amet metus feugiat ultricies luctus vel purus. Vivamus cursus lobortis leo vitae placerat. Vestibulum ut eleifend ipsum, at congue lectus. Nullam mollis purus at eros ultricies lobortis. Pellentesque cursus id ante elementum vehicula Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus euismod quis purus nec feugiat. Sed mi erat, sagittis sed mollis nec, bibendum sit amet mauris. Sed pellentesque, sapien ut faucibus venenatis, sem leo cursus purus, in posuere sem odio id lacus. In eget fringilla nulla. Aenean a nisi sit amet metus feugiat ultricies luctus vel purus. Vivamus cursus lobortis leo vitae placerat. Vestibulum ut eleifend ipsum, at congue lectus. Nullam mollis purus at eros ultricies lobortis. Pellentesque cursus id ante elementum vehicula")
                            .font(.system(size: 16, weight: .regular))
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
            }
        }
        .ignoresSafeArea(edges: .bottom)
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
                    .opacity(selectedItem != nil ? 0 : 1)
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
    @State var contentHeight: Double = 0.0
    @State var scrollViewContentHeight: Double = 0.0
    
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
                if offset > 130 {
                    dismissAnimation()
                }
            } onBottomOffsetChange: { bottomOffset in
                print(bottomOffset)
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
                        .frame(height: contentHeight)
                    
                    VStack {
                        Text("Titulo del detalle")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.bottom, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(y: detailOffset)
                        Text("Subtitulo del detalle que puede ser bastante largo")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.gray)
                            .lineSpacing(4)
                            .padding(.bottom, 32)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(y: detailOffset*1.2)
                        detailedContent
                            .offset(y: detailOffset*1.5)
                    }
                    .offset(y: animate ? 0 : UIScreen.main.bounds.size.height)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    ArticleFooter()
                }
                .background {
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                scrollViewContentHeight = proxy.size.height
                                print("Scroll view content height: \(scrollViewContentHeight)")
                                print("Screen size height: \(UIScreen.main.bounds.size.height)")
                                print("Resta: \(scrollViewContentHeight - UIScreen.main.bounds.size.height)")
                            }
                        }
                    }
                }
            }
            .scrollClipDisabled()
            .padding(.top, 18)
            
            Rectangle()
                .foregroundStyle(
                    .linearGradient(.init(colors: [.red, .red, .clear]), startPoint: .top, endPoint: .bottom)
                )
                .frame(height: 360)
                .ignoresSafeArea()
                .opacity(gradientOpacity)
            
            
            ZStack(alignment: .top) {
                content
                    .matchedGeometryEffect(id: "content" + "\(id)", in: namespace)
                    .frame(height: 200)
                VStack(spacing: 32) {
                    Color
                        .clear
                        .frame(height: dummyBackgroundHeight)
                    ZStack {
                        Text("At 40%, your effort maxed out below your potential")
                            .font(.system(size: 22, weight: .bold))
                            .matchedGeometryEffect(id: "title" + "\(id)", in: namespace)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(contentTextOpacity)
                            .offset(y: contentTextOffset)
                            .padding(.bottom, 24)
                        Text("More about why this matters...")
                            .matchedGeometryEffect(id: "subtitle" + "\(id)", in: namespace)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(0)
                            .padding(.bottom, 24)
                    }
                    .padding(.trailing, 40)
                    //.clipped() // IF scrolloffset < 0
                    .opacity(0.75)
                }
            }
            .padding([.horizontal, .top], 24)
            .background(
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 18)
                        .matchedGeometryEffect(id: "background" + "\(id)", in: namespace)
                        .foregroundStyle(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(lineWidth: 1)
                                .matchedGeometryEffect(id: "backgroundStroke" + "\(id)", in: namespace)
                                .foregroundStyle(.gray.opacity(0.3))
                        )
                        .onAppear {
                            contentHeight = proxy.size.height + 32
                        }
                }
            )
            .shadow(
                color: .gray.opacity(shadowOpacity), radius: 10
            )
            .padding(.horizontal, 16)
            .padding(.top, 78)
            .scaleEffect(contentScaleEffect, anchor: .leading)
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
    
    var dummyBackgroundHeight: Double {
        min(200, max(110,(200 + scrollOffset*1.5)))
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
        1 + scrollOffset/50
    }
    
    var contentTextOffset: Double {
        return max(0, -scrollOffset*2)
    }
    
    var shadowOpacity: Double {
        min(1, -scrollOffset/30)
    }
    
    var gradientOpacity: Double {
        min(1, -scrollOffset/84)
    }
    
    var detailOffset: Double {
        return max(0, scrollOffset)
    }
    
    var headerVerticalOffset: Double {
        return -max(0, scrollOffset) / 2
    }
    
    var contentOffset: Double {
        return max(-42, scrollOffset)
    }
    
    var contentScaleEffect: Double {
        return bezier(min(1, max(0.7, 1 + scrollOffset*0.005)))
    }
    
    func dismissAnimation() {
        withAnimation(.spring(duration: 0.55, bounce: 0.2)) {
            animate = false
            selectedItem = nil
        }
    }
    
    func bezier(_ value: Double) -> Double {
        let square = value * value;
        return square / (2.0 * (square - value) + 1.0)
    }
}

public struct ArticleFooter: View {
    @State var thumbs: Bool? = nil
    public var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("Help us make Forma better.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Was this helpful?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: 12) {
                    Button(action:{
                        thumbs = thumbs != nil ? (thumbs == true ? false : nil) : false
                    }, label: {
                        Image(systemName: thumbs != nil ? (thumbs == false ? "hand.thumbsdown.fill" : "hand.thumbsdown") : "hand.thumbsdown.fill")
                            .foregroundStyle(thumbs != nil ? (thumbs == false ? .red : .white.opacity(0.12)) : .white)
                            .background(
                                Circle()
                                    .foregroundStyle(thumbs == false ? .clear : .gray.opacity(0.5))
                                    .frame(width: 48, height: 48)
                            )
                            .overlay(
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(.red)
                                    .frame(width: 48, height: 48)
                                    .opacity(thumbs == false ? 1: 0)
                            )
                            .frame(width: 48, height: 48)
                    })
                    
                    Button(action:{
                        thumbs = thumbs != nil ? (thumbs == false ? true : nil) : true
                    }, label: {
                        Image(systemName: thumbs != nil ? (thumbs == true ? "hand.thumbsup.fill" : "hand.thumbsup") : "hand.thumbsup.fill")
                            .foregroundStyle(thumbs != nil ? (thumbs == true ? .green : .white.opacity(0.12)) : .white)
                            .background(
                                Circle()
                                    .foregroundStyle(thumbs == true ? .clear : .gray.opacity(0.5))
                                    .frame(width: 48, height: 48)
                            )
                            .overlay(
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(.green)
                                    .frame(width: 48, height: 48)
                                    .opacity(thumbs == true ? 1: 0)
                            )
                            .frame(width: 48, height: 48)
                    })
                }
            }
            .padding(.horizontal, 24)
            Rectangle()
                .frame(height: 1)
                .padding(.horizontal, 24)
            HStack() {
                Text("Last updated January 2024")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.bottom, 70)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Image(.formaFooter)
                    .resizable()
                    .colorMultiply(.white)
                    .frame(width: 90, height: 80)
            }
        }
        .padding(.top, 32)
        .background(.black)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview {
    ContentView()
}
