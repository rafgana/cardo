import UIKit
import SwiftUI

enum HapticFeedback {
    @MainActor static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    @MainActor static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    @MainActor static func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    @MainActor static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    @MainActor static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    @MainActor static func selection() { UISelectionFeedbackGenerator().selectionChanged() }

    @MainActor
    static func prCelebration() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            success()
        }
    }

    @MainActor
    static func tierUp() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            medium()
        }
    }

    @MainActor
    static func setCompleted() {
        light()
    }
}

struct PRCelebrationView: View {
    let prType: PRType
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var particles: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                Text("🏆")
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(particles ? 5 : -5))

                Text(prType.emoji)
                    .font(.title)

                Text(prType.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                switch prType {
                case .estimated1RM(let old, let new):
                    Text("\(old.clean)kg → \(new.clean)kg")
                        .font(.headline)
                        .foregroundStyle(.orange)
                case .reps(let weight, let old, let new):
                    Text("\(weight.clean)kg: \(old) → \(new) reps")
                        .font(.headline)
                        .foregroundStyle(.orange)
                case .volume(let old, let new):
                    Text("\(Int(old))kg → \(Int(new))kg")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }

                Button("Seguir") {
                    HapticFeedback.medium()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.orange.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            HapticFeedback.prCelebration()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.easeInOut(duration: 0.3).repeatCount(6, autoreverses: true)) {
                particles.toggle()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.5
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}

struct TierAnimationView: View {
    let tier: Tier
    @State private var animate = false

    var body: some View {
        VStack(spacing: 8) {
            Text(tier.icon)
                .font(.system(size: 64))
                .scaleEffect(animate ? 1.0 : 0.3)
                .rotationEffect(.degrees(animate ? 0 : -180))

            Text(tier.rawValue)
                .font(.title.bold())
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

struct SetRowModifier: ViewModifier {
    let isCompleted: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isCompleted ? 0.7 : 1)
            .overlay(
                isCompleted ?
                Rectangle()
                    .fill(.green.opacity(0.05))
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 4)
                    )
                : nil
            )
    }
}
