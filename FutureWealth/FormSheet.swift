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

struct FormSheet: View {
    @Binding var openForm:Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let instrument:String
    
    @State var categories:[String] = ["All Investments", "Other"]
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
                Image("pancakeswap")
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
                                ForEach(categories, id: \.self) { c in
                                    Text(c)
                                        .tag(c)
                                }
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
                    let c = Category(context: managedObjectContext)
                    c.category_id = UUID()
                    if(category=="Other"){ c.name = category }
                    else { c.name = newCategory }
                    c.currentCapital = Double(capital) ?? 0.0
                    c.instrument = instrument
                    log.toCategory = c
                    c.toLog = [log]
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
                
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    @State static var openForm:Bool = true
    static var previews: some View {
        FormSheet(openForm: $openForm, instrument: "PancakeSwap")
    }
}
