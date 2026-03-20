#if canImport(IronSource)
import Foundation

func bidscubeInvokeOptional(_ target: AnyObject, selector selectorName: String) {
    guard let object = target as? NSObject else { return }
    let selector = NSSelectorFromString(selectorName)
    guard object.responds(to: selector) else { return }
    object.perform(selector)
}
#endif
