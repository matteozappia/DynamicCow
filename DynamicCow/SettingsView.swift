//
//  SettingsView.swift
//  DynamicCow
//
//  Created by ethernal on 11/01/23.
//

import SwiftUI
import Foundation

struct SettingsView: View {
    
    @State var showPFAlert: Bool = false
    @State var showASAlert: Bool = false
    
    @State var version: String = ""
    
    var body: some View {
        NavigationStack{
                List{
                    
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(version)
                                .foregroundColor(.secondary)
                        }
                        
                        
                    } header: {
                        Text("General")
                    } footer: {
                        //
                    }
                    
                    Section {
                        Button {
                            withAnimation{
                                showPFAlert = true
                            }
                        } label: {
                            Text("Restore plist file")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .alert("Are you sure?", isPresented: $showPFAlert) {
                            Button("Yes", role: .destructive) {
                                
                                // restore plist
                                killMobileGestalt()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                    respring()
                                }
                                
                                
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("You are going to reset the plist file to its initial state.")
                        }
                        
                        Button {
                            withAnimation{
                                showASAlert = true
                            }
                        } label: {
                            Text("Reset app state")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .alert("Are you sure?", isPresented: $showASAlert) {
                            Button("Yes", role: .destructive) { UserDefaults.standard.resetAppState() }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("You are going to reset app current state.")
                        }


                    } header: {
                        Text("Troubleshoot")
                    } footer: {
                        Text("Normally the app should not corrupt the plist file, but in rare cases it can happen, especially if you have made changes manually through Santander, this can lead to an app crash when you try to enable or disable the dynamic island. To restore it to its initial state, click Restore plist file.\n\nIf the app thinks you have dynamic island turned on but it is disabled click on Reset app state.")
                    }

                    
                    Section{
                        HStack {
                            Button {
                                withAnimation {
                                    respring()
                                }
                                
                            } label: {
                                Text("Respring")
                                    .font(.headline)
                                    .foregroundColor(.cyan)
                            }
                            
                            Spacer()
                        }
                    }
            }
            .onAppear{
                version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
            }
            .navigationTitle("Settings")
        }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
