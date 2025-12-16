//
//  CanvasView.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 15/12/25.
//

import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = .white
        canvasView.isMultipleTouchEnabled = true
        
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Lógica cuando el dibujo cambia
        }
    }
}
