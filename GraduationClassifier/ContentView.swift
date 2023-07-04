//
//  ContentView.swift
//  GraduationClassifier
//
//  Created by rifqi triginandri on 01/07/23.
//

import SwiftUI
import CoreML
 
struct ContentView: View {
    
    @State private var isButtonVisible = true
    
    
    @State private var selectedYear: String = ""
    @State private var isYearPickerShown = false
    let years = Array(1900...2023).map { String($0) }
    
    @State private var selectedProdi: String = ""
    @State private var isProdiPickerShown = false
    let prodi = ["Dirasat Islamiyah", "Magister Dirasat Islamiyah"]
    
    @State private var ipk: Double = 2.0
    
    
    @State private var studentName: String = ""
    @State private var yearStudy: String = ""
    @State private var MonthStudy: String = ""
    
    @State private var classifiedClass: String = "-"
    @State private var probability: String = "-"
    
    @State private var probabilities: [String: Double] = [:]
    
    @State private var showingAlert = false

    func formatProbability(_ value: Double) -> String {
        let formattedValue = String(format: "%.2f", value * 100)
        return "\(formattedValue)%"
    }
    
    func formatProbabilities(_ probabilities: [String: Double]) -> String {
        var result = ""
        for (key, value) in probabilities {
            if !key.isEmpty{
                let formattedValue = String(format: "%.4f", value)
                result += "\(key): \(formattedValue)\n"
            }
        }
        return result
    }

    
    var body: some View {
        NavigationView {
            VStack() {
                
                VStack(){
                    HStack{
                        Text("Klasifikasi Predikat \nKelulusan")
                            .font(.title2)
                            .bold()
                            .padding([.bottom])
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    VStack{
                        Spacer()
                        ZStack{
                            Image("bg-grad")
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 10)
                            
                            VStack{
                                
                                Text(classifiedClass).font(.title3)
                                    .padding(.top)
                                HStack{
                                    Text(probability).font(.headline)
                                }
                                
                                Button(action: {
                                    showingAlert = true
                                }) {
                                    Text("Lihat Probabilitas")
                                        .padding(5)
                                    
                                }
                                .alert( isPresented: $showingAlert) {
                                    Alert(title: Text("Probabilitas"), message: Text(formatProbabilities(probabilities)), dismissButton: .default(Text("OK")))
                                }
                            }
                            
                        }.padding(.top, -30)
                        Spacer()
                    }
                    
                    
                    
                }.padding([.leading,.top,.trailing])
                
                VStack(alignment: .leading){
                    HStack{
                        Spacer()
                        Text("Data Mahasiswa")
                            .font(.headline)
                            .bold()
                            .padding([.top], 10)
                        Spacer()
                    }
                    
                    
                    // Input tahun
                    HStack {
                        
                        Text("Tahun wisuda").font(.headline)
                        TextField("Pilih tahun", text: $selectedYear)
                            .disabled(isYearPickerShown)
                            .onTapGesture {
                                isYearPickerShown = true
                            }
                            .padding(.leading)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    }
                    .padding([.leading, .trailing])
                    .sheet(isPresented: $isYearPickerShown) {
                        Picker("Tahun", selection: $selectedYear) {
                            ForEach(years, id: \.self) { year in
                                Text(year)
                                    .tag(year)
                            }
                        }
                        .presentationDetents([.fraction(0.2)])
                        .pickerStyle(WheelPickerStyle())
                        .onDisappear {
                            isYearPickerShown = false
                        }
                        .onAppear {
                            if selectedYear.isEmpty {
                                let currentYear = Calendar.current.component(.year, from: Date())
                                selectedYear = String(currentYear)
                            }
                        }
                    }
                    
                    // picker prodi
                    HStack {
                        Text("Prodi").font(.headline)
                        TextField("Pilih Program Studi", text: $selectedProdi)
                            .disabled(isProdiPickerShown)
                            .onTapGesture {
                                isProdiPickerShown = true
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                        
                    }
                    .padding([.leading, .trailing])
                    .sheet(isPresented: $isProdiPickerShown) {
                        VStack {
                            Picker("Program Studi", selection: $selectedProdi) {
                                ForEach(prodi, id: \.self) { prodi in
                                    Text(prodi)
                                        .tag(prodi)
                                }
                            }
                            .presentationDetents([.fraction(0.2)])
                            .pickerStyle(WheelPickerStyle())
                            .onDisappear {
                                isProdiPickerShown = false
                            }
                            .onAppear {
                                if selectedProdi.isEmpty {
                                    selectedProdi = "Dirasat Islamiyah"
                                }
                            }
                            
                        }
                    }
                    
                    //input lama study
                    
                    VStack(alignment: .leading){
                        Text("Lama Studi").font(.headline)
                        
                        HStack{
                            TextField("tahun", text: $yearStudy)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Tahun").font(.subheadline)
                            
                            TextField("bulan", text: $MonthStudy)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("Bulan").font(.subheadline)
                            
                        }
                        
                    }.padding([.leading, .trailing])
                        .padding(.top, 5)
                    
                    // slider ipk
                    VStack{
                        HStack {
                            Text("IPK").font(.headline)
                            
                            Slider(value: $ipk, in: 0.00...4.00, step: 0.01)
                                .accentColor(.orange)
                                .padding(.leading)
                            
                            Text(String(format: "%.2f", ipk))
                                .font(.callout)
                        }
                        
                        
                    }.padding([.leading, .trailing])
                        .padding(.top, 5)
                    
                    
                    HStack{
                        
                        Button {
                            let predictedClass = GraduationModel(
                                tahun: Double(yearStudy) ?? 0,
                                prodi: selectedProdi,
                                lama_study: (((Double(yearStudy) ?? 0 )*12) + (Double(MonthStudy) ?? 0))/12,
                                ipk: ipk)!.Yudisium
                            
                            let probability = GraduationModel(
                                tahun: Double(yearStudy) ?? 0,
                                prodi: selectedProdi,
                                lama_study: (((Double(yearStudy) ?? 0 )*12) + (Double(MonthStudy) ?? 0))/12,
                                ipk: ipk)!.YudisiumProbability
                            
                            classifiedClass = predictedClass
                            
                            probabilities = probability.reduce(into: [:]) { (result, keyValue) in
                                let (key, value) = keyValue
                                let stringKey = String(key)
                                result[stringKey] = value
                            }
                            
                            print(probabilities)

                            for (key, value) in probability {
                                let maxEntry = probability.max { $0.value < $1.value }
                                
                                print(" Probability: \(maxEntry?.key)")
                                
                                
                                if let maxKey = maxEntry?.key, let probability = probability[maxKey] {
                                    print(" Probability: \(formatProbability(probability))")
                                    self.probability = formatProbability(probability)
                                }
                                
                            }
                            
                        } label: {
                            Text("Klasifikasi")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color.blue)
                        )
                        
                        Button(action: {
                            yearStudy = ""
                            MonthStudy = ""
                            selectedYear = ""
                            selectedProdi = ""
                            ipk = 2.00
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .padding()
                                .shadow(radius: 5)
                            
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .foregroundColor(Color.red)
                        )
                    }.padding()
                    
                }
                .background(.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .shadow(radius: 10)
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.green)
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.top)
        
    }
    
    
}

func GraduationModel(tahun: Double, prodi: String, lama_study: Double, ipk: Double) -> GraduationClassifierModelOutput? {
    
    do{
        let config = MLModelConfiguration()
        let model = try GraduationClassifierModel(configuration: config)
        
        //        let prediction = try model.prediction(Tahun: 2020, Prodi: "Dirasat Islamiyah", Lama_Study: 5.3, IPK: 0)
        let prediction = try model.prediction(Tahun: tahun, Prodi: prodi, Lama_Study: lama_study, IPK: ipk)
        
        
        return prediction
    } catch{
        
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

