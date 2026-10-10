import SwiftUI

struct ContentView: View {
    @State private var started = false
    @State private var score = 0
    @State private var timeLeft = 30
    @State private var target = CGPoint(x: 0.5, y: 0.5)
    @State private var best = UserDefaults.standard.integer(forKey: "TapRushBest")
    @State private var gameID = UUID()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(red: 0.04, green: 0.06, blue: 0.18),
                                        Color(red: 0.17, green: 0.08, blue: 0.35),
                                        Color(red: 0.04, green: 0.20, blue: 0.30)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("TAP RUSH")
                                .font(.system(size: 27, weight: .black, design: .rounded))
                                .tracking(2)
                            Text("НАБЕРИ МАКСИМУМ ОЧКОВ")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .tracking(1.4)
                                .foregroundStyle(.white.opacity(0.65))
                        }
                        Spacer()
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(.yellow)
                            .padding(13)
                            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.top, 12)

                    HStack(spacing: 12) {
                        statCard(title: "ОЧКИ", value: "\(score)", symbol: "target")
                        statCard(title: "ВРЕМЯ", value: "\(timeLeft)с", symbol: "timer")
                        statCard(title: "РЕКОРД", value: "\(best)", symbol: "trophy.fill")
                    }
                    .padding(.horizontal, 18)

                    GeometryReader { board in
                      ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.white.opacity(0.055))
                            .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.12), lineWidth: 1))

                        if started && timeLeft > 0 {
                            Circle()
                                .fill(Color.cyan.opacity(0.15))
                                .frame(width: 104, height: 104)
                                .position(x: target.x * board.size.width, y: target.y * board.size.height)
                                .allowsHitTesting(false)

                            Button {
                                hitTarget(in: board.size)
                            } label: {
                                ZStack {
                                    Circle().fill(
                                        LinearGradient(colors: [.cyan, .blue, .purple],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    Circle().stroke(.white.opacity(0.9), lineWidth: 3).padding(7)
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 28, weight: .black))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 72, height: 72)
                                .shadow(color: .cyan.opacity(0.65), radius: 18)
                            }
                            .buttonStyle(.plain)
                            .position(x: target.x * board.size.width, y: target.y * board.size.height)
                            .id(gameID)
                        } else {
                            VStack(spacing: 14) {
                                Image(systemName: timeLeft == 0 ? "flag.checkered" : "hand.tap.fill")
                                    .font(.system(size: 44, weight: .bold))
                                    .foregroundStyle(.cyan)
                                Text(timeLeft == 0 ? "ВРЕМЯ ВЫШЛО!" : "ГОТОВ ИГРАТЬ?")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(timeLeft == 0 ? "Твой результат: \(score)" : "Нажимай на цель как можно быстрее")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                Button {
                                    startGame(in: board.size)
                                } label: {
                                    Text(timeLeft == 0 ? "ЕЩЁ РАЗ" : "НАЧАТЬ ИГРУ")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .tracking(1)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, 15)
                                        .background(LinearGradient(colors: [.cyan, .mint], startPoint: .leading, endPoint: .trailing), in: Capsule())
                                }
                                .padding(.top, 4)
                            }
                            .padding(22)
                        }
                      }
                    }
                    .padding(.horizontal, 18)
                    .frame(maxHeight: .infinity)

                    Text(started && timeLeft > 0 ? "ПОПАДАЙ ПО СВЕТЯЩЕЙСЯ ЦЕЛИ" : "30 СЕКУНД • БЕЗ ОГРАНИЧЕНИЙ")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.3)
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.bottom, 12)
                }
            }
            .onReceive(timer) { _ in
                guard started, timeLeft > 0 else { return }
                timeLeft -= 1
                if timeLeft == 0 {
                    started = false
                    if score > best {
                        best = score
                        UserDefaults.standard.set(best, forKey: "TapRushBest")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func statCard(title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 10, weight: .bold))
                Text(title).font(.system(size: 9, weight: .black, design: .rounded)).tracking(1)
            }
            .foregroundStyle(.white.opacity(0.62))
            Text(value).font(.system(size: 23, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(.white.opacity(0.08), lineWidth: 1))
    }

    private func startGame(in size: CGSize) {
        score = 0
        timeLeft = 30
        started = true
        moveTarget(in: size)
    }

    private func hitTarget(in size: CGSize) {
        guard started, timeLeft > 0 else { return }
        score += 1
        gameID = UUID()
        moveTarget(in: size)
    }

    private func moveTarget(in size: CGSize) {
        let safeWidth = max(size.width, 1)
        let safeHeight = max(size.height, 1)
        target = CGPoint(
            x: CGFloat.random(in: 0.15...0.85),
            y: CGFloat.random(in: 0.15...0.85)
        )
        _ = safeWidth
        _ = safeHeight
    }
}
