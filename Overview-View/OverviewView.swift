
//
//  OverviewView.swift
//  HMS_admin_Demo_02
//
//  Created by Sameer Verma on 04/07/24.
//

import SwiftUI
import Charts
import FirebaseFirestore

struct OverviewView: View {
    
    @StateObject var appModel = AppViewModel()
    @State private var selectedSegment = "Yearly"
    private let segments = ["Weekly", "Monthly", "Yearly"]
    @State private var doctorCount: Int = 0 // State variable to store doctor count
    @State private var requestsCount: Int = 0 // State variable to store request count
    @State private var pendingRequestsCount: Int = 0 // State variable to store pending request count
    @State private var PatientCount: Int = 0
    

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Overview Section
                HStack {
                    Text("Overview")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading, 16)
                        .padding(.top)
                    Spacer()
                }

                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        OverviewBox(title: "Today's Appointment", value: "\(getAppointment())", image: "person.3").frame(width: 310)
                        OverviewBox(title: "Doctors", value: "\(doctorCount)", image: "stethoscope").frame(width: 310)
                        OverviewBox(title: "Patients", value: "\(PatientCount)", image: "person").frame(width: 310)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    HStack(spacing: 16) {
                        OverviewBox(title: "Leave Requests", value: "\(pendingRequestsCount)", image: "person.fill.checkmark").frame(width: 310)
                        OverviewBox(title: "Departments", value: "6", image: "building.columns").frame(width: 310)
                        OverviewBox(title: "Today's Revenue", value: "\(TodayRevenueApp())", image: "creditcard").frame(width: 310)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

                // Chart Section
                HStack(spacing: 16) {
                    VStack {
                        Picker("Select", selection: $selectedSegment) {
                            ForEach(segments, id: \.self) { segment in
                                Text(segment)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        LineChart(data: getData(for: selectedSegment), labels: getLabels(for: selectedSegment))
                            .frame(height: geometry.size.height * 0.5)
                            .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 4)
                            .padding(.top,10)
                    )
                    
                    VStack {
                        Text("Department - wise Revenue")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        
                        DonutChartView(segments: [
                            (color: Color.orange, value: 41.0),
                            (color: Color.blue, value: 12.0),
                            (color: Color.gray, value: 13.0),
                            (color: Color.red, value: 34.0)
                        ])
                        .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
                        

                        HStack() {
                            Legend(color: .orange, text: "Cardiology")
                            Legend(color: .gray, text: "Neurology")
                            Legend(color: .red, text: "Eye")
                            Legend(color: .blue, text: "Dental")
                        }
                        .padding()
                        
                        
                        Spacer()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 4)
                    )
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.3)
                }
                .padding(.horizontal, 16)
            }
//            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                fetchDoctorCount() // Fetch doctor count when the view appears
                fetchPatientCount()
                fetchRequestCount()
               
            }
        }
        .background(Color("LightColor").opacity(0.7))
        .edgesIgnoringSafeArea(.all)
    }
    
    func getAppointment() -> Int{
        ForEach(appModel.todayApp) { appointment in
                AppointmentRow(appointment: appointment)}
        return appModel.todayApp.count
    }
    
    
    func TodayRevenueApp() -> Int{
        var todayRevenueApp = 0
        ForEach(appModel.todayApp) { appointment in
            AppointmentRow(appointment: appointment)
//            todayRevenueApp = todayRevenueApp + appModel.doctorData[appointment.doctorId]?.visitingFeeOfDoctor ?? 0
        }
        return todayRevenueApp
        
    }
    
        func getData(for segment: String) -> [Double] {
        switch segment {
        case "Weekly":
            return [20, 45, 75, 50, 65, 45, 80]
        case "Monthly":
            return [20, 45, 75, 50, 65, 45, 80, 20, 45, 75, 50, 65, 45, 80, 20, 45, 75, 50, 65, 45, 80]
        case "Yearly":
            return [20, 45, 75, 50, 65, 45, 80, 20, 45, 75, 50, 65, 45]
        default:
            return []
        }
    }

    func getLabels(for segment: String) -> [String] {
        
        switch segment {
        case "Weekly":
            return ["1", "2", "3", "4", "5", "6", "7"]
        case "Monthly":
            return ["1-10", "11-20", "21-30"]
        case "Yearly":
            return ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        default:
            return []
        }
    }

    func fetchDoctorCount() {
        let db = Firestore.firestore()
        db.collection("Doctors").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                doctorCount = querySnapshot?.documents.count ?? 0
            }
        }
    }
    
    func fetchRequestCount() {
            let db = Firestore.firestore()
            db.collection("requests").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    if let documents = querySnapshot?.documents {
                        requestsCount = documents.count
                        pendingRequestsCount = documents.filter { ($0.data()["status"] as? String) == "Pending" }.count
                    }
                }
            }
        }
    
    func fetchPatientCount() {
        let db = Firestore.firestore()
        db.collection("Patient").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                PatientCount = querySnapshot?.documents.count ?? 0
            }
        }
    }
}

struct OverviewBox: View {
    var title: String
    var value: String
    var image: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: image)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
                Spacer()
            }
            Spacer()
            HStack {
                Text(value)
                    .font(.title)
                    .bold()
                Spacer()
            }
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#E1654A"))
                .shadow(radius: 5)
                .opacity(0.15)
                
            
        )
        .frame(height: 120)
    }
}

struct LineChart: View {
    var data: [Double]
    var labels: [String]
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let maxValue = 100.0
            let points = data.enumerated().map { index, value in
                CGPoint(x: (width / CGFloat(data.count - 1)) * CGFloat(index),
                        y: (1 - CGFloat(value / maxValue)) * height)
            }
            
            Path { path in
                path.move(to: points.first ?? .zero)
                for point in points {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.red, lineWidth: 2)
            
            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                Circle()
                    .fill(Color.red)
                    .frame(width: 4, height: 4)
                    .position(point)
            }
            
            VStack {
                HStack {
                    ForEach(["0", "25", "50", "75", "100"], id: \.self) { yLabel in
                        Text(yLabel)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                Spacer()
                HStack {
                    ForEach(labels, id: \.self) { label in
                        Text(label)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct DonutChartView: View {
    var segments: [(color: Color, value: Double)]
    var thickness: CGFloat = 40

    private var total: Double {
        segments.map { $0.value }.reduce(0, +)
    }

    private func angle(for value: Double) -> Angle {
        .degrees(360 * value / total)
    }

    var body: some View {
        ZStack {
            ForEach(0..<segments.count) { index in
                let startAngle = index == 0 ? Angle.zero : angle(for: segments.prefix(index).map { $0.value }.reduce(0, +))
                let endAngle = angle(for: segments.prefix(index + 1).map { $0.value }.reduce(0, +))

                DonutSegment(startAngle: startAngle, endAngle: endAngle, thickness: thickness)
                    .fill(segments[index].color)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct DonutSegment: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let innerRadius = radius - thickness

        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addLine(to: CGPoint(x: center.x + innerRadius * CGFloat(cos(endAngle.radians)), y: center.y + innerRadius * CGFloat(sin(endAngle.radians))))
        path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct Legend: View {
    var color: Color
    var text: String

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.caption)
                .foregroundColor(color)
        }
    }
}

#Preview {
    OverviewView()
}


