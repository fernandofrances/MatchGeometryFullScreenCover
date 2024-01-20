import SwiftUI

#Preview {
    InfoTickerView()
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

enum InfoItem: CaseIterable {
    case location
    case weather
    case health
    
    static var cases: [InfoItem] {
        return [.location, .health, .weather]
    }
    
    var title: String {
        switch self {
        case .location:
            return "Location"
        case .weather:
            return "Weather"
        case .health:
            return "Health"
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
        switch self {
        case .location:
            return AnyView(HStack (spacing: 10){
                InfoContent("Rafa Nadal Academy")
                InfoDot()
                InfoContent(title: "Elevation", "80m")
                InfoDot()
                InfoContent(title: "Location", "Very Nice")
            })
        case .weather:
            return AnyView(HStack(spacing: 10) {
                InfoContent("18º")
                InfoDot()
                InfoContent(title: "Conditions", "Clear")
                InfoDot()
                InfoContent(title: "Humidity", "66%")
            })
        case .health:
            return AnyView(HStack(spacing: 10) {
                InfoContent(title: "Energy", "214kcal")
                InfoDot()
                InfoContent(title: "Heart", "123bpm")
            })
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
    
    init(item: InfoItem, width containerWidth: CGFloat, isActive: Bool, drag: CGFloat?) {
        self.item = item
        self.containerWidth = containerWidth
        self.isActive = isActive
        self.isDragging = drag != nil
        self.dragOffset = drag ?? 0
    }
    
    let scrollOffset: CGFloat = 200
    
    @State var width: CGFloat?
    @State var offset: CGFloat = 0
    @State var shouldDouble = false
    @State var timer: Timer?
    
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
            item.content
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
                .frame(width: 2000, alignment: .leading)
                .offset(x: offset)
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
    
    @State var isComplete: Bool = false
    
    let symbolSize = CGFloat(16)
    
    func next() {
        if currentIndex == 2 {
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
            ZStack {
                ForEach(0..<5) { i in
                    let itr = i - 1
                    let index = (InfoItem.cases.count + itr) % InfoItem.cases.count
                    let item = InfoItem.cases[index]
                    let isActive: Bool = {
                        let currentIndex: Int
                        if let drag, abs(drag) > 30 {
                            currentIndex = self.currentIndex + Int(-drag / abs(drag))
                        } else {
                            currentIndex = self.currentIndex
                        }
                        return currentIndex == index || (index == 2 && currentIndex == -1)
                    }()
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: item.symbol)
                                .resizable()
                                .scaledToFill()
                                .frame(width: symbolSize, height: symbolSize)
                            HStack(spacing: 20) {
                                Text(item.title)
                                Spacer()
                                Color.clear
                                    .frame(width: symbolSize, height: symbolSize)
                            }
                            .animation(.snappy(duration: 0.4)) { content in
                                content.opacity(isActive || drag != nil ? 1 : 0)
                            }
                        }
                        .saturation(isActive ? 1 : 0)
                        .opacity(isActive ? 1 : 0.6)
                        .foregroundColor(item.color)
                        .offset(x: (width - symbolSize) * CGFloat(itr - currentIndex) + (drag ?? 0))
                        
                        TickerWrapper(item: item, width: width, isActive: currentIndex == index, drag: drag)
                            .equatable()
                            .offset(x: (width + 64) * CGFloat(itr - currentIndex) + (drag ?? 0) * 1.5)
                    }
                }
            }
            HStack {
                ForEach(0..<InfoItem.cases.count) { itr in
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
                    if newIndex == InfoItem.cases.count {
                        currentIndex = -1
                    } else if newIndex == -1 {
                        currentIndex = InfoItem.cases.count
                    }
                    schedule()
                    withAnimation(.smooth(duration: 0.4)) {
                        currentIndex += change
                        drag = nil
                    }
                })
        )
        .onTapGesture {
            next()
            schedule()
        }
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
