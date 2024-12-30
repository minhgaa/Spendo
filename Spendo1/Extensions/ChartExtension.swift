import Foundation

struct DevTechieCourses: Identifiable {
    let id = UUID()
    let money: Double
    let category: DTCourseCategory
    let time: DTCourseTime
}

extension DevTechieCourses {
    static let data: [DevTechieCourses] = [
        .init( money: 998, category: .Income,  time: .Mon),
        .init( money: 3432, category: .Outcome,  time: .Mon),
        .init( money: 1292, category: .Income,  time: .Tue),
        .init( money: 1342, category: .Outcome,  time: .Tue),
        .init( money: 1233, category: .Income,  time: .Wed),
        .init( money: 805, category: .Outcome,  time: .Wed),
        .init( money: 900, category: .Income,  time: .Thu),
        .init( money: 570, category: .Outcome,  time: .Thu),
    ]
}

enum DTCourseCategory: String {
    case  Income = "Income"
    case Outcome = "Outcome"
}

enum DTCourseTime: String {
    case Mon = "Mon"
    case Tue = "Tue"
    case Wed = "Wed"
    case Thu = "Thu"
}
