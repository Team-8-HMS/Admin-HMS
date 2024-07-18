//
//  AppointmentView.swift
//  HMS_admin_Demo_02
//
//  Created by Sameer Verma on 04/07/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
//var currentDateString: Date {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        formatter.timeStyle = .none
//    return formatter.date()
//    }


struct PatientModel: Identifiable {
    var id :String
    var name: String
    var contactnumber : String
    var dob : Date
    var profileImage: String
   
    var status : String
}

//DoctorModel
struct DoctorModel: Identifiable{
    var id: String
    var idNumber: Int
    var name: String
    var contactNo: String
    var email: String
    var department: String
    var imageURL: String
    var visitingFees : Int
//    var workingDays: [String]
//    var yearsOfExperience: Int
    
}


let db = Firestore.firestore()
struct FirebaseAppointment : Identifiable{
    let id:String
    let doctorId:String
    let patientId:String
    let date:Date
    let timeSlot:String
    let isPremium:Bool
    let status:String = "Pending"
}
var app:[FirebaseAppointment] = []

func dateConverter(dateString : String) -> Date?{
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM yyyy"
    dateFormatter.locale = Locale(identifier: "en_US")

    if let date = dateFormatter.date(from: dateString) {
        print("Converted date: \(date)")
        return date
    } else {
        print("Failed to convert date.")
        return nil
    }
}


// MARK: - Appointmentn View

struct AppointmentView: View {
    @StateObject var appModel = AppViewModel()
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            CalendarView(selectedDate: $selectedDate)
                .padding(.bottom, 20)
            
            Divider()
            
            HStack {
                Spacer()
                Text("Patient Details")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Doctor Details")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Time Slot")
                    .fontWeight(.bold)
                Spacer()
                    
               
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()
            
            List {
                ForEach(appModel.app.filter { $0.date.isSameDay(as: selectedDate) }) { appointment in
                    AppointmentRow(appointment: appointment)
                }
            }
            .padding(.horizontal) // Add horizontal padding to the List
            .padding(.bottom, 10) // Add bottom padding to the List
        }
        .padding(.horizontal, -10)
        .accentColor(Color(UIColor(red: 225 / 255, green: 101 / 255, blue: 74 / 255, alpha: 0.8)))
        .navigationTitle("Appointment")
    }
}

// CalendarView
struct CalendarView: View {
    @Binding var selectedDate: Date
    @State private var weekOffset: Int = 0
    private let calendar = Calendar.current
    
    private var days: [Date] {
        let today = calendar.startOfDay(for: Date())
        let startOfWeek = calendar.date(byAdding: .day, value: weekOffset * 7, to: today.startOfWeek!)!
        return (0...6).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private var currentMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack {
            Text(currentMonth)
                .font(.system(size: 40))
                .fontWeight(.bold)
                .padding(.top, 0)
            
            HStack {
                Button(action: {
                    weekOffset -= 1
                    let today = calendar.startOfDay(for: Date())
                    let startOfWeek = calendar.date(byAdding: .day, value: weekOffset * 7, to: today.startOfWeek!)!
                    selectedDate = startOfWeek // update the selected date
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .padding()
                }
                
                Spacer()
                
                ForEach(days, id: \.self) { day in
                    VStack {
                        ZStack {
                            Circle()
                                .foregroundColor(selectedDate.isSameDay(as: day) ? Color(UIColor(red: 228 / 255, green: 101 / 255, blue: 74 / 255, alpha: 1)) : Color.gray.opacity(0.6))
                                .frame(width: 80, height: 80)
                            
                            VStack {
                                Text(day.formattedDay())
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                
                                Text(day.formattedDate())
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .onTapGesture {
                            selectedDate = day
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    weekOffset += 1
                    let today = calendar.startOfDay(for: Date())
                    let startOfWeek = calendar.date(byAdding: .day, value: weekOffset * 7, to: today.startOfWeek!)!
                    selectedDate = startOfWeek // update the selected date
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .padding()
                }
            }
            .padding(.horizontal)
        }
    }
}

// AppointmentRow
struct AppointmentRow: View {
    @StateObject var appModel = AppViewModel()
    var appointment: FirebaseAppointment

    var body: some View {
        NavigationStack{
            HStack {
                // Patient
                HStack {
                    AsyncImage(url: URL(string: appModel.patientData[appointment.patientId]?.profileImage ?? "")) { image in
                        image
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .padding(.trailing, 10)
                    } placeholder: {
                        Circle()
                            .frame(width: 80, height: 80)
                            .padding(.trailing, 10)
                    }

                    VStack(alignment: .leading) {
                        Text(appModel.patientData[appointment.patientId]?.name ?? "No name found")
                            .font(.headline)
                        Text(appModel.patientData[appointment.patientId]?.contactnumber ?? "No contact found")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Divider between patient and doctor
                Divider()
                    .frame(height: 80) // Adjust the height to match the content
                    .padding(.horizontal, 10)
                
                // Doctor
                HStack {
                    AsyncImage(url: URL(string: appModel.doctorData[appointment.doctorId]?.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .padding(.trailing, 10)
                    } placeholder: {
                        Circle()
                            .frame(width: 80, height: 80)
                            .padding(.trailing, 10)
                    }

                    VStack(alignment: .leading) {
                        Text(appModel.doctorData[appointment.doctorId]?.name ?? "No name found")
                            .font(.headline)
                        Text(appModel.doctorData[appointment.doctorId]?.department ?? "No department found")
                            .font(.headline)
                        Text("\(appModel.doctorData[appointment.doctorId]?.visitingFees ?? 0) Rs")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Time Slot
                Text(appointment.timeSlot)
                    .font(.subheadline)
            }
            .padding()
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Pending":
            return Color(red: 218/255, green: 59/255, blue: 19/255)
        case "Done":
            return Color(red: 101/255, green: 200/255, blue: 102/255)
        case "Progress":
            return Color(red: 50/255, green: 0/255, blue: 255/255)
        default:
            return .gray // default color if status is unrecognized
        }
    }

    private func statusBackgroundColor(for status: String) -> Color {
        switch status {
        case "Pending":
            return Color(red: 250/255, green: 224/255, blue: 229/255)
        case "Done":
            return Color(red: 230/255, green: 246/255, blue: 231/255)
        case "Progress":
            return Color(red: 230/255, green: 230/255, blue: 247/255)
        default:
            return Color.gray.opacity(0.2)
        }
    }
}




 var todayRevenueApp = 0
// MARK: - APP Model
class AppViewModel: ObservableObject {
    @AppStorage("doctorId") var doctorId : String = ""
    @Published var app:[FirebaseAppointment] = []
    @Published var todayApp: [FirebaseAppointment] = []
  
    @Published var pendingApp: [FirebaseAppointment] = []
    @Published var patientData:[String:PatientModel] = [:]
    @Published var doctorData:[String:DoctorModel] = [:]
    
    init() {
        db.collection("Appointements").addSnapshotListener{ querySnapshot ,error in
            guard let documents = querySnapshot?.documents else{
                print("No data found")
                return
            }
            self.app = []
            self.todayApp = []
            self.pendingApp = []
            self.patientData = [:]
            for document in documents{
                do{
                    
                    let data = document.data()
                        let id = data["id"] as? String ?? ""
                        let doctorId = data["doctorId"] as? String ?? ""
                        let patientId = data["patientId"] as? String ?? ""
                        let date = data["date"] as? String ?? ""
                        let realDate = dateConverter(dateString: date)!
                        let timeSlot = data["timeSlot"] as? String ?? ""
                        let isPremium = data["isPremium"] as? Bool ?? false
                        let appointment:FirebaseAppointment = FirebaseAppointment(id: id, doctorId: doctorId, patientId: patientId, date: realDate, timeSlot: timeSlot, isPremium: isPremium)
                        if realDate.isSameDay(as: Date()) {
                            self.todayApp.append(appointment)
//                            todayRevenueApp = todayRevenueApp + doctorData.visitingFees
                        } else {
                            self.pendingApp.append(appointment)
                        }
                        print("patientid --> \(patientId)")
                        db.document("Patient/\(patientId)").getDocument{documentSnapshot , error in
                            if let error = error{
                                print("error")
                            }
                            else if let documentSnapshot , documentSnapshot.exists{
                                if let data = documentSnapshot.data(){
                                    let firstname = data["firstname"] as? String ?? ""
                                    let lastname = data["lastname"] as? String ?? ""
                                    let name = "\(firstname) \(lastname)"
                                    let contactNumber = data["contactNumber"] as? String ?? ""
                                    let image = data["imageURL"] as? String ?? ""
                                    let dob = data["dob"] as? String ?? ""
                                    let dateDOB = dateConverter(dateString: dob)
                                    self.patientData[patientId] = PatientModel(id: patientId, name: name,  contactnumber: contactNumber, dob: dateDOB ?? Date.now, profileImage: image,status: "Pending")
                                    print(self.patientData)
                                    print("HIHiHiHi")
                                    
                                }
                            }
                        }
                    db.document("Doctors/\(doctorId)").getDocument{documentSnapshot , error in
                        if let error = error{
                            print("error")
                        }
                        else if let documentSnapshot , documentSnapshot.exists{
                            if let data = documentSnapshot.data(){
                                let medicalId = data["idNumber"] as? Int ?? 000
                                let name = data["name"] as? String ?? ""
                                
                                let contactNo = data["contactNo"] as? String ?? ""
                                let department = data["department"] as? String ?? ""
                                let email = data["email"] as? String ?? ""
                                let image = data["imageURL"] as? String ?? ""
                                let visitingFees = data["visitingFees"] as? Int ?? 0
                                self.doctorData[doctorId] = DoctorModel(id: doctorId, idNumber: medicalId, name: name, contactNo: contactNo, email: email, department: department, imageURL: image,visitingFees: visitingFees)
                                print(self.doctorData)
                                print("HIHiHiHi")
                                
                            }
                        }
                    }
                        self.app.append(appointment)
                   
                    
                }
            }
        }
    }
}
