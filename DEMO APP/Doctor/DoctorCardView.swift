//
//  DoctorCardView.swift
//  DEMO APP
//
//  Created by Sameer Verma on 10/07/24.
//

import Foundation
import SwiftUI

struct DoctorCardView: View {
    var doctor: Doctor
    
    var body: some View {
        VStack(spacing: 17)  {
            AsyncImage(url: doctor.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
            } placeholder: {
                ProgressView()
            }
            Text(doctor.name)
                .font(.headline)
                .foregroundColor(.primary)
                .fontWeight(.bold)
  
            
            Text(doctor.department)
                .font(.subheadline)
                .foregroundColor(.black)
            
//            Text("ID: \(doctor.idNumber)")
//                .font(.subheadline)
//                .foregroundColor(.black)
//                .padding(.bottom)
            
//            Text("Entry: \(DateFormatter.timeFormatter.string(from: doctor.entryTime))")
//                .font(.subheadline)
//                .foregroundColor(.black)
//
//            Text("Exit: \(DateFormatter.timeFormatter.string(from: doctor.exitTime))")
//                .font(.subheadline)
//                .foregroundColor(.black)
//                .padding(.bottom)
        }
        .frame(width: 200, height: 200) // Fixed width and height
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 1.5)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
