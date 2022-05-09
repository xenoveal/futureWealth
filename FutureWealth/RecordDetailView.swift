//
//  RecordDetail.swift
//  FutureWealth
//
//  Created by Ttaa on 4/28/22.
//

import SwiftUI
import CoreData


struct RecordDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var showingAlert:Bool = false
    @State private var logSelected: Int?
    
    let instrument: String
    let category: Category
    var logs: [Log] {
        var categoryLog = category.toLog?.allObjects as? [Log]
        categoryLog?.sort {
            $0.date! > $1.date!
        }
        if(categoryLog != nil){
            return categoryLog!
        }else{
            return []
            
        }
    }
    
    func removeLog(logIndex: Int) {
        let log = logs[logIndex]
        if(category.toLog!.count<=1){
            LogController.shared.delete(category)
        }
        else{
            if(logIndex == 0){
                category.currentCapital = logs[1].capital
            }
            LogController.shared.delete(log)
        }
        
    }
    
    func calcChange(logCapital: Double, index: Int) -> String{
        if(index==logs.count-1){ return "0.0" }
        let previousLogCapital = logs[index+1].capital
        let change = (logCapital-previousLogCapital)/previousLogCapital

        return String(format: "%.0f", change*100)
    }
    
    
    var body: some View {
//        let withIndex = logs.enumerated().map({ $0 })
//        let withIndex = Array(zip(logs.indices, logs)
        
        ZStack {
            Color(color_primary).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 26){
                Image(instrument.lowercased())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45, alignment: .center)
                Text("All Investments").foregroundColor(Color(color_thrid))
                    .font(Font.custom("SF Compact", size: 20))
                List{
                    ForEach(Array(zip(logs.indices, logs)), id: \.1){ index, log in
//                        let log=logs[index]
                        VStack{
                            RecordDetailCard(
                                date: formatDate(date: log.date ?? Date()),
                                change: calcChange(logCapital: log.capital, index: index), capital: log.capital
                            )
                                .background(Color(color_primary))
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .frame(height: 95)
                        .background(Color(color_primary))
                        .swipeActions(content: {
                            Button(action: {
                                showingAlert.toggle()
                                self.logSelected = index
                            }, label: {
                                Image("delete")
                            })
                            .tint(Color(color_primary))
                        })
                        
                    }
//                    .onDelete(perform: removeLog)
                        
                        .alert("Delete This Log?", isPresented: $showingAlert){
                            Button("Delete", role: .destructive){
//                                print(self.logSelected ?? Log())
                                removeLog(logIndex: self.logSelected ?? 0)
                            }
                        }
                        
                }
                .listStyle(PlainListStyle())
                
            }
            .padding(30)
        }
    }
}


struct RecordDetail_Previews: PreviewProvider {
//    @State static var openRecordSheet:Bool = true
    static var previews: some View {
        RecordDetailView(instrument: "PancakeSwap", category: Category())
    }
}

struct RecordDetailCard: View {
    let date:String
    let change:String
    let capital:Double
    
    var body: some View {
        let capitalFormatted = String(format: "%.2f", capital)
        ZStack{
            
            Color(color_secondary).opacity(0.15).frame(minWidth: 330, maxHeight:83).cornerRadius(10)
            VStack(alignment: .leading, spacing: 16){
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(color_secondary))
                        .font(Font.custom("SF Compact", size: 14))
                    Text(date).foregroundColor(Color(additional_color))
                        .font(Font.custom("SF Compact", size: 12))
                }
                HStack(spacing: 15){
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(Color(color_secondary))
                            .font(Font.system(size: 20, weight: .bold))
                        HStack {
                            Text("\(change)%").foregroundColor(Color(color_secondary))
                                .font(Font.custom("SF Compact", size: 16))
                            Text("Change").foregroundColor(Color(additional_color))
                                .font(Font.custom("SF Compact", size: 12))
                        }
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "banknote")
                            .foregroundColor(Color(color_secondary))
                            .font(Font.system(size: 20, weight: .bold))
                        HStack {
                            Text(capitalFormatted).foregroundColor(Color(color_secondary))
                                .font(Font.custom("SF Compact", size: 16))
                            Text("Capital").foregroundColor(Color(additional_color))
                                .font(Font.custom("SF Compact", size: 12))
                        }
                    }
                }
                
            }
            .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .leading
            )
            .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))

        }
    }
}


private func formatDate(date:Date) -> String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/YYYY  •  hh:mma"
    return dateFormatter.string(from: date)

}
