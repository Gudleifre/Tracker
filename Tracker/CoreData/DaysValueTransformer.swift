import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Weekday] else { return nil }
        
        do {
            let data = try JSONEncoder().encode(days)
            return data as NSData
        } catch {
            print("Error encoding days of the week: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        
        do {
            let days = try JSONDecoder().decode([Weekday].self, from: data as Data)
            return days
        } catch {
            print("Error decoding days of the week: \(error)")
            return nil
        }
    }
    
    static func register() {
        let transformer = DaysValueTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName(String(describing: DaysValueTransformer.self))
        )
    }
}
