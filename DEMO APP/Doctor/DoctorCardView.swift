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
        VStack {
            AsyncImage(url: doctor.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
            } placeholder: {
                ProgressView()
            }
            Text(doctor.name)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
                .foregroundColor(.black)
            
            Text(doctor.department)
                .font(.subheadline)
                .foregroundColor(.black)
            
            Text("ID: \(doctor.idNumber)")
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.bottom)
            
            Text("Entry: \(DateFormatter.timeFormatter.string(from: doctor.entryTime))")
                .font(.subheadline)
                .foregroundColor(.black)
            
            Text("Exit: \(DateFormatter.timeFormatter.string(from: doctor.exitTime))")
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.bottom)
        }
        .frame(width: 197, height: 300)
        .background(Color.white.opacity(0.7))
        .cornerRadius(36)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.all, 5)
    }
}
