
//
//  DataModel.swift
//  HMS_admin_Demo_02
//
//  Created by Sameer Verma on 06/07/24.
//

import Foundation
import UIKit

struct Patient: Identifiable {
    var id: UUID = UUID()
    var name: String
    var contactNumber: String
    var email: String
    var address: String
    var gender: String
    var dob: Date  // changes from age
    var image: UIImage?
    var emergencyContact: String
    var upcomingAppointments: [Appointment]?
    var previousDoctors: [String]?
    var imageName: String {
        image != nil ? "patient_image" : "person.circle"
    } // extra
}




//-------------------------------------------------------
// *************   Doctor Data Model *********************



enum Departments : String {
    case general = "General",cardiology = "Cardiology",nurology = "Nurology",pediatrics = "Pediatrics",dermatology = "Dermatology",ophthalmology = "Ophthalmology"
}

struct Appointment {
    var id: String
    var patientId: String
    var doctorId: String
    var date: Date
    var timeSlot: AppointmentSlot
    var status: AppointmentStatus
    var isPremium: Bool
    var paymentStatus: PaymentStatus
}

struct AppointmentSlot {
    var startTime: String
    var endTime: String
}

enum AppointmentStatus {
    case confirmed
    case cancelled
    case rescheduled
    case pendingPayment
}

enum PaymentStatus {
    case paid
    case unpaid
}

enum Days : String{
    case monday = "Monday",tuesday = "Tuesday",wednesday = "Wednesday",thursday = "Thusday",friday = "Friday",saturday = "Saturday",sunday = "Sunday"
}
//
//struct MedicalRecord {
//    var id: String
//    var type: RecordType
//    var date: Date
//    var details: String
//    var attachments: [Attachment]
//}
//
//enum RecordType {
//    case labReport
//    case bill
//    case prescription
//}
//
//struct Attachment {
//    var id: String
//    var fileName: String
//    var fileURL: URL
//}
//
//struct Review {
//    var patientId: String
//    var doctorId: String
//    var rating: Double
//    var comment: String
//    var date: Date
//}
//
//struct FollowUp {
//    var id: String
//    var appointmentId: String
//    var date: Date
//    var timeSlot: AppointmentSlot
//    var status: FollowUpStatus
//}
//
//enum FollowUpStatus {
//    case scheduled
//    case completed
//    case missed
//}
//
//struct SOSAlert {
//    var id: String
//    var patientId: String
//    var time: Date
//    var status: SOSStatus
//    var vitals: [Vital]
//}
//
//enum SOSStatus {
//    case initiated
//    case acknowledged
//    case resolved
//}
//
//struct Vital {
//    var type: VitalType
//    var value: String
//    var unit: String
//}
//
//enum VitalType {
//    case heartRate
//    case bloodPressure
//    case temperature
//}
    

