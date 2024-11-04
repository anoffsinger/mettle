//
//  WelcomeView.swift
//  Mettle
//
//  Created by Adam Noffsinger on 9/29/24.
//

import SwiftUI

struct WelcomeView: View {
  @Binding var showWelcomeModal: Bool
  var body: some View {
    ZStack (alignment: .bottom){
      ScrollView {
        Image("Welcome")
          .resizable()
          .aspectRatio(contentMode: .fit)
        
        VStack {
          VStack {
            HStack {
              Text("Welcome to Metal")
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(2) // Allow up to 2 lines to wrap
                .layoutPriority(1) // Prioritize space for this text
              Text("Alpha")
                .padding(4)
                .background(Color("ForegroundAlt"))
                .cornerRadius(8)
                .font(.system(size: 15, weight: .medium))
            }
            Text("Metal's a simple app for tracking PRs at the gym. It's geared towards olympic lifters, power lifters, and CrossFitters.")
              .multilineTextAlignment(.center)
              .lineLimit(nil) // Allow unlimited lines
              .padding(.horizontal)
          }
          
          Spacer().frame(height: 32)
          
          VStack(alignment: .leading, spacing: 16) {
            WelcomeTipView(tipHeadline: "Log your PRs", tipBody: "When you set a new personal record (PR), log it in the app", iconName: "pencil.and.list.clipboard")
            WelcomeTipView(tipHeadline: "Track your progress over time", tipBody: "See your PRs charted over time and view your historical notes", iconName: "chart.xyaxis.line")
            WelcomeTipView(tipHeadline: "Calculate workout percentages", tipBody: "Quickly calculate percentages for WODs based on your current PRs", iconName: "percent")
          }
          
          
          
          Spacer().frame(height: 150)
        
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        
        
      }
      .edgesIgnoringSafeArea(.all)
      .background(Color("BackgroundAlt"))
      VStack {
        Divider()
          .frame(maxWidth: .infinity)
        Spacer()
          .frame(height: 16)
        
        VStack {
          Button(action: {
            showWelcomeModal = false // Dismiss the modal
          }) {
            Text("Get Started")
              .font(.system(size: 17, weight: .bold))
              .foregroundColor(Color.white)
          }
          .frame(maxWidth: .infinity, maxHeight: 56)
          .background(
            LinearGradient(
              gradient: Gradient(colors: [Color(hex: "F91F60"), Color(hex: "EC1B80")]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .cornerRadius(20)
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .inset(by: 1)
              .stroke(Color("ButtonBorder"), lineWidth: 2)
          )
          
        }
        .padding(.horizontal, 16)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 100)
      .background(Color("BackgroundAlt"))
      
    }
  }
}

struct WelcomeTipView: View {
  
  let tipHeadline: String
  let tipBody: String
  let iconName: String
  
  var body: some View {
    HStack (spacing: 16) {
      ZStack {
        Image(systemName: iconName)
          .foregroundStyle(Color("Action"))
          .fontWeight(.bold)
      }
      .frame(width: 48, height: 48)
      .background(Color("ForegroundAlt"))
      .cornerRadius(16)
      
      VStack(alignment: .leading) {
        Text(tipHeadline)
          .font(.headline)
          .lineLimit(nil) // Allow wrapping
        
        Text(tipBody)
          .font(.system(size: 15, weight: .regular))
          .multilineTextAlignment(.leading)
          .lineLimit(nil) // Allow wrapping
          
        
      }
      
    }
  }
}

#Preview {
  WelcomeView(showWelcomeModal: .constant(false))
}
