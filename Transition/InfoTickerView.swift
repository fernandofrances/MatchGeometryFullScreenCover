import SwiftUI

#Preview {
    ScrollView {
        InfoTickerView()
    }
}


struct InfoContent: View {
    let title: String?
    let value: String
    
    init(title: String? = nil, _ value: String) {
        self.title = title
        self.value = value
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let title {
                Text(title)
                    .lineLimit(1, reservesSpace: true)
                    .opacity(0.4)
            }
            Text(value)
                .lineLimit(1, reservesSpace: true)
        }
        .fontWeight(.medium)
    }
}

struct InfoDot: View {
    var body: some View {
        Text("·")
            .opacity(0.4)
    }
}

enum InfoItem {
    
    case location([(String?, String)])
    case weather(symbol: String?, [(String?, String)])
    case health([(String?, String)])
    
    static var cases: [InfoItem] {
        return [
            .health([
                ("Energy", "1700kcal"),
                ("Heart Rate", "123bpm"),
                ("RPE", "4"),
                ("Max Heart Rate", "123bpm")
            ]),
            .weather(symbol: "sun.max", [
                ("Temperature", "18ºC"),
                ("Humidity", "60%")
            ]),
            .location([
                (nil, "Rafa nadal Academy"),
                ("Elevation", "123m")
            ])
        ]
    }
    
    var title: String {
        switch self {
        case .location:
            return "Location"
        case .weather:
            return "Weather"
        case .health:
            return "Fitness"
        }
    }
    
    var symbol: String {
        switch self {
        case .location:
            return "location.fill"
        case .weather:
            return "sun.max.fill"
        case .health:
            return "heart.square.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .location:
            return .blue
        case .weather:
            return .orange
        case .health:
            return .pink
        }
    }
    
    var content: some View {
        let values = self.values
        return AnyView(
            HStack (spacing: 10){
                ForEach(Array(values.enumerated()), id: \.self.0) { index , item in
                    InfoContent(title: item.0, item.1)
                    if index != values.count - 1 {
                        InfoDot()
                    }
                }
            }
        )
    }
    
    var values: [(String?, String)] {
        switch self {
        case .location(let array):
            return array
        case .weather(_, let array):
            return array
        case .health(let array):
            return array
        }
    }
}

struct TickerWrapper: View, Equatable {
    static func == (lhs: TickerWrapper, rhs: TickerWrapper) -> Bool {
        lhs.isActive == rhs.isActive &&
        lhs.isDragging == rhs.isDragging &&
        lhs.dragOffset == rhs.dragOffset
    }
    
    let item: InfoItem
    let containerWidth: CGFloat
    let isActive: Bool
    let isDragging: Bool
    let dragOffset: CGFloat
    
    init(item: InfoItem, width containerWidth: CGFloat, isActive: Bool, drag: CGFloat?, expanded: Binding<Bool>, transition: Binding<Bool>) {
        self.item = item
        self.containerWidth = containerWidth
        self.isActive = isActive
        self.isDragging = drag != nil
        self.dragOffset = drag ?? 0
        self._expanded = expanded
        self._transition = transition
    }
    
    let scrollOffset: CGFloat = 200
    
    var layout: AnyLayout {
        transition ? AnyLayout(FlowLayout()) : AnyLayout(HStackLayout())
    }
    
    @State var width: CGFloat?
    @State var offset: CGFloat = 0
    @State var shouldDouble = false
    @State var timer: Timer?
    @Binding var expanded: Bool
    @Binding var transition: Bool
    
    func setupTicker(width: CGFloat?) {
        if let width {
            self.width = width
            if width > containerWidth {
                shouldDouble = true
                withAnimation(.linear(duration: 6)) {
                    offset = -scrollOffset
                }
            }
        } else {
            if shouldDouble {
                withAnimation(.linear(duration: 6)) {
                    offset = -scrollOffset
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            layout {
                ForEach(Array(item.values.enumerated()), id: \.self.0) { index, element in
                    InfoContent(title: element.0, element.1).padding(.trailing, 10)
                    if index != item.values.count - 1 {
                        InfoDot().padding(.trailing, 10)
                    }
                }
            }
            .overlay(alignment: .leading) {
                if shouldDouble {
                    HStack(spacing: 10, content: {
                        InfoDot()
                        item.content
                    })
                    .padding(.leading, 10)
                    .frame(width: 800, alignment: .leading)
                    .offset(x: width ?? 0)
                }
            }
            .background {
                if width == nil {
                    GeometryReader { g in
                        Color.clear
                            .onAppear {
                                setupTicker(width: g.size.width)
                            }
                    }
                }
            }
            .frame(width: transition ? UIScreen.main.bounds.width : 2000, alignment: .leading)
            .offset(x: transition ? 0 : offset)
        }
        .frame(width: containerWidth, alignment: .leading)
        .padding(.horizontal, 32)
        .mask({
            LinearGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.05),
                .init(color: .black, location: 0.95),
                .init(color: .clear, location: 1),
            ], startPoint: .leading, endPoint: .trailing)
        })
        .clipped()
        .drawingGroup()
        .padding(.horizontal, -32)
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                setupTicker(width: nil)
            } else {
                offset = 0
            }
        }
        .onChange(of: isDragging) { oldValue, newValue in
            if newValue {
                withAnimation(.snappy) {
                    offset = 0
                }
            } else {
                setupTicker(width: nil)
            }
        }
    }
}

struct InfoTickerView: View {
    @State var timer: Timer?
    @State var currentIndex: Int = 0
    @State var width: CGFloat = UIScreen.main.bounds.width - 64
    @State var drag: CGFloat?
    
    @State var layoutTransition: Bool = false
    @State var opacityTransition: Bool = false
    @State var expanded: Bool = false
    @State var shrinkTransition: Bool = false
    
    @State var isComplete: Bool = false
    
    var layout: AnyLayout {
        expanded ? AnyLayout(VStackLayout()) : AnyLayout(ZStackLayout())
    }
    
    var items = InfoItem.cases
    
    let symbolSize = CGFloat(16)
    
    func next() {
        if currentIndex == items.count - 1 {
            currentIndex = -1
        }
        withAnimation(.smooth(duration: 0.6)) {
            currentIndex = currentIndex.next
        }
    }
    
    func schedule() {
        isComplete = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 5).delay(0.4)) {
                isComplete = true
            }
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true, block: { timer in
            next()
            isComplete = false
            withAnimation(.linear(duration: 5).delay(0.5)) {
                isComplete = true
            }
        })
    }
    
    var body: some View {
            VStack {
                layout {
                    ForEach(0..<5) { i in
                        let itr = i - 1
                        let index = (items.count + itr) % items.count
                        let item = items[index]
                        let isActive = currentIndex == index
                        if drag == nil && (i==0 || i==4) {
                            EmptyView()
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: item.symbol)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: symbolSize, height: symbolSize)
                                    HStack(spacing: 6) {
                                        Text(item.title)
                                        Color.clear
                                            .frame(width: symbolSize, height: symbolSize)
                                    }
                                    .animation(.snappy(duration: 0.4)) { content in
                                        content.opacity(isActive || drag != nil ? 1 : (expanded ? 1 : 0))
                                    }
                                }
                                .saturation(expanded ? 1 : (isActive ? 1 : 0))
                                .opacity(currentIndex == index ? 1 : (shrinkTransition ? (expanded ? 1 : 0) : 0.2))
                                .foregroundColor(item.color)
                                .offset(x: shrinkTransition ? 0 : ((width - symbolSize) * CGFloat(itr - currentIndex) + (drag ?? 0)))
                                TickerWrapper(item: item, width: width, isActive: currentIndex == index, drag: drag, expanded: $expanded, transition: $layoutTransition)
                                    .equatable()
                                    .offset(x: shrinkTransition ? 0 : ((width + 64) * CGFloat(itr - currentIndex) + (drag ?? 0) * 1.5))
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .opacity(currentIndex == itr ? 1 : (opacityTransition ? 0 : 1))
                        }
                    }
                }
                
                if !shrinkTransition {
                    HStack {
                        ForEach(0..<3) { itr in
                            let item = InfoItem.cases[itr]
                            let isActive = currentIndex == itr
                            Capsule()
                                .foregroundStyle(.black.opacity(0.1))
                                .frame(maxWidth: .infinity)
                                .overlay(alignment: .leading) {
                                    if isActive {
                                        Capsule()
                                            .frame(maxWidth: isActive && isComplete ? .infinity : 0)
                                            .brightness(0.1)
                                            .foregroundStyle(item.color)
                                    }
                                }
                                .frame(height: 3)
                            
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged({ value in
                        if let timer {
                            withAnimation(.snappy) {
                                isComplete = false
                            }
                            timer.invalidate()
                            self.timer = nil
                        }
                        withAnimation(.snappy(duration: 0.1)) {
                            drag = value.translation.width
                        }
                    })
                    .onEnded({ value in
                        let change = max(-1,min(1,Int(round(-value.predictedEndTranslation.width / width))))
                        let newIndex = change + currentIndex
                        if newIndex == items.count {
                            currentIndex = -1
                        } else if newIndex == -1 {
                            currentIndex = items.count
                        }
                        schedule()
                        withAnimation(.smooth(duration: 0.4)) {
                            currentIndex += change
                            drag = nil
                        }
                    })
            )
            .background {
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        width = geometry.size.width
                    }
                }
            }
            .padding(32)
            .onAppear {
                schedule()
            }
            .onTapGesture {
                if expanded {
                    withAnimation(.snappy(duration: 0.15)) {
                        opacityTransition.toggle()
                    }
                    withAnimation(.bouncy(duration: 0.35)) {
                        expanded.toggle()
                    }
                    
                    withAnimation(.smooth(duration: 0.1).delay(0.35)) {
                        shrinkTransition.toggle()
                    }
                    
                    withAnimation(.smooth(duration: 0.35).delay(0.15)) {
                        layoutTransition.toggle()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        opacityTransition.toggle()
                        schedule()
                    }
                    
                } else {
                    opacityTransition.toggle()
                    
                    if let timer {
                        timer.invalidate()
                        self.timer = nil
                        withAnimation(.snappy) {
                            isComplete = false
                        }
                    }
                    withAnimation(.smooth(duration: 0.35)) {
                        layoutTransition.toggle()
                    }
                    
                    withAnimation(.smooth(duration: 0.1)) {
                        shrinkTransition.toggle()
                    }
                    
                    withAnimation(.bouncy(duration: 0.35).delay(0.1)) {
                        expanded.toggle()
                    }
                    
                    withAnimation(.smooth(duration: 0.35).delay(0.2)) {
                        opacityTransition.toggle()
                    }
                }
            }
    }
}

fileprivate extension Int {
    var next: Int {
        (self + 1) % InfoItem.cases.count
    }
    var previous: Int {
        (self + InfoItem.cases.count - 1) % InfoItem.cases.count
    }
}


extension View {
    @ViewBuilder public func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
