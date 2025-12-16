//
//  DrawingTool.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 15/12/25.
//

import Foundation

enum DrawingTool: String, CaseIterable {
    case pen = "Pen"
    case pencil = "Pencil"
    case marker = "Marker"
    case eraser = "Eraser"
    
    var icon: String {
        switch self {
        case .pen: return "pencil"
        case .pencil: return "pencil.tip"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
}

