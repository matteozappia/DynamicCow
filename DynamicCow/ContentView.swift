//
//  ContentView.swift
//  DynamicCow
//
//  Created by ethernal on 08/01/23.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("isEnabled") private var isEnabled: Bool = false
    @AppStorage("currentSet") private var currentSet: Int = 0
    
    @State private var isDoing: Bool = false
    
    private let dynamicPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    
    private let deviceSize = Int(UIScreen.main.nativeBounds.height)
    
    @State var checkedPro: Bool = false
    @State var checkedProMax: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
   
                AppearanceCellView(checkedPro: $checkedPro, checkedProMax: $checkedProMax)
                    .disabled(isEnabled)
                    .disabled(isDoing)
                    .opacity(isEnabled ? 0.8 : 1)
                    .opacity(isDoing ? 0.8 : 1)
  
                Spacer()
                
                Button {
                    
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    if isEnabled{
                        //disable
                        plistChange(plistPath: dynamicPath, key: "ArtworkDeviceSubType", value: deviceSize)
                        currentSet = 0
                        isDoing = true
                        isEnabled = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 15){
                            respring()
                        }
                        
                    }else{
                        //enable
                        if checkedProMax {
                            plistChange(plistPath: dynamicPath, key: "ArtworkDeviceSubType", value: 2796)
                            currentSet = 2796
                        }else{
                            plistChange(plistPath: dynamicPath, key: "ArtworkDeviceSubType", value: 2556)
                            currentSet = 2556
                        }
                        isDoing = true
                        isEnabled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 15){
                            respring()
                        }
                        
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 54)
                        .foregroundColor(.white.opacity(0.9))
                        .overlay {
                            if !isDoing{
                                Text(isEnabled ? "Disable" : "Enable")
                                    .foregroundColor(.black)
                                    .bold()
                            }else{
                                ProgressView()
                                    .tint(.black)
                            }
                        }
                }
                .padding()
                .disabled(checkedPro || checkedProMax ? false : true)
                .disabled(isDoing)
                .opacity(checkedPro || checkedProMax ? 1 : 0.8)
                .opacity(isDoing ? 0.8 : 1)

                
            }
            .padding()
            .onAppear{
                if currentSet == 2556{
                    checkedPro = true
                }else if currentSet == 2796{
                    checkedProMax = true
                }
            }
            
            .navigationTitle("DynamicCow")
            .toolbar {
                if !isDoing {
                    Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(isEnabled ? .green : .red)
                        .font(.title2)
                        .animation(.spring(), value: isEnabled)
                }else{
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }
    
    
    func plistChange(plistPath: String, key: String, value: Int) {
        let stringsData = try! Data(contentsOf: URL(fileURLWithPath: plistPath))
        
        let plist = try! PropertyListSerialization.propertyList(from: stringsData, options: [], format: nil) as! [String: Any]
        func changeValue(_ dict: [String: Any], _ key: String, _ value: Int) -> [String: Any] {
            var newDict = dict
            for (k, v) in dict {
                if k == key {
                    newDict[k] = value
                } else if let subDict = v as? [String: Any] {
                    newDict[k] = changeValue(subDict, key, value)
                }
            }
            return newDict
        }
   
        var newPlist = plist
        newPlist = changeValue(newPlist, key, value)
    
        let newData = try! PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)

        overwriteFile(newData, plistPath)
    }
    
    
    func respring(){
        guard let window = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first else { return }
        while true {
           window.snapshotView(afterScreenUpdates: false)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
