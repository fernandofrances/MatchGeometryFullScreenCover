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
    @State var show: Bool = false
    @State var selectedItem: Int?
    @Namespace var namespace
    @State var scrollOffset: Double = 0.0
    var body: some View {
        NavigationStack {
            ScrollViewOffset { offset in
                print(offset)
                scrollOffset = offset
            } content: {
                Header(selectedItem: $selectedItem)
                ForEach(0..<4) { index in
                    OverView(
                        namespace: namespace,
                        id: index,
                        selectedItem: $selectedItem,
                        show: $show
                    ) {
                        DummyChart()
                    }
                    .blur(radius: selectedItem != nil ? 5 : 0)
                    .opacity(selectedItem != nil ? 0 : 1)
                }
            }
            .customFullScreenCover(show: $show) {
                if let selectedItem {
                    DetailView(
                        id: selectedItem,
                        namespace: namespace,
                        selectedItem: $selectedItem,
                        content: {
                            DummyChart()
                        }, detailedContent: {
                            VStack {
                                Text("Titulo otra vez")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus euismod quis purus nec feugiat. Sed mi erat, sagittis sed mollis nec, bibendum sit amet mauris. Sed pellentesque, sapien ut faucibus venenatis, sem leo cursus purus, in posuere sem odio id lacus. In eget fringilla nulla. Aenean a nisi sit amet metus feugiat ultricies luctus vel purus. Vivamus cursus lobortis leo vitae placerat. Vestibulum ut eleifend ipsum, at congue lectus. Nullam mollis purus at eros ultricies lobortis. Pellentesque cursus id ante elementum vehicula")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        })
                }
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
        VStack {
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
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("3:34pm")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 24)
            
            HStack {
                Text("\(Text("Workout Activity").foregroundStyle(.black)) \(Text("• 24 min").foregroundStyle(.gray))").font(.system(size: 24, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(Image(systemName: "ellipsis"))")
                    .font(.system(size: 12))
                    .padding(10)
                    .background(
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.gray.opacity(0.3))
                    )
            }
            .padding(.horizontal, 24)
        }
        .offset(y: selectedItem != nil ? 20 : 0)
        .blur(radius: selectedItem != nil ? 5 : 0)
        .opacity(selectedItem != nil ? 0 : 1)
    }
}

struct OverView<Content: View>: View {
    var namespace: Namespace.ID
    var id: Int
    @Binding var selectedItem: Int?
    @Binding var show: Bool
    @ViewBuilder let content: Content
    
    public init(
        namespace: Namespace.ID,
        id: Int,
        selectedItem: Binding<Int?>,
        show: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.namespace = namespace
        self.id = id
        self._selectedItem = selectedItem
        self._show = show
        self.content = content()
    }
    
    public var body: some View {
        VStack {
            content
                .matchedGeometryEffect(id: "content" + "\(id)", in: namespace)
                .frame(height: 200)
            Text("Titulo")
                .matchedGeometryEffect(id: "title" + "\(id)", in: namespace)
                .opacity(selectedItem == nil ? 1 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Subtitlo")
                .matchedGeometryEffect(id: "subtitle" + "\(id)", in: namespace)
                .opacity(selectedItem == nil ? 1 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .stroke(lineWidth: 1)
                .foregroundStyle(.gray.opacity(0.3))
                .matchedGeometryEffect(id: "\(id)", in: namespace)
        )
        .onTapGesture {
            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                selectedItem = id
                show.toggle()
            }
        }
        .padding()
    }
}


struct DetailView<Content: View, DetailedContent: View>: View {
    var namespace: Namespace.ID
    var id: Int
    
    @State var animate: Bool = false
    @State var animateTransition: Bool = false
    
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
        ScrollView {
            VStack {
                if animateTransition {
                    HStack(spacing: 12) {
                        Text("\(Image(systemName: "chevron.left"))")
                            .font(.system(size: 12))
                            .padding(10)
                            .background(
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(.gray.opacity(0.3))
                            )
                        Text("Workout Activity")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top))
                    ZStack(alignment: .bottom) {
                        content
                            .matchedGeometryEffect(id: "content" + "\(id)", in: namespace)
                            .frame(height: 200)
                        Text("Titulo")
                            .matchedGeometryEffect(id: "title" + "\(id)", in: namespace)
                            .transition(.opacity)
                            .opacity(0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Subtitlo")
                            .matchedGeometryEffect(id: "subtitle" + "\(id)", in: namespace)
                            .opacity(0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.gray.opacity(0.3))
                            .matchedGeometryEffect(id: "\(id)", in: namespace)
                    )
                    .padding()
                }
                
                detailedContent
                    .offset(y: animate ? 0 : UIScreen.main.bounds.size.height)
                    .padding()
            }
        }
        .background(
            Rectangle()
                .foregroundStyle(.thickMaterial)
                .opacity(animate ? 1 : 0)
                .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                animate = true
                animateTransition = true
            }
        }
        .onTapGesture {
            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                animateTransition = false
                animate = false
                selectedItem = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    dismiss()
                }
            }
        }
    }
}



extension View {
    @ViewBuilder func customFullScreenCover<Content: View>(show: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(HelperCustomFullScreenCoverView(show: show, overlay: content()))
    }
}
struct HelperCustomFullScreenCoverView<Overlay: View>: ViewModifier {
    @Binding var show: Bool
    var overlay: Overlay
    @State private var hostView: CustomHostingView<Overlay>?
    @State private var parentController: UIViewController?
    
    func body(content: Content) -> some View {
        content
            .background(
                ExtractSwiftUIViewParentController(content: overlay, hostView: $hostView, parentController: { viewController in
                    parentController = viewController
                })
            )
            .onAppear {
                hostView = CustomHostingView(show: $show, rootView: overlay)
            }
            .onChange(of: show) { _, newValue in
                if newValue {
                    if let hostView {
                        hostView.modalPresentationStyle = .overCurrentContext
                        hostView.modalTransitionStyle = .crossDissolve
                        hostView.view.backgroundColor = .clear
                        
                        parentController?.present(hostView, animated: false)
                    }
                } else {
                    hostView?.dismiss(animated: false)
                }
            }
    }
}
struct ExtractSwiftUIViewParentController<Content: View>: UIViewRepresentable {
    var content: Content
    @Binding var hostView: CustomHostingView<Content>?
    var parentController: (UIViewController?) -> ()
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        hostView?.rootView = content
        DispatchQueue.main.async {
            parentController(uiView.superview?.superview?.parentController)
        }
    }
}
public extension UIView {
    var parentController: UIViewController? {
        var responder = self.next
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        
        return nil
    }
}
class CustomHostingView<Content: View>: UIHostingController<Content> {
    @Binding var show: Bool
    
    init(show: Binding<Bool>, rootView: Content) {
        self._show = show
        super.init(rootView: rootView)
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        show = false
    }
    
}


#Preview {
    ContentView()
}
