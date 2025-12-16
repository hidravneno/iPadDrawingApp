//
//  DrawingView.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 15/12/25.
//

import SwiftUI
import PencilKit

struct DrawingView: View {
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedTool: DrawingTool = .pen
    @State private var selectedColor: Color = .black
    @State private var strokeWidth: CGFloat = 5.0
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasRotation: Angle = .zero

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Toolbar con herramientas de dibujo
                ToolbarView(
                    selectedTool: $selectedTool,
                    selectedColor: $selectedColor,
                    strokeWidth: $strokeWidth,
                    onToolChange: updateTool
                )
                
                // Canvas principal
                CanvasView(canvasView: $canvasView, toolPicker: $toolPicker)
                    .navigationBarTitle("Drawing Pad", displayMode: .inline)
                    .navigationBarItems(
                        leading: HStack {
                            Button(action: clearCanvas) {
                                Label("Clear", systemImage: "trash")
                            }
                            .keyboardShortcut("k", modifiers: .command)
                            
                            Button(action: resetTransform) {
                                Label("Reset View", systemImage: "arrow.counterclockwise")
                            }
                            .keyboardShortcut("r", modifiers: .command)
                        },
                        trailing: HStack(spacing: 20) {
                            Button(action: undo) {
                                Label("Undo", systemImage: "arrow.uturn.backward")
                            }
                            .keyboardShortcut("z", modifiers: .command)
                            
                            Button(action: redo) {
                                Label("Redo", systemImage: "arrow.uturn.forward")
                            }
                            .keyboardShortcut("z", modifiers: [.command, .shift])
                        }
                    )
                    .onAppear(perform: setupToolPicker)
                    // Gesto de zoom (pinch)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                handleZoom(value)
                            }
                    )
                    // Gesto de rotación
                    .gesture(
                        RotationGesture()
                            .onChanged { angle in
                                handleRotation(angle)
                            }
                    )
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Setup Methods
    
    private func setupToolPicker() {
        // Configurar el tool picker de PencilKit
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        // Configurar herramienta inicial
        updateTool()
    }
    
    // MARK: - Canvas Actions
    
    private func clearCanvas() {
        // Limpiar el canvas
        canvasView.drawing = PKDrawing()
    }

    private func undo() {
        // Deshacer última acción
        canvasView.undoManager?.undo()
    }

    private func redo() {
        // Rehacer acción
        canvasView.undoManager?.redo()
    }
    
    private func resetTransform() {
        // Resetear zoom y rotación
        withAnimation {
            canvasView.transform = .identity
            canvasScale = 1.0
            canvasRotation = .zero
        }
    }
    
    // MARK: - Tool Management
    
    private func updateTool() {
        let uiColor = UIColor(selectedColor)
        
        switch selectedTool {
        case .pen:
            let tool = PKInkingTool(.pen, color: uiColor, width: strokeWidth)
            canvasView.tool = tool
        case .pencil:
            let tool = PKInkingTool(.pencil, color: uiColor, width: strokeWidth)
            canvasView.tool = tool
        case .marker:
            let tool = PKInkingTool(.marker, color: uiColor, width: strokeWidth)
            canvasView.tool = tool
        case .eraser:
            // El borrador usa PKEraserTool
            canvasView.tool = PKEraserTool(.bitmap)
        }
    }
    
    // MARK: - Gesture Handlers
    
    private func handleZoom(_ scale: CGFloat) {
        let currentScale = canvasView.transform.a
        let newScale = currentScale * scale
        
        // Limitar el zoom entre 0.5x y 3x
        let clampedScale = min(max(newScale, 0.5), 3.0)
        canvasView.transform = CGAffineTransform(scaleX: clampedScale, y: clampedScale)
            .rotated(by: CGFloat(canvasRotation.radians))
        canvasScale = clampedScale
    }
    
    private func handleRotation(_ angle: Angle) {
        canvasRotation = angle
        canvasView.transform = CGAffineTransform(scaleX: canvasScale, y: canvasScale)
            .rotated(by: CGFloat(angle.radians))
    }
}

/// MARK: - Preview
#Preview(traits: .landscapeLeft) {
    DrawingView()
}
