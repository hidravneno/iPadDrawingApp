//
//  DrawingView.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 15/12/25.
//

import SwiftUI
import PencilKit

struct DrawingView: View {
    @StateObject private var drawingManager = DrawingManager()
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedTool: DrawingTool = .pen
    @State private var selectedColor: Color = .black
    @State private var strokeWidth: CGFloat = 5.0
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasRotation: Angle = .zero
    @State private var canvasOffset: CGSize = .zero
    
    @State private var showSaveDialog = false
    @State private var showGallery = false
    @State private var showShareSheet = false
    @State private var showToolbar = true
    @State private var shareImage: UIImage?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isCompact: Bool {
        horizontalSizeClass == .compact || verticalSizeClass == .compact
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    if showToolbar {
                        if isCompact {
                            CompactToolbarView(
                                selectedTool: $selectedTool,
                                selectedColor: $selectedColor,
                                strokeWidth: $strokeWidth,
                                onToolChange: updateTool
                            )
                        } else {
                            ToolbarView(
                                selectedTool: $selectedTool,
                                selectedColor: $selectedColor,
                                strokeWidth: $strokeWidth,
                                onToolChange: updateTool
                            )
                        }
                    }
                    
                    ZStack {
                        CanvasView(canvasView: $canvasView, toolPicker: $toolPicker)
                        
                        TrackpadGestureView(
                            onPan: handleTrackpadPan,
                            onZoom: handleTrackpadZoom
                        )
                        .allowsHitTesting(true)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showToolbar.toggle() }) {
                            Image(systemName: showToolbar ? "chevron.up" : "chevron.down")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Drawing Pad", displayMode: .inline)
            .navigationBarItems(
                leading: leadingBarItems,
                trailing: trailingBarItems
            )
            .onAppear(perform: setupToolPicker)
            .sheet(isPresented: $showSaveDialog) {
                SaveDrawingDialog(isPresented: $showSaveDialog) { name in
                    saveCurrentDrawing(name: name)
                }
            }
            .sheet(isPresented: $showGallery) {
                GalleryView(
                    drawingManager: drawingManager,
                    isPresented: $showGallery
                ) { drawing in
                    loadDrawing(drawing)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    ShareSheet(items: [image])
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var leadingBarItems: some View {
        HStack(spacing: 15) {
            Button(action: clearCanvas) {
                Label("Clear", systemImage: "trash")
            }
            .keyboardShortcut("k", modifiers: .command)
            
            Button(action: resetTransform) {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .keyboardShortcut("r", modifiers: .command)
            
            Button(action: { showGallery = true }) {
                Label("Gallery", systemImage: "square.grid.2x2")
            }
            .keyboardShortcut("g", modifiers: .command)
        }
    }
    
    private var trailingBarItems: some View {
        HStack(spacing: 15) {
            Button(action: undo) {
                Label("Undo", systemImage: "arrow.uturn.backward")
            }
            .keyboardShortcut("z", modifiers: .command)
            .disabled(!(canvasView.undoManager?.canUndo ?? false))
            
            Button(action: redo) {
                Label("Redo", systemImage: "arrow.uturn.forward")
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
            .disabled(!(canvasView.undoManager?.canRedo ?? false))
            
            Menu {
                Button(action: { showSaveDialog = true }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                
                Button(action: exportDrawing) {
                    Label("Export as Image", systemImage: "square.and.arrow.up")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        updateTool()
    }
    
    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }

    private func undo() {
        canvasView.undoManager?.undo()
    }

    private func redo() {
        canvasView.undoManager?.redo()
    }
    
    private func resetTransform() {
        withAnimation {
            canvasView.transform = .identity
            canvasScale = 1.0
            canvasRotation = .zero
            canvasOffset = .zero
        }
    }
    
    private func saveCurrentDrawing(name: String) {
        drawingManager.saveDrawing(canvasView.drawing, name: name)
    }
    
    private func loadDrawing(_ drawing: PKDrawing) {
        canvasView.drawing = drawing
    }
    
    private func exportDrawing() {
        shareImage = drawingManager.exportDrawing(canvasView.drawing)
        showShareSheet = true
    }
    
    private func updateTool() {
        let uiColor = UIColor(selectedColor)
        
        switch selectedTool {
        case .pen:
            canvasView.tool = PKInkingTool(.pen, color: uiColor, width: strokeWidth)
        case .pencil:
            canvasView.tool = PKInkingTool(.pencil, color: uiColor, width: strokeWidth)
        case .marker:
            canvasView.tool = PKInkingTool(.marker, color: uiColor, width: strokeWidth)
        case .eraser:
            canvasView.tool = PKEraserTool(.bitmap)
        }
    }
    
    private func handleTrackpadPan(_ translation: CGPoint) {
        let newOffset = CGSize(
            width: canvasOffset.width + translation.x,
            height: canvasOffset.height + translation.y
        )
        canvasOffset = newOffset
        
        canvasView.transform = CGAffineTransform(scaleX: canvasScale, y: canvasScale)
            .rotated(by: CGFloat(canvasRotation.radians))
            .translatedBy(x: newOffset.width, y: newOffset.height)
    }
    
    private func handleTrackpadZoom(_ scale: CGFloat) {
        let currentScale = canvasView.transform.a
        let newScale = currentScale * scale
        let clampedScale = min(max(newScale, 0.5), 3.0)
        
        canvasView.transform = CGAffineTransform(scaleX: clampedScale, y: clampedScale)
            .rotated(by: CGFloat(canvasRotation.radians))
            .translatedBy(x: canvasOffset.width, y: canvasOffset.height)
        
        canvasScale = clampedScale
    }
}

struct CompactToolbarView: View {
    @Binding var selectedTool: DrawingTool
    @Binding var selectedColor: Color
    @Binding var strokeWidth: CGFloat
    let onToolChange: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach([DrawingTool.pen, DrawingTool.marker, DrawingTool.eraser], id: \.self) { tool in
                Button(action: {
                    selectedTool = tool
                    onToolChange()
                }) {
                    Image(systemName: tool.icon)
                        .frame(width: 40, height: 40)
                        .background(selectedTool == tool ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                }
            }
            
            Divider()
            
            Menu {
                ForEach([Color.black, .red, .blue, .green], id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                        onToolChange()
                    }) {
                        HStack {
                            Circle().fill(color).frame(width: 20, height: 20)
                            Text(colorName(color))
                        }
                    }
                }
            } label: {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
    }
    
    private func colorName(_ color: Color) -> String {
        switch color {
        case .black: return "Black"
        case .red: return "Red"
        case .blue: return "Blue"
        case .green: return "Green"
        default: return "Color"
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview(traits: .landscapeLeft) {
    DrawingView()
}
