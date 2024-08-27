import SwiftUI

struct PercentageCalculatorView: View {
    let percentages = [100, 95, 90, 85, 80, 75, 70, 65, 60, 55, 50, 45]
    let maxWeightLift: Double
    @Binding var kgViewEnabled: Bool
    @State private var selectedPercentage: Int = 100
    @State private var lastHapticValue: Int = 100
    let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // This calculates the weight based on the selected percentage
    var calculatedWeight: Double {
        let weight = maxWeightLift * (Double(selectedPercentage) / 100.0)
        return kgViewEnabled ? poundsToKilograms(pounds: weight) : weight
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Percent Calculator")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                // Format the calculated weight before displaying, with kg or lb suffix
                Text("\(formattedWeight(calculatedWeight)) \(kgViewEnabled ? "kg" : "lb")")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(percentages, id: \.self) { percentage in
                    Button(action: {
                        selectedPercentage = percentage
                        hapticGenerator.impactOccurred() // Haptic feedback on button press
                    }) {
                        Text("\(percentage)%")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 40)
                            .font(.system(size: 15, weight: .regular))
                            .background(percentage == selectedPercentage ? Color("ButtonCalcBackgroundSelected") : Color("ButtonCalcBackground"))
                            .foregroundColor(percentage == selectedPercentage ? Color("ButtonCalcForegroundSelected") : Color("TextPrimary"))
                            .cornerRadius(16)
                    }
                }
            }
            
            HStack(spacing: 24) {
                Slider(value: Binding(
                    get: { Double(selectedPercentage) },
                    set: { newValue in
                        let newIntValue = Int(newValue)
                        if newIntValue != lastHapticValue {
                            hapticGenerator.impactOccurred() // Haptic feedback on slider increment
                            lastHapticValue = newIntValue
                        }
                        updateSelectedPercentage(percentage: newIntValue)
                    }
                ), in: 0...100, step: 1)
                .tint(Color("Action"))
                .frame(maxWidth: .infinity) // Takes up remaining space in the HStack
                
                Text("\(selectedPercentage)%")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func updateSelectedPercentage(percentage: Int) {
        selectedPercentage = percentage
    }
}

#Preview {
    PercentageCalculatorView(maxWeightLift: 225.5, kgViewEnabled: .constant(true))
}
