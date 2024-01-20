import SwiftUI
//import Charts
//
//struct DummyChart: View {
//    @GestureState private var selectedElement: Int?
//    let items: [Int]
//    init() {
//        var values = [Int]()
//        for i in 0..<50 {
//            values.append(i)
//        }
//        self.items = values
//    }
//    var body: some View {
//        Chart {
//            ForEach(items, id: \.self) { index in
//                LineMark(x: .value("X", index),
//                         y: .value("Y", index))
//                .interpolationMethod(.catmullRom)
//                .annotation(position: .top, spacing: 10) {
//                    let value = Int(items[(selectedElement ?? items.indices.last) ?? 0] * 100 / 180)
//                    Text("\(value)%")
//                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
//                        .padding(7)
//                        .background(.green, in: RoundedRectangle(cornerRadius: 8))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(lineWidth: 1)
//                                .foregroundStyle(.black)
//                        )
//                }
//            }
//            PointMark(x: .value("X", 20),
//                      y: .value("Y", 10))
//        }
//        .chartOverlay(content: spatialTapOverlay)
//    }
//    
//    private func spatialTapOverlay(_ proxy: ChartProxy) -> some View {
//        GeometryReader { geo in
//            Rectangle().fill(.clear).contentShape(Rectangle())
//                .gesture(
//                    SpatialTapGesture()
//                        .simultaneously(
//                            with: DragGesture(minimumDistance: 0)
//                                .updating($selectedElement, body: { value, state, _ in
//                                    let origin = geo[proxy.plotAreaFrame].origin
//                                    let location = CGPoint(
//                                        x: value.location.x - origin.x,
//                                        y: value.location.y - origin.y
//                                    )
//                                    
//                                    let (position, workload) = proxy.value(at: location, as: (Int, Double).self) ?? (0, 0)
//                                    let newSelectedElement = min(items.count - 1, max(0, position))
//                                    if newSelectedElement != selectedElement {
//                                        state = newSelectedElement
//                                    }
//                                })
//                        )
//                )
//        }
//    }
//}
