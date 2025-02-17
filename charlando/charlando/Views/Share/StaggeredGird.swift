//
//  StaggeredGird.swift
//  2lab
//
//  Created by Phạm Việt Tú on 04/06/2024.
//

import Foundation
import SwiftUI

struct StaggeredGird<Content: View, T: Identifiable>: View where T: Hashable {
    var list: [T]
    var columns: Int
    var content: (T) -> Content
    

    init(list: [T], columns: Int, @ViewBuilder content: @escaping (T) -> Content) {
        self.list = list
        self.columns = columns
        self.content = content
    }
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(setUpList(), id: \.self) { columnsData in
                LazyVStack {
                    ForEach(columnsData) { object in
                        content(object)
                    }
                }
            }
        }
    }
    
    func setUpList() -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        var currentIndex = 0
        
        for object in list {
            gridArray[currentIndex].append(object)
            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }
        
        return gridArray
    }
}
