//
//  GalleryView.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 17/12/25.
//

import SwiftUI
import PencilKit

struct GalleryView: View {
    @ObservedObject var drawingManager: DrawingManager
    @Binding var isPresented: Bool
    let onLoadDrawing: (PKDrawing) -> Void
    
    @State private var selectedDrawing: SavedDrawing?
    @State private var showDeleteAlert = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 20), count: count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if drawingManager.drawings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.image")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No saved drawings")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Your saved drawings will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(drawingManager.drawings) { drawing in
                            DrawingCard(drawing: drawing)
                                .onTapGesture {
                                    loadDrawing(drawing)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        selectedDrawing = drawing
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Drawings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
            .alert("Delete Drawing", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let drawing = selectedDrawing {
                        drawingManager.deleteDrawing(drawing)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this drawing? This action cannot be undone.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func loadDrawing(_ savedDrawing: SavedDrawing) {
        if let drawing = drawingManager.loadDrawing(savedDrawing: savedDrawing) {
            onLoadDrawing(drawing)
            isPresented = false
        }
    }
}

struct DrawingCard: View {
    let drawing: SavedDrawing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let thumbnail = drawing.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "doc.text.image")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(drawing.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(drawing.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
