import Foundation
import SwiftUI
import CascableCore

// We need this since we can't conform our `PropertyValue` protocol to `Identifiable` etc.
private struct HashablePropertyValue: Hashable, Identifiable {

    static func == (lhs: HashablePropertyValue, rhs: HashablePropertyValue) -> Bool {
        return lhs.value.isEqual(rhs.value)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value.stringValue)
    }

    let value: PropertyValue

    var displayValue: String { return value.localizedDisplayValue ?? value.stringValue  }
    var id: String { return value.stringValue }
}

struct PropertyView: View {

    let property: CameraProperty

    @State private var effectiveCurrentValue: HashablePropertyValue?
    @State private var validSettableValues: [HashablePropertyValue] = []
    @State private var propertyObserverToken: CameraPropertyObservation?

    private func addPropertyObserver() {
        propertyObserverToken = property.addObserver({ _, type in
            updateValues(for: type)
        })
    }

    private func removePropertyObserver() {
        propertyObserverToken?.invalidate()
        propertyObserverToken = nil
    }

    private func updateValues(for changeType: PropertyChangeType) {
        if changeType.contains(.validSettableValues) {
            validSettableValues = property.validSettableValues?.map({ .init(value: $0) }) ?? []
        }
        if changeType.contains(.value) || changeType.contains(.pendingValue) {
            let effectiveValue = (property.pendingValue ?? property.currentValue)
            if let effectiveValue {
                effectiveCurrentValue = .init(value: effectiveValue)
            } else {
                effectiveCurrentValue = nil
            }
        }
    }

    private func chooseValue(_ propertyValue: HashablePropertyValue) {
        property.setValue(propertyValue.value, completionHandler: { error in
            if let error { print("Setting value got error: \(error)") }
        })
    }

    var body: some View {
        VStack(spacing: 10.0) {
            Text(property.localizedDisplayName ?? "Property")
                .lineLimit(1)
                .bold()

            Menu(content: {
                ForEach(validSettableValues) { value in
                    // This is awkward as heck but it seems like the best way to get "proper" checkmarks in a menu.
                    let binding = Binding<Bool>(get: { value == effectiveCurrentValue },
                                                set: { if $0 { chooseValue(value) }})
                    Toggle(value.displayValue, isOn: binding)
                }
            }, label: {
                Text(effectiveCurrentValue?.displayValue ?? "—")
            })
            .menuStyle(.borderlessButton)
            .menuIndicator(validSettableValues.isEmpty ? .hidden : .visible)
            .fixedSize()
            .opacity(effectiveCurrentValue == nil ? 0.3 : 1.0)
            .contentShape(Rectangle())
        }
        .frame(width: 130.0)
        .padding(.vertical, 10.0)
        .onAppear {
            updateValues(for: [.value, .pendingValue, .validSettableValues])
            addPropertyObserver()
        }
        .onDisappear { removePropertyObserver() }
    }
}
