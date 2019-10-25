//
//  ContentView.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/24/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    private var auditViewModel: AuditViewModel!
    private var accessViewModel: AccessViewModel!
    
    init() {
        self.auditViewModel = AuditViewModel()
        self.accessViewModel = AccessViewModel(auditViewModel: self.auditViewModel)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            TimeView(accessViewModel)
                .frame(height: 80)
            LogView(auditViewModel)
        }
        .padding(.top, 8.0)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
