import SwiftUI
import Charts

struct DummyColors {
    static let colors: [Color] = [.red, .yellow, .green, .blue, .black, .purple, .gray]
}

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
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(0..<4) { index in
                        OverView(
                            namespace: namespace,
                            id: index, 
                            selectedItem: $selectedItem,
                            show: $show
                        ) {
                            DummyChart()
                        }
                        
                    }
                }
            }
            .customFullScreenCover(show: $show) {
                DetailView(
                    namespace: namespace,
                           selectedItem: $selectedItem) {
                   DummyChart()
                }
            }
        }
    }
}

#Preview {
    ContentView()
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
            Text("Subtitlo")
                .matchedGeometryEffect(id: "subtitle" + "\(id)", in: namespace)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .foregroundStyle(DummyColors.colors[id])
                .matchedGeometryEffect(id: "\(id)", in: namespace)
        )
        .clipped()
        .padding()
        .onTapGesture {
            withAnimation(.snappy(duration: 0.3)) {
                selectedItem = id
                show.toggle()
            }
        }
    }
}


struct DetailView<Content: View>: View {
    var namespace: Namespace.ID
    
    @Binding var selectedItem: Int?
    
    @State var animate: Bool = false
    @State var animateTransition: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    @ViewBuilder let content: Content
    
    public init(
        namespace: Namespace.ID,
        selectedItem: Binding<Int?>,
        @ViewBuilder content: () -> Content
    ) {
        self.namespace = namespace
        self._selectedItem = selectedItem
        self.content = content()
    }
    
    var body: some View {
        VStack {
            if let selectedItem,
               animateTransition {
                content
                    .matchedGeometryEffect(id: "content" + "\(selectedItem)", in: namespace)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .foregroundStyle(DummyColors.colors[selectedItem])
                            .matchedGeometryEffect(id: "\(selectedItem)", in: namespace)
                    )
                    .frame(height: 200)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            Rectangle()
                .foregroundStyle(.ultraThinMaterial)
                .opacity(animate ? 1 : 0)
                .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.snappy(duration: 0.3)) {
                animate = true
                animateTransition = true
            }
        }
        .onTapGesture {
            withAnimation(.snappy(duration: 0.3)) {
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
