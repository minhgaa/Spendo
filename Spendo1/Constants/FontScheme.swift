import Foundation
import SwiftUI

class FontScheme: NSObject {
    static func kWorkSansRegular(size: CGFloat) -> Font {
        return Font.custom(FontConstant.kWorkSansRegular, size: size)
    }

    static func kWorkSansSemiBold(size: CGFloat) -> Font {
        return Font.custom(FontConstant.kWorkSansSemiBold, size: size)
    }

    static func kWorkSansMedium(size: CGFloat) -> Font {
        return Font.custom(FontConstant.kWorkSansMedium, size: size)
    }

    static func kWorkSansBold(size: CGFloat) -> Font {
        return Font.custom(FontConstant.kWorkSansBold, size: size)
    }

    static func kInterRegular(size: CGFloat) -> Font {
        return Font.custom(FontConstant.kInterRegular, size: size)
    }

    static func kInterMedium(size: CGFloat) -> Font {
        return Font.custom(FontConstant.kInterMedium, size: size)
    }

    static func kInterSemiBold(size: CGFloat) -> Font {
        return Font.custom(FontConstant.kInterSemiBold, size: size)
    }

    static func fontFromConstant(fontName: String, size: CGFloat) -> Font {
        var result = Font.system(size: size)

        switch fontName {
        case "kWorkSansRegular":
            result = self.kWorkSansRegular(size: size)
        case "kWorkSansSemiBold":
            result = self.kWorkSansSemiBold(size: size)
        case "kWorkSansMedium":
            result = self.kWorkSansMedium(size: size)
        case "kWorkSansBold":
            result = self.kWorkSansBold(size: size)
        case "kInterRegular":
            result = self.kInterRegular(size: size)
        case "kInterMedium":
            result = self.kInterMedium(size: size)
        case "kInterSemiBold":
            result = self.kInterSemiBold(size: size)
        default:
            result = self.kWorkSansRegular(size: size)
        }
        return result
    }

    enum FontConstant {
        /**
         * Please Add this fonts Manually
         */
        static let kWorkSansRegular: String = "WorkSans-Regular"
        /**
         * Please Add this fonts Manually
         */
        static let kWorkSansSemiBold: String = "WorkSans-SemiBold"
        /**
         * Please Add this fonts Manually
         */
        static let kWorkSansMedium: String = "WorkSans-Medium"
        /**
         * Please Add this fonts Manually
         */
        static let kWorkSansBold: String = "WorkSans-Bold"
        /**
         * Please Add this fonts Manually
         */
        static let kInterRegular: String = "InterRegular"
        /**
         * Please Add this fonts Manually
         */
        static let kInterMedium: String = "Inter-Medium"
        /**
         * Please Add this fonts Manually
         */
        static let kInterSemiBold: String = "Inter-SemiBold"
    }
}
