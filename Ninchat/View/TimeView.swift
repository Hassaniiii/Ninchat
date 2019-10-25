//
//  TimeView.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import SwiftUI

struct TimeView: View {
    @ObservedObject private var accessViewModel: AccessViewModel
    
    init(_ viewModel: AccessViewModel) {
        self.accessViewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                HStack {
                    Text("Server status:")
                        .foregroundColor(Color.gray)
                        .lineLimit(nil)
                    Text("Updating...")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                Spacer()
            }
            HStack {
                HStack {
                    Text("Server time:")
                        .foregroundColor(Color.gray)
                        .lineLimit(nil)
                    Text(accessViewModel.clock)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
}

#if DEBUG
struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView(AccessViewModel(auditViewModel: AuditViewModel()))
    }
}
#endif
