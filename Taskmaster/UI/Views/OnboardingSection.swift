import SwiftUI

/**
 * Displayed when there are no tasks in the view model.
 * Slides in from below when visible.
 */
struct OnboardingSection: View {
    
    // MARK: Environment Variables
    @EnvironmentObject
    private var settings: SettingsStore
    
    // MARK: Constants
    private let noItemsBlob   = "Looking to organize your life? Taskmaster can help with that. Press the big purple button below to begin composing your first task."
    private let blobPadding   = DeviceUtilities.isPhone() ? 30.0 : 200.0
    private let initialOffset = -300.0
    private let animateOffset = DeviceUtilities.isTablet() ? -400.0 : -100.0
    
    // MARK: Stateful Variables
    @State var animate = false
    
    public var body: some View {
        VStack(spacing: 0) {
            sectionBlob
            sectionPromptAndButton
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
extension OnboardingSection {
    
    // MARK: Superviews
    
    private var sectionBlob: some View {
        VStack {
            Text(noItemsBlob)
                .multilineTextAlignment(.center)
                .padding(.horizontal, blobPadding)
        }
    }
    
    private var sectionPromptAndButton: some View {
        VStack(spacing: 0) {
            Text("Ready to get started? ⬇️")
                .font(.caption)
            buttonBeginComposing
                .padding(.horizontal)
                .padding(.bottom, 50)
                .padding(.top, 10)
                .modifier(HapticOnTapViewModifier(playOut: $settings.shouldUseHaptics.wrappedValue))
        }
    }
    
    // MARK: Subviews
    
    private var buttonBeginComposing: some View {
        NavigationLink(
            destination: AddTaskPage(),
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
    OnboardingSection()
        .environmentObject(SettingsStore())
        .padding(.top, 500)
}
