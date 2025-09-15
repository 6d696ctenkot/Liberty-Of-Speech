import SwiftUI

struct Whisper: Identifiable {
    let id = UUID()
    var location: CGPoint
    var brightness: Double = 1.0
}

struct Darkness: Identifiable {
    let id = UUID()
    var location: CGPoint
    var radius: CGFloat = 5.0
}

struct ContentView: View {
    @State private var whispers = [Whisper]()
    @State private var darkness = [Darkness]()
    @State private var isFeatherBroken = false
    @State private var bloodSpreadAmount: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                if isFeatherBroken {
                    Rectangle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: geometry.size.width * bloodSpreadAmount,
                               height: geometry.size.height * bloodSpreadAmount)
                        .scaleEffect(bloodSpreadAmount)
                        .blur(radius: 10 * bloodSpreadAmount)
                        .animation(.easeOut(duration: 5.0), value: bloodSpreadAmount)
                }

                ForEach(whispers) { whisper in
                    Circle()
                        .fill(Color.white.opacity(whisper.brightness))
                        .frame(width: 10, height: 10)
                        .position(whisper.location)
                        .blur(radius: 5)
                }

                ForEach(darkness) { dark in
                    Circle()
                        .fill(Color.black)
                        .frame(width: dark.radius * 2, height: dark.radius * 2)
                        .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 2))
                        .position(dark.location)
                }

                if !isFeatherBroken {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        .transition(.opacity)
                } else {
                    Text("...")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }

            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !isFeatherBroken else { return }
                        
                        let newWhisper = Whisper(location: value.location)
                        whispers.append(newWhisper)

                        for i in 0..<whispers.count {
                            for dark in darkness {
                                let distance = hypot(whispers[i].location.x - dark.location.x, whispers[i].location.y - dark.location.y)
                                if distance < dark.radius + 5 {
                                    whispers[i].brightness *= 0.95
                                }
                            }
                        }
                        
                        whispers.removeAll { $0.brightness < 0.1 }

                        if Int.random(in: 0...15) == 0 {
                            let newDarkness = Darkness(location: CGPoint(x: CGFloat.random(in: 0...geometry.size.width),
                                                                          y: CGFloat.random(in: 0...geometry.size.height)))
                            darkness.append(newDarkness)
                        }

                        for i in 0..<darkness.count {
                            darkness[i].radius += 0.05
                        }
                        
                        let darkArea = darkness.reduce(0) { $0 + (Double.pi * $1.radius * $1.radius) }
                        let totalArea = geometry.size.width * geometry.size.height
                        if darkArea / totalArea > 0.6 {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                isFeatherBroken = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation {
                                    bloodSpreadAmount = 1.0
                                }
                            }
                        }
                    }
            )
        }
    }
}

#Preview {
    ContentView()
}
