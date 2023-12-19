import SwiftUI

/**
 * Displayed when there are no tasks in the view model.
 * Slides in from below when visible.
 */
struct OnboardingView: View {
    
    // MARK: Environment Variables
    @EnvironmentObject var settings: SettingsStore
    
    // MARK: Constants
    let noItemsBlob = "Looking to organize your life? Taskmaster can help with that. Press the big purple button below to begin composing your first task."
    let blobPadding:   CGFloat = DeviceUtilities.isPhone() ? 30 : 200
    let initialOffset: CGFloat = -300.0
    let animateOffset: CGFloat = DeviceUtilities.isTablet() ? -400.0 : -100.0
    
    // MARK: Stateful Variables
    @State var animate = false
    
    var body: some View {
        VStack(spacing: 0) {
            blobSection
            promptAndButtonSection
                .padding(.top, 25)
        }
        .offset(y: animate ? (initialOffset + animateOffset) : initialOffset)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.75)) {
                    animate = true
                }
            }
        }
    }
}

// MARK: Layout Declarations
extension OnboardingView {
    
    // MARK: Superviews
    
    private var blobSection: some View {
        VStack {
            Text(noItemsBlob)
                .multilineTextAlignment(.center)
                .padding(.horizontal, blobPadding)
        }
    }
    
    private var promptAndButtonSection: some View {
        VStack(spacing: 0) {
            Text("Ready to get started? ⬇️")
                .font(.caption)
            beginComposingButton
                .padding(.horizontal)
                .padding(.bottom, 50)
                .padding(.top, 10)
                .modifier(HapticOnTapViewModifier(playOut: $settings.shouldUseHaptics.wrappedValue))
        }
    }
    
    // MARK: Subviews
    
    private var beginComposingButton: some View {
        NavigationLink(
            destination: AddView(),
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor)
                        .frame(height: 55)
                        .frame(maxWidth: 200)
                        .shadow(radius: 25, y: 15)
                    Text("Begin Composing")
                        .foregroundColor(.white)
                        .font(.headline)
                        .transition(.move(edge: .leading))
                }
            }
        )
    }
}

// MARK: Preview
#Preview {
    OnboardingView()
        .environmentObject(SettingsStore())
        .padding(.top, 500)
}
