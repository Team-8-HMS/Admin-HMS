////
////  PatientCardView.swift
////  DEMO APP
////
////  Created by Sameer Verma on 13/07/24.
////
//
//import Foundation
//import SwiftUI
//
//struct PatientCardView: View {
//    var patient :  Patient
//    
//    var body: some View {
//        VStack {
//            AsyncImage(url: patient.imageURL) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 100, height: 100)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
//            } placeholder: {
//                ProgressView()
//            }
//            Text("\(patient.firstname) \(patient.lastname)")
//                .font(.headline)
//                .fontWeight(.bold)
//                .padding(.top)
//                .foregroundColor(.black)
//            
//            Text(patient.contactNumber)
//                .font(.subheadline)
//                .foregroundColor(.black)
//            
//            
//        }
//        .frame(width: 197, height: 300)
//        .background(Color.white.opacity(0.7))
//        .cornerRadius(36)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//        .padding(.all, 5)
//    }
//}
//
