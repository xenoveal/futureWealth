//
//  ContentView.swift
//  FutureWealth
//
//  Created by Ttaa on 4/26/22.
//

import SwiftUI

let color_primary = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)
let color_secondary = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.00)
let color_thrid = UIColor(red: 0.39, green: 0.82, blue: 1.00, alpha: 1.00)
let additional_color = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.00)
let disabled_color = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.00)

struct HomepageView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.currentCapital, ascending: false )]
//        ,
//        predicate: NSPredicate(format: "category == %@", "All Investments")
    ) var categories: FetchedResults<Category>
    
   
    var body: some View {
//        Button(type(of: categories)){
//            print(type(of: categories))
//        }
        ZStack{
            Color(color_primary).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 35){
                PortfolioSummaryView()
                if categories.count>0{
                    InvestmentAllocationView(categories: categories)
                    
                }
                RecordView()
            }
            .padding(16)
            
        }
        .preferredColorScheme(.dark) 
        
    }
}

struct HomepageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomepageView()
        }
    }
}

struct PortfolioSummaryView: View {
    
    var body: some View {
        ZStack{
            Color(color_secondary).opacity(0.05).frame(maxHeight:197)
            VStack(alignment: .leading, spacing: 25){
                //title
                Text("Portfolio Summary").foregroundColor(Color(color_secondary)).font(.custom("SF Compact", size: 20))
                
                //metrics
                HStack(alignment: .top){
                        
                    VStack(alignment: .leading, spacing: 15){
                        HStack{
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(Color(color_secondary))
                                .font(Font.system(size: 20, weight: .bold))
                            Text("Last Week Return").foregroundColor(Color(additional_color)).font(.custom("SF Compact", size: 12))
                            
                        }
                        VStack(spacing: 8){
                            Text("$5 (0.5%)").foregroundColor(Color(color_thrid)).font(.custom("SF Compact", size: 20))
                            Text("Updated: 04/16").foregroundColor(Color(additional_color)).font(.custom("SF Compact", size: 12))
                            
                            
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 20){
                        HStack(alignment: .top){
                            
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(Color(color_secondary))
                                .font(Font.system(size: 20, weight: .bold))
                            VStack(alignment:.leading){
                                Text("60%").foregroundColor(Color(color_thrid)).font(.custom("SF Compact", size: 20))
                                Text("APR").foregroundColor(Color(color_secondary)).font(.custom("SF Compact", size: 12))
                            }
                            
                        }
                        HStack(alignment: .top){
                            
                            Image(systemName: "banknote")
                                .foregroundColor(Color(color_secondary))
                                .font(Font.system(size: 20, weight: .bold))
                            VStack(alignment:.leading){
                                Text("$5,000").foregroundColor(Color(color_thrid)).font(.custom("SF Compact", size: 20))
                                Text("Total Capital").foregroundColor(Color(additional_color)).font(.custom("SF Compact", size: 12))
                            }
                            
                        }
                    }
                    Spacer()
                }
            }.padding(25)
        }.cornerRadius(20)
    }
}

struct InvestmentAllocationView: View {
    let categories:FetchedResults<Category>

    var body: some View {
        VStack(alignment: .leading){
            Text("Investment Allocation").foregroundColor(Color(color_secondary)).font(.custom("SF Compact", size: 20)).padding(EdgeInsets(top: 0, leading: 16, bottom: 26, trailing: 0))
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(categories, id: \.self){ category in
                        AllocationCard(
                            capital: category.currentCapital,
                            category: category.name!,
                            instrument: category.instrument!
                        )
                    }
                    
                }
                
            }
        }
    }
}


struct RecordView: View {
    @State var  selectedInstrument: String = "PancakeSwap"
    @State var openForm: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 26){
            Text("Record Investment Allocation").foregroundColor(Color(color_secondary))
                .font(.custom("SF Compact", size: 24))
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            HStack{
                Text("Instrument").foregroundColor(Color(color_secondary))
                    .font(.custom("SF Compact", size: 16))
                Spacer()
                Menu(selectedInstrument){
                    Picker(selection: $selectedInstrument, label: EmptyView()) {
                        Text("PancakeSwap")
                            .tag("PancakeSwap")
                        Text("KoinWorks")
                            .tag("KoinWorks")
                        Text("Ethermine")
                            .tag("Ethermine")
                    }
                    
                }
                .padding(EdgeInsets(top: 8, leading: 25, bottom: 8, trailing: 25))
                .frame(minWidth: 150)
                .background(Color(color_secondary).cornerRadius(5)
                    .opacity(0.13))
                .foregroundColor(Color(color_secondary))
                .font(Font.custom("SF Compact", size: 12))
                    
            }
            Button(action: {
                openForm.toggle()
            }, label: {
                Image(systemName: "camera.viewfinder")
                Text("New Record in Pancake Swap")
            })
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background(Color(color_secondary).opacity(0.05))
            .foregroundColor(Color(color_thrid))
            .cornerRadius(10)
            .font(Font.custom("CF Compact", size: 16))
            .sheet(isPresented: $openForm, content: {FormSheet(openForm: $openForm ,instrument: selectedInstrument)})
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        Spacer()
    }
}

struct AllocationCard: View {
//    let category:Category
    let capital:Double
    let category:String
    let instrument:String
    
    
    @State var openRecordSheet:Bool = false
    var body: some View {
//        let capitalFormatted = (capital * 1000).rounded() / 1000
        let capitalFormatted = String(format: "%.0f", capital)
        
        VStack{
            Image(instrument.lowercased())
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35, alignment: .center)
            VStack{
                ZStack{
                    Color(color_secondary).cornerRadius(10).frame(minWidth: 128, maxHeight:68).opacity(0.1)
                    VStack(spacing: 7){
                        Text("50%").foregroundColor(Color(color_secondary))
                            .font(Font.custom("SF Compact", size: 20))
                        Text("or \(capitalFormatted)USD")
                            .foregroundColor(Color(additional_color))
                            .font(Font.custom("SF Compact", size: 12))
                    }
                }
                
            }
            Text("All Investments").foregroundColor(Color(color_secondary))
                .font(Font.custom("SF Compact", size: 12))
        }
        .sheet(isPresented: $openRecordSheet, content: {
            RecordDetail(instrument: instrument)
        })
        .onTapGesture {
            openRecordSheet.toggle()
        }
    }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}
