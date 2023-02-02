//
//  ContentView.swift
//  DynamicCow
//
//  Created by ethernal on 08/01/23.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage(DynamicKeys.isEnabled.rawValue) private var isEnabled: Bool = false
    @AppStorage(DynamicKeys.currentSet.rawValue) private var currentSet: Int = 0
    @AppStorage(DynamicKeys.originalDeviceSubType.rawValue) private var originalDeviceSubType: Int = 0
    
    
    @State private var isDoing: Bool = false
    
    private let dynamicPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    
    @State private var deviceSize: Int = 0
    
    @State var checkedPro: Bool = false
    @State var checkedProMax: Bool = false
    
    @State var tappedOnSettings: Bool = false
    
    @State var shouldAlertDeviceSubTypeError: Bool = false
    @State var shouldAlertPlistCorrupted: Bool = false
    
    @State var shouldRedBarFix: Bool = false
    
    var body: some View {
        NavigationStack{
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
                        plistChange(plistPath: dynamicPath, key: "ArtworkDeviceSubType", value: originalDeviceSubType)
                        currentSet = 0
                        if shouldRedBarFix{
                            setResolution()
                        }
                        withAnimation{
                            isDoing = true
                            isEnabled = false
                        }
                        
                    }else{
                        //enable
                        if checkedProMax {
                            plistChange(plistPath: dynamicPath, key: "ArtworkDeviceSubType", value: 2796)
                            currentSet = 2796
                            if shouldRedBarFix{
                                setResolution()
                            }
                        }else{
                            plistChange(plistPath: dynamicPath, key: "ArtworkDeviceSubType", value: 2556)
                            currentSet = 2556
                            if shouldRedBarFix{
                                setResolution()
                            }
                        }
                        withAnimation{
                            isDoing = true
                            isEnabled = true
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
                    withAnimation{
                        checkedPro = true
                    }
                }else if currentSet == 2796{
                    withAnimation{
                        checkedProMax = true
                    }
                }
            }
            
            .navigationTitle("DynamicCow")
            .toolbar {
            
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                }
                .disabled(isDoing)
                .opacity(isDoing ? 0.8 : 1)
            
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
        }.tint(.white)
            .onAppear{
                grant_full_disk_access() { error in
                            print(error?.localizedDescription as Any)
                        }
                deviceSize = getDefaultSubtype()
                
                switch UIDevice().machineName {
                case "iPhone11,8":
                    shouldRedBarFix = true
                    break
                case "iPhone12,1":
                    shouldRedBarFix = true
                    break
                default:
                    break
                }
                
            }
            .alert(isPresented: $shouldAlertDeviceSubTypeError) {
                Alert(title: Text("Error"), message: Text("There was an error getting the deviceSubType, maybe your plist file is corrupted, please tap on Reset and reopen the app again.\nNote: Your device will respring."), dismissButton: .destructive(Text("Reset"),action: {
                    // restore plist
                    killMobileGestalt()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                        respring()
                    }
                }))
            }
            .alert(isPresented: $shouldAlertPlistCorrupted) {
                Alert(title: Text("Error"), message: Text("There was an error modyfing your plist file is corrupted, please tap on Reset and reopen the app again.\nNote: Your device will respring."), dismissButton: .destructive(Text("Reset"),action: {
                    // restore plist
                    killMobileGestalt()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                        respring()
                    }
                }))
            }
    }
    
    func setResolution() {
            do {
                let tmpPlistURL = URL(fileURLWithPath: "/var/tmp/com.apple.iokit.IOMobileGraphicsFamily.plist")
                try? FileManager.default.removeItem(at: tmpPlistURL)
                
                try createPlist(at: tmpPlistURL)
                
                let aliasURL = URL(fileURLWithPath: "/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist")
                try? FileManager.default.removeItem(at: aliasURL)
                try FileManager.default.createSymbolicLink(at: aliasURL, withDestinationURL: tmpPlistURL)
                
                respring()
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
    
    func createPlist(at url: URL) throws {
        if isEnabled{
                let 💀 : [String: Any] = [
                    "canvas_height": 1792,
                    "canvas_width": 828,
                ]
                let data = NSDictionary(dictionary: 💀)
                data.write(toFile: url.path, atomically: true)
        }else{
            let 💀 : [String: Any] = [
                "canvas_height": 1971,
                "canvas_width": 911,
            ]
            let data = NSDictionary(dictionary: 💀)
            data.write(toFile: url.path, atomically: true)
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
        
        if overwriteFile(originPath: plistPath, replacementData: newData) {
            // all actions completed
            DispatchQueue.main.asyncAfter(deadline: .now()){
                respring()
            }
        } else {
            // something went wrong
            shouldAlertPlistCorrupted = true
        }
    }
    
    // very messy but will not bootloop the device hopefully
    func getDefaultSubtype() -> Int {
        var deviceSubType: Int = originalDeviceSubType
        
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
                withAnimation{
                    shouldAlertDeviceSubTypeError = true
                }
            }
            originalDeviceSubType = deviceSubType
        }
        return deviceSubType
    }
    
    
    
    // Overwrite the system font with the given font using CVE-2022-46689.
    // The font must be specially prepared so that it skips past the last byte in every 16KB page.
    // See BrotliPadding.swift for an implementation that adds this padding to WOFF2 fonts.
    // credit: FontOverwrite
    func overwriteFile(originPath: String, replacementData: Data) -> Bool {
    #if false
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].path
        
        let pathToRealTarget = originPath
        let originPath = documentDirectory + originPath
        let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTarget))
        try! origData.write(to: URL(fileURLWithPath: originPath))
    #endif
        
        // open and map original font
        let fd = open(originPath, O_RDONLY | O_CLOEXEC)
        if fd == -1 {
            print("Could not open target file")
            return false
        }
        defer { close(fd) }
        // check size of font
        let originalFileSize = lseek(fd, 0, SEEK_END)
        guard originalFileSize >= replacementData.count else {
            print("Original file: \(originalFileSize)")
            print("Replacement file: \(replacementData.count)")
            print("File too big")
            return false
        }
        lseek(fd, 0, SEEK_SET)
        
        // Map the font we want to overwrite so we can mlock it
        let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, fd, 0)
        if fileMap == MAP_FAILED {
            print("Failed to map")
            return false
        }
        // mlock so the file gets cached in memory
        guard mlock(fileMap, replacementData.count) == 0 else {
            print("Failed to mlock")
            return true
        }
        
        // for every 16k chunk, rewrite
        print(Date())
        for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
            print(String(format: "%lx", chunkOff))
            let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x4000)]
            var overwroteOne = false
            for _ in 0..<2 {
                let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                    return unaligned_copy_switch_race(
                        fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count)
                }
                if overwriteSucceeded {
                    overwroteOne = true
                    break
                }
                print("try again?!")
            }
            guard overwroteOne else {
                print("Failed to overwrite")
                return false
            }
        }
        print(Date())
        return true
    }
    
    func respring(){
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = .black
            view.alpha = 0

            UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first!.windows.first!.addSubview(view)
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                view.alpha = 1
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                respringBackboard()
            })
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
