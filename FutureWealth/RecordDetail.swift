//
//  RecordDetail.swift
//  FutureWealth
//
//  Created by Ttaa on 4/28/22.
//

import SwiftUI

struct RecordDetail: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.date, ascending: false )],
        predicate: NSPredicate(format: "category == %@", "All Investments")
    ) var logs: FetchedResults<Log>
    
    @State var showingAlert:Bool = false
    
    let instrument:String
    
    
    var body: some View {
        
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
                    ForEach(logs, id: \.self){ log in
                        VStack{
                            RecordDetailCard(
                                date: formatDate(date: log.date ?? Date()),
                                change: "0.4", capital: String(log.capital)
                            )
                                .background(Color(color_primary))
                        }
                        .listRowInsets(EdgeInsets())
                        .frame(height: 95)
                        .background(Color(color_primary))
                        
                    }
                    .swipeActions(content: {
                        Button(action: {
                            showingAlert = true
                        }, label: {
                            Image("delete")
                        })
                        .tint(Color(color_primary))
                    })
                        
                }
                .listStyle(PlainListStyle())
                
            }
            .padding(30)
            .alert("Delete This Log?", isPresented: $showingAlert){
                Button("Delete", role: .destructive){
                    
                }
            }
            
//            .alert(isPresented: $showingAlert){
//                Alert(
//                    title: Text("Delete This Log?"),
//                    primaryButton: .destructive(Text("Delete")),
//                    secondaryButton: .cancel()
//                )
//
//            }
        }
    }
}


struct RecordDetail_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetail()
    }
}

struct RecordDetailCard: View {
    let date:String
    let change:String
    let capital:String
    
    var body: some View {
        ZStack{
            
            Color(color_secondary).opacity(0.15).frame(minWidth: 330, maxHeight:83).cornerRadius(10)
            VStack(alignment: .leading, spacing: 16){
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(color_secondary))
                        .font(Font.custom("SF Compact", size: 14))
                    Text("04/22/2022").foregroundColor(Color(additional_color))
                        .font(Font.custom("SF Compact", size: 12))
                }
                HStack(spacing: 15){
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(Color(color_secondary))
                            .font(Font.system(size: 20, weight: .bold))
                        HStack {
                            Text("\(change)%").foregroundColor(Color(color_secondary))
                                .font(Font.custom("SF Compact", size: 20))
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
                            Text("5,000").foregroundColor(Color(color_secondary))
                                .font(Font.custom("SF Compact", size: 20))
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
    dateFormatter.dateFormat = "mm/DD/YYYY"
    return dateFormatter.string(from: date)

}
