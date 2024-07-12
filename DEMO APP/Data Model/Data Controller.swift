//
//  Data Controller.swift
//  DEMO APP
//
//  Created by Sameer Verma on 08/07/24.
//

import Foundation
import SwiftUI


class DataController{
    
    static let shared = DataController() // Singleton instance
    
    
    private var Patients:[String:Patient] = [:]
//    private var Doctors:[String:Doctor] = [:]
//    private var allDoctors: [String] = []
    private var allPatients : [String] = []
//    private var doctorArray : [Doctor] = []
    private var patientArray : [Patient] = []



    private init() {
        loadData()
    }
//    func getDoctorArray() -> [Doctor] {
//        return doctorArray
//    }
    
    func getPatientArray () -> [Patient] {
        return patientArray
    }

//    func getAllDoc() -> [String]{
//        return allDoctors
//    }
    
    func getAllPat() -> [String]{
        return allPatients
    }
    
//    func getDoc(withId id:String) -> Doctor {
//        return Doctors[id]!
//    }
    
    
    func getPat(withId id:String) -> Patient {
        return Patients[id]!
    }
    
//    func setDoc(doc:Doctor){
//        Doctors["\(doc.medicalId)"] = doc
//        allDoctors.append("\(doc.medicalId)")
//        doctorArray.append(doc)
//        
//        
//    }
    
    func setPat(pat:Patient){
        Patients["\(pat.id)"] = pat
        allPatients.append("\(pat.id)")
        patientArray.append(pat)
        
        
    }
    private func loadData(){
        
        let p1 = Patient(name: "Sameer Verma", contactNumber: "9999999999", email: "sameer@gmail.com", address: "Greater Noida, UP", gender: "Male", dob: Date(), image: UIImage(named: "sameer"), emergencyContact: "1234567890", upcomingAppointments: nil, previousDoctors: nil)
        
        let p2 = Patient(name: "Ravi Prasad", contactNumber: "8888888888", email: "aryan@gmail.com", address: "Delhi", gender: "Male", dob: Date(), image: UIImage(named: "aryan"), emergencyContact: "0987654321", upcomingAppointments: nil, previousDoctors: nil)

        
    
    
       
        
        setPat(pat: p1)
        setPat(pat: p2)
        
       
        print(allPatients)
        print(Patients)
        
    }
        

}

