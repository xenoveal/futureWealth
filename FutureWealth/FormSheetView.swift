//
//  SwiftUIView.swift
//  FutureWealth
//
//  Created by Ttaa on 4/27/22.
//

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct FormSheetView: View {
    @Binding var openForm:Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var showScanner = true
//    @State private var texts:[String] = []
    
    let instrument:String
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.currentCapital, ascending: false )]
//        ,
//        predicate: NSPredicate(format: "category == %@", "All Investments")
    ) var categories: FetchedResults<Category>
    
//    @State var categories:[String] = ["All Investments", "Other"]
    @State var capital:String=""
    @State var category:String="All Investments"
    @State var newCategory:String=""
    @State var note:String=""
    init(openForm:Binding<Bool>, instrument:String){
        UITableView.appearance().backgroundColor = .clear
        self._openForm = openForm
        self.instrument = instrument
    }
    var body: some View {
        ZStack{
            Color(color_primary).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 26){
                Image(instrument.lowercased())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45, alignment: .center)
                Text("Add New Investment Log").foregroundColor(Color(color_thrid))
                    .font(Font.custom("SF Compact", size: 20))
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Current Capital (IDR)").font(Font.custom("SF Compact", size: 12)).foregroundColor(Color(color_secondary))
                    TextField("", text: $capital)
                        .placeholder(when: capital.isEmpty) {
                            Text("Your current capital").foregroundColor(.gray)
                        }
                        .foregroundColor(Color(color_secondary))
                        .padding(EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16))
                        .background(Color(color_secondary).opacity(0.15))
                        .cornerRadius(10)
                }
                VStack(alignment: .leading, spacing: 10){
                    Text("Category").font(Font.custom("SF Compact", size: 12)).foregroundColor(Color(color_secondary))
                    GeometryReader { proxy in
                        Menu(category){
                            Picker(selection: $category, label: EmptyView()) {
                                Text("All Investments")
                                    .tag("All Investments")
                                ForEach(categories, id: \.self) { c in
                                    if(c.name != "All Investments" && c.instrument == instrument){
                                        Text(c.name ?? "")
                                            .tag(c.name ?? "")
                                    }
                                }
                                Text("Other")
                                    .tag("Other")
                            }
                            
                        }
                            .frame(width: proxy.size.width-22, alignment: .leading)
                            .foregroundColor(Color(color_secondary))
                            .font(Font.custom("SF Compact", size: 16))
                            .padding(EdgeInsets(top: 11, leading: 11, bottom: 11, trailing: 11))
                            .background(Color(color_secondary).opacity(0.15))
                            .cornerRadius(10)
                        
                    }
                    .frame(height: 44)
                }
                if category=="Other"{
                    VStack(alignment: .leading, spacing: 10){
                        Text("New Category").font(Font.custom("SF Compact", size: 12)).foregroundColor(Color(color_secondary))
                        TextField("", text: $newCategory)
                        
                            .placeholder(when: newCategory.isEmpty) {
                                Text("Add new category").foregroundColor(.gray)
                            }
                            .foregroundColor(Color(color_secondary))
                            .padding(EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16))
                            .background(Color(color_secondary).opacity(0.15))
                            .cornerRadius(10)
                    }
                }
                VStack(alignment: .leading, spacing: 10){
                    Text("Note (optional)").font(Font.custom("SF Compact", size: 12)).foregroundColor(Color(disabled_color))
                    TextField("", text: $note)
                    
                        .placeholder(when: note.isEmpty) {
                            Text("Add notes for this log").foregroundColor(.gray)
                        }
                        .foregroundColor(Color(additional_color))
                        .frame(height: 123, alignment: .top)
                        .padding(EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16))
                        .background(Color(color_secondary).opacity(0.15))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    let log = Log(context: managedObjectContext)
                    log.id = UUID()
                    log.capital = Double(capital) ?? 0.0
                    log.note = note
                    log.date = Date.now
                    log.category = category
                    
                    var c:Category
                    var found = false
                    
                    for eachCategory in categories {
                        if (
                        (eachCategory.name == category
                         || eachCategory.name == newCategory) &&
                        eachCategory.instrument == instrument
                        ){
                            c = eachCategory
                            c.toLog?.addingObjects(from: [log])
                            c.currentCapital = Double(capital) ?? 0.0
                            log.toCategory = c
                            found = true
                            break
                        }
                    }
                    if(!found){
                        c = Category(context: managedObjectContext)
                        c.category_id = UUID()
                        if(category=="Other"){ c.name = newCategory }
                        else { c.name = category }
                        c.instrument = instrument
                        c.toLog = [log]
                        c.currentCapital = Double(capital) ?? 0.0
                        log.toCategory = c
                    }
                    LogController.shared.save()
                    openForm = false
                    
                }, label: {
                    Image(systemName: "plus.app")
                    Text("Save Log")
                })
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                .background(Color(color_secondary).opacity(0.05))
                .foregroundColor(Color(color_thrid))
                .cornerRadius(10)
                .font(Font.custom("CF Compact", size: 16))
            }
            .padding(30)
            .sheet(isPresented: $showScanner, content: {
                makeScannerView()
            })
                
        }
        
    }
    private func makeScannerView() -> ScannerView {
        ScannerView(completion: {
            textPerPage in
            if let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines){
                let perText = outputText.components(separatedBy: "\n")
                var totalCap:Double = 0
                for text in perText {
                    if(text.contains("~") && instrument == "PancakeSwap"){
                        var parsed = text.replacingOccurrences(of: "~", with: "")
                        parsed = parsed.replacingOccurrences(of: " USD", with: "")
                        print(parsed)
                        if let cap = Double(parsed){
                            totalCap+=cap
                        }
                    }
                    if((text.contains("Earn ") || text.contains("-"))
                       && instrument == "PancakeSwap"){
                        var found = false
                        for i in 0..<self.categories.count {
                            let c = categories[i]
                            if(c.name == text && c.instrument == "PancakeSwap"){
                                self.category = text
                                found = true
                            }
                        }
                        if(!found){
                            self.category = "Other"
                            let parsed = text.replacingOccurrences(of: "LP STAKED", with: "")
                            self.newCategory = parsed
                        }
                        
                    }
                }
                self.capital = String(format: "%.2f", totalCap)
                print(self.capital)
            }
            self.showScanner = false
        })
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    @State static var openForm:Bool = true
    static var previews: some View {
        FormSheetView(openForm: $openForm, instrument: "PancakeSwap")
    }
}
