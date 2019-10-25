//
//  LogView.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import SwiftUI
import Combine

struct LogView: View {
    @ObservedObject private var auditViewModel: AuditViewModel
    
    init(_ viewModel: AuditViewModel) {
        self.auditViewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            HStack {
                Text("Audit Log")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Text("Active")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.green)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            ScrollView {
                Text(auditViewModel.auditLog)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)
            }
        }
        .padding()
    }
}

#if DEBUG
struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView(AuditViewModel())
    }
}
#endif
