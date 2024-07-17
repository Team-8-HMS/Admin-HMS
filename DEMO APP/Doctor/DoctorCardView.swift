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
        VStack(spacing: 17) {
            if let imageURL = doctor.imageURL, let url = URL(string: imageURL.absoluteString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            }
            
            Text(doctor.name)
                .font(.system(size: 24, weight: .semibold)) // Larger font size for name
                .foregroundColor(.primary)
            
            Text(doctor.department)
                .font(.system(size: 18, weight: .regular)) // Regular font size for department
                .foregroundColor(.secondary)
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
