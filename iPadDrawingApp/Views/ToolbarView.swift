//
//  ToolbarView.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 15/12/25.
//

import SwiftUI

struct ToolbarView: View {
    @Binding var selectedTool: DrawingTool
    @Binding var selectedColor: Color
    @Binding var strokeWidth: CGFloat
    let onToolChange: () -> Void
    
    let colors: [Color] = [.black, .red, .blue, .green, .yellow, .orange, .purple, .pink]
    
    var body: some View {
        HStack(spacing: 15) {
            // Selector de herramientas
            ForEach(DrawingTool.allCases, id: \.self) { tool in
                Button(action: {
                    selectedTool = tool
                    onToolChange()
                }) {
                    VStack {
                        Image(systemName: tool.icon)
                            .font(.system(size: 20))
                        Text(tool.rawValue)
                            .font(.caption2)
                    }
                    .frame(width: 60, height: 50)
                    .background(selectedTool == tool ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .keyboardShortcut(KeyEquivalent(tool.rawValue.first!.lowercased().first!))
            }
            
            Divider()
                .frame(height: 40)
            
            // Selector de colores
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                            onToolChange()
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.blue : Color.clear, lineWidth: 3)
                                )
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            .frame(maxWidth: 300)
            
            Divider()
                .frame(height: 40)
            
            // Control de grosor
            VStack {
                Text("Width")
                    .font(.caption2)
                Slider(value: $strokeWidth, in: 1...20, step: 1)
                    .frame(width: 100)
                    .onChange(of: strokeWidth) {
                        onToolChange()
                    }
                Text("\(Int(strokeWidth))pt")
                    .font(.caption2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
