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

extension Date {

    /// Create a date from specified parameters
    ///
    /// - Parameters:
    ///   - year: The desired year
    ///   - month: The desired month
    ///   - day: The desired day
    /// - Returns: A `Date` object
    static func from(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? nil
    }
}

struct HomepageView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.currentCapital, ascending: false )]
//        ,
//        predicate: NSPredicate(format: "category == %@", "All Investments")
    ) var categories: FetchedResults<Category>
    
    func getTotalCapital(categoryData:FetchedResults<Category>) -> Double {
        var total: Double = 0.0
        for c in categoryData {
            total+=c.currentCapital
        }
        return total
    }
    
    func getOneWeekCapital(categoryData:FetchedResults<Category>, startDate:Date, endDate: Date) -> Double {
        var total: Double = 0.0
        var logs: [Log]
        var capitalPerCategory: Double
        var earliestDate: Date
        
        for c in categoryData {
            logs = c.toLog?.allObjects as! [Log]
            capitalPerCategory = 0.0
            earliestDate = Date.from(year: 2000, month: 10, day: 10) ?? Date()
            
            for log in logs.reversed() {
                if let date = log.date {
                    if(startDate<=date && date<=endDate && date>earliestDate){
                        capitalPerCategory = log.capital
                        earliestDate = date
                    }
                    
                }
            }
            
            total+=capitalPerCategory
        }
        return total
    }
    
    
   
    var body: some View {
//        Button(type(of: categories)){
//            print(type(of: categories))
//        }
        let totalCapital = getTotalCapital(categoryData: categories)
        
        let calendar = Calendar.current
        let currentDate = calendar.dateComponents([.day, .month, .year, .calendar], from: Date()).date
        let oneWeekBeforeDate = calendar.date(byAdding: .day, value: -7, to: Date())
        
        
        let lastWeekProfit = totalCapital-getOneWeekCapital(categoryData: categories, startDate: oneWeekBeforeDate ?? Date(), endDate: currentDate ?? Date())
        ZStack{
            Color(color_primary).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 35){
                PortfolioSummaryView(
                    totalCapital: totalCapital,
                    lastWeekProfit: lastWeekProfit
                )
                if categories.count>0{
                    InvestmentAllocationView(categories: categories, totalCapital: totalCapital)
                    
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
    let totalCapital:Double
    let lastWeekProfit: Double
    
    var body: some View {
        let formattedCapital:String = String(format: "%.0f", totalCapital)
        let formattedLastWeekProfit:String = String(format: "%.0f", lastWeekProfit)
        let lastWeekProfitPercentage = String(format: "%.0f", lastWeekProfit/totalCapital*100)
        let APR = String(format: "%.1f", ((lastWeekProfit/totalCapital)-1)*5214.2857)
        let currentDate = formatDate(date: Date.now)
        
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
                            Text("$\(formattedLastWeekProfit) (\(lastWeekProfitPercentage)%)").foregroundColor(Color(color_thrid)).font(.custom("SF Compact", size: 20))
                            Text("Updated: \(currentDate)").foregroundColor(Color(additional_color)).font(.custom("SF Compact", size: 12))
                            
                            
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 20){
                        HStack(alignment: .top){
                            
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(Color(color_secondary))
                                .font(Font.system(size: 20, weight: .bold))
                            VStack(alignment:.leading){
                                Text("\(APR)%").foregroundColor(Color(color_thrid)).font(.custom("SF Compact", size: 20))
                                Text("APR").foregroundColor(Color(color_secondary)).font(.custom("SF Compact", size: 12))
                            }
                            
                        }
                        HStack(alignment: .top){
                            
                            Image(systemName: "banknote")
                                .foregroundColor(Color(color_secondary))
                                .font(Font.system(size: 20, weight: .bold))
                            VStack(alignment:.leading){
                                Text("$\(formattedCapital)").foregroundColor(Color(color_thrid)).font(.custom("SF Compact", size: 20))
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
    let totalCapital: Double

    var body: some View {
        VStack(alignment: .leading){
            Text("Investment Allocation").foregroundColor(Color(color_secondary)).font(.custom("SF Compact", size: 20)).padding(EdgeInsets(top: 0, leading: 16, bottom: 26, trailing: 0))
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(categories, id: \.self){ category in
                        AllocationCard(
                            category: category,
                            totalCapital: totalCapital
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
            .sheet(isPresented: $openForm, content: {FormSheetView(openForm: $openForm ,instrument: selectedInstrument)})
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        Spacer()
    }
}

struct AllocationCard: View {
    let category:Category
    let totalCapital: Double
    
    @State var openRecordSheet:Bool = false
    var body: some View {
//        let capitalFormatted = (capital * 1000).rounded() / 1000
        let capitalFormatted = String(format: "%.0f", category.currentCapital)
        let allocationPercentage = String(format: "%.0f", category.currentCapital/totalCapital*100)
        
        //50,000
        
        VStack{
            Image(category.instrument?.lowercased() ?? "")
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35, alignment: .center)
            VStack{
                ZStack{
                    Color(color_secondary).cornerRadius(10).frame(minWidth: 128, maxHeight:68).opacity(0.1)
                    VStack(spacing: 7){
                        Text("\(allocationPercentage)%").foregroundColor(Color(color_secondary))
                            .font(Font.custom("SF Compact", size: 20))
                        Text("or \(capitalFormatted)USD")
                            .foregroundColor(Color(additional_color))
                            .font(Font.custom("SF Compact", size: 12))
                    }
                }
                
            }
            Text(category.name ?? "").foregroundColor(Color(color_secondary))
                .font(Font.custom("SF Compact", size: 12))
        }
        .sheet(isPresented: $openRecordSheet, content: {
            RecordDetailView(instrument: category.instrument ?? "", category: category)
        })
        .onTapGesture {
//            for category in categories{
//                LogController.shared.delete(category)
//            }
            openRecordSheet.toggle()
        }
    }
}

private func formatDate(date:Date) -> String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd"
    return dateFormatter.string(from: date)

}
