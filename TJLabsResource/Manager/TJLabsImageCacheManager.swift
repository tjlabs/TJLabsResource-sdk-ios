
import Foundation
import UIKit

class TJLabsImageCacheManager {
    
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {}
}
