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

let db = Firestore.firestore()
struct FirebaseAppointment : Identifiable{
    let id:String
    let doctorId:String
    let patientId:String
    let doctorName : String
    let patientName : String
    let date:Date
    let timeSlot:String
    let isPremium:Bool
    let status:String = "Pending"
}
var app:[FirebaseAppointment] = []


func dateConverter(dateString : String) -> Date?{
    
    let dateFormatter = DateFormatter()

    // Set the date format according to the input string
    dateFormatter.dateFormat = "dd MMMM yyyy"

    // Set the locale if needed, e.g., for English
    dateFormatter.locale = Locale(identifier: "en_US")

    if let date = dateFormatter.date(from: dateString) {
        print("Converted date: \(date)")
        return date
    } else {
        print("Failed to convert date.")
        return nil
    }
}

extension Date {
    func formattedMonthAndYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    func formattedDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }

    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }

    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }

    var startOfWeek: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)
    }
}





func fetchAppointments(){
    db.collection("Appointements").addSnapshotListener{ querySnapshot ,error in
        app = []

        guard let documents = querySnapshot?.documents else{
            print("No data found")
            return
        }
        for document in documents{
            do{
                
                let data = document.data()
            
               
                    
                    var doctorName = "name_of_doctotr_009444"
                    var patientName = "name_of_patient"
                    let id = data["id"] as? String ?? ""
                    let doctorId = data["doctorId"] as? String ?? ""
                    db.collection("Doctors").whereField("id", isEqualTo: doctorId).getDocuments { (snapshot, error) in
                    if let error = error {
                        print("\n\n error is  \(error)")
                    } else {
                        for document in snapshot?.documents ?? [] {
                            doctorName = data["name"] as? String ?? ""
                            print(doctorName)
                            }
                    }
                        
                    }
                    let patientId = data["patientId"] as? String ?? ""
                    let date = data["date"] as? String ?? ""
                    let realDate = dateConverter(dateString: date)
                    let timeSlot = data["timeSlot"] as? String ?? ""
                    let isPremium = data["isPremium"] as? Bool ?? false
                    let appointment:FirebaseAppointment = FirebaseAppointment(id: id, doctorId: doctorId, patientId: patientId,doctorName: doctorName, patientName: patientName, date: realDate ?? Date.now, timeSlot: timeSlot, isPremium: isPremium)
                    app.append(appointment)
                    print(appointment)
                
                
            }
            print(app)
        }
        
    }
}

// Appointment view  ------------------------------------------main screen---------------
struct AppointmentView: View {
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack{
        VStack {
            CalendarView(selectedDate: $selectedDate).padding(.top,80).frame(maxWidth: .infinity, alignment: .leading).font(.largeTitle)
                .fontWeight(.bold)
            
            
            //            print(app)
            List {
                
                ForEach(app.filter { $0.date.isSameDay(as: selectedDate) }) { appointment in
                    AppointmentRow(appointment: appointment)
                    //                    print(app)
                    
                }
            }
            .padding(.horizontal) // Add horizontal padding to the List
            .padding(.bottom, 10) // Add bottom padding to the List
        }
        .padding(.horizontal, -10)
        }.navigationTitle("Appointments")
        

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
                .padding(.top, -40)
            
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
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(selectedDate.isSameDay(as: day) ? Color(UIColor(red: 228 / 255, green: 101 / 255, blue: 74 / 255, alpha: 1)) : Color.gray)
                                .frame(width: 120, height: 100)
                            
                            VStack {
                                Text(day.formattedDay())
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                                
                                Text(day.formattedDate())
                                    .font(.system(size: 30))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 10)
                            }
                        }
                        .cornerRadius(15)
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
    var appointment: FirebaseAppointment

    var body: some View {
        HStack {
            Image("appointment.patient.profileImage")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(appointment.patientId)
                    .font(.headline)
                Text(appointment.doctorName)
                    .font(.headline)
                Text("\(appointment.date)")
                    .font(.subheadline)
            }.background(Color(.systemGray6))
            Spacer()
            Text(appointment.timeSlot)
                .font(.subheadline)
            Spacer()
//            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "Pending":
            return Color(red: 218/255, green: 59/255, blue: 19/255)
        case "Done":
            return Color(red: 101/255, green:200/255, blue: 102/255)
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
