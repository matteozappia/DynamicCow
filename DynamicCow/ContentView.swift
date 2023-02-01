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
    
    @State private var deviceSize: Int = 0
    
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
                deviceSize = getDefaultSubtype()
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
    
    
    // very messy but will not bootloop the device hopefully
    func getDefaultSubtype() -> Int {
        var deviceSubType: Int = UserDefaults.standard.integer(forKey: "OriginalDeviceSubType")
        if deviceSubType == 0 {
            var canUseStandardMethod: [String] = ["10,3", "10,4", "10,6", "11,2", "11,4", "11,6", "11,8", "12,1", "12,3", "12,5", "13,1", "13,2", "13,3", "13,4", "14,4", "14,5", "14,2", "14,3", "14,7", "14,8", "15,2"]
            for (i, v) in canUseStandardMethod.enumerated() {
                canUseStandardMethod[i] = "iPhone" + v
            }
            
            let deviceModel: String = UIDevice().machineName
            
            if canUseStandardMethod.contains(deviceModel) {
                // can use device bounds
                deviceSubType = Int(UIScreen.main.nativeBounds.height)
            } else {//else if specialCases[deviceModel] != nil {
                //deviceSubType = specialCases[deviceModel]!
                let url: URL? = URL(string: "https://raw.githubusercontent.com/matteozappia/DynamicCow/main/DefaultSubTypes.json")
                if url != nil {
                    // get the data of the file
                    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                        guard let data = data else {
                            print("No data to decode")
                            return
                        }
                        guard let subtypeData = try? JSONSerialization.jsonObject(with: data, options: []) else {
                            print("Couldn't decode json data")
                            return
                        }
                        
                        // check if all the files exist
                        if  let subtypeData = subtypeData as? Dictionary<String, AnyObject>, let deviceTypes = subtypeData["Default_SubTypes"] as? [String: Int] {
                            if deviceTypes[deviceModel] != nil {
                                // successfully found subtype
                                deviceSubType = deviceTypes[deviceModel] ?? -1
                            }
                        }
                    }
                    task.resume()
                }
            }
            
            // set the subtype
            if deviceSubType == 0 {
                // get the current subtype
                do {
                    let url = URL(fileURLWithPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
                    let data = try Data(contentsOf: url)
                    
                    var plist = try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String:Any]
                    let origDeviceTypeURL = URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ArtworkDeviceSubTypeBackup")
                    
                    if !FileManager.default.fileExists(atPath: origDeviceTypeURL.path) {
                        let currentType = ((plist["CacheExtra"] as? [String: Any] ?? [:])["oPeik/9e8lQWMszEjbPzng"] as? [String: Any] ?? [:])["ArtworkDeviceSubType"] as! Int
                        deviceSubType = currentType
                        let backupData = String(currentType).data(using: .utf8)!
                        try backupData.write(to: origDeviceTypeURL)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            if deviceSubType == 0 {
                // do something
                // for now just crash the app
                exit(0)
            }
            UserDefaults.standard.set(deviceSubType, forKey: "OriginalDeviceSubType")
        }
        return deviceSubType
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
