//
//  MockPaymentView.swift
//  Liste
//
//  Created by Miles Broomfield on 02/03/2021.
//

import SwiftUI

struct MockPaymentView: View {
    @Environment(\.colorScheme) var colorScheme
    let amount:Double
    let onSuccess:()->Void
    let dismiss:()->Void
    
    var body: some View {
        VStack(alignment:.leading,spacing:20){
            VStack{
                HStack{
                    Text("Checkout")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action:{dismiss()}){
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height:15)
                    }
                }
                .padding(.horizontal,10)

                Rectangle()
                    .foregroundColor(ThemePresets.accentColor)
                    .frame(height:1)
            }
            VStack(spacing:20){
                HStack{
                    Image(systemName: "tag")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height:20)
                        .foregroundColor(ThemePresets.accentColor)
                    Text("Donation Total")
                    Spacer()
                    Text("£\(String(format: "%.2f",amount))")
                        .font(.body)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                }
                Text("We will deduct 6% + 70p as a service and proccessing fee from your donation.")
                    .font(.caption)
            }
            .padding(.horizontal,10)

            VStack(alignment:.leading,spacing:20){
                Button(action:{
                        onSuccess()
                }){
                    Rectangle()
                        .foregroundColor(ThemePresets.accentColor)
                        .frame(height:50)
                        .cornerRadius(10)
                        .overlay(Text("Donate").font(.headline).bold()            .foregroundColor(.white))
                }
                
                Text("Please note that you may only donate at the rate specified.")
                    .font(.caption)
            }
            .padding(.horizontal,10)
            .padding(.top)
        }
        .foregroundColor(self.colorScheme == .light ? .black :.white)
        .padding(.bottom,40)
    }
}

struct MockPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        MockPaymentView(amount: 5.34, onSuccess: {}, dismiss: {})
            .preferredColorScheme(.dark)
    }
}
