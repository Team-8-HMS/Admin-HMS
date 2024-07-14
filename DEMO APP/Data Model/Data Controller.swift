////
////  Data Controller.swift
////  DEMO APP
////
////  Created by Sameer Verma on 08/07/24.
////
//
//import Foundation
//import SwiftUI
//
//
//class DataController{
//    
//    static let shared = DataController() // Singleton instance
//    
//    
//    private var Patients:[String:Patient] = [:]
//
//    private var allPatients : [String] = []
//
//    private var patientArray : [Patient] = []
//
//
//
//    private init() {
//        loadData()
//    }
//
//    func getPatientArray () -> [Patient] {
//        return patientArray
//    }
//
//
//    
//    func getAllPat() -> [String]{
//        return allPatients
//    }
//    
//
//    
//    func getPat(withId id:String) -> Patient {
//        return Patients[id]!
//    }
//    
//
//    
//    func setPat(pat:Patient){
//        Patients["\(pat.id)"] = pat
//        allPatients.append("\(pat.id)")
//        patientArray.append(pat)
//        
//        
//    }
//    private func loadData(){
//        
////        let p1 = Patient(firstname: "Sameer",lastname :"Verma", contactNumber: "9999999999", email: "sameer@gmail.com", address: "Greater Noida, UP", gender: "Male", dob: Date(), image: UIImage(named: "sameer"), emergencyContact: "1234567890")
////        
////        let p2 = Patient(firstname: "Ravi",lastname: " Prasad", contactNumber: "8888888888", email: "aryan@gmail.com", address: "Delhi", gender: "Male", dob: Date(), image: UIImage(named: "aryan"), emergencyContact: "0987654321")
//
//        
//    
//    
//       
////        
////        setPat(pat: p1)
////        setPat(pat: p2)
//        
//       
//        print(allPatients)
//        print(Patients)
//        
//    }
//        
//
//}
//
