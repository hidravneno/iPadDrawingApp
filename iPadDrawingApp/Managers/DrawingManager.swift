//
//  DrawingManager.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 17/12/25.
//

import SwiftUI
import PencilKit
import Combine

class DrawingManager: ObservableObject {
    @Published var drawings: [SavedDrawing] = []
    
    private let documents/Users/franciscoeduardoaramburoreyes/iPadDrawingApp/iPadDrawingApp/Managers/TrackpadGestureHandler.swiftDirectory: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()
    
    init() {
        loadDrawings()
    }
    
    func saveDrawing(_ drawing: PKDrawing, name: String) {
        let id = UUID()
        let fileName = "\(id.uuidString).drawing"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            let data = drawing.dataRepresentation()
            try data.write(to: fileURL)
            
            let savedDrawing = SavedDrawing(
                id: id,
                name: name,
                fileName: fileName,
                date: Date(),
                thumbnail: generateThumbnail(from: drawing)
            )
            
            drawings.append(savedDrawing)
            saveMetadata()
        } catch {
            print("Error saving drawing: \(error)")
        }
    }
    
    func loadDrawing(savedDrawing: SavedDrawing) -> PKDrawing? {
        let fileURL = documentsDirectory.appendingPathComponent(savedDrawing.fileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try PKDrawing(data: data)
        } catch {
            print("Error loading drawing: \(error)")
            return nil
        }
    }
    
    func deleteDrawing(_ savedDrawing: SavedDrawing) {
        let fileURL = documentsDirectory.appendingPathComponent(savedDrawing.fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            drawings.removeAll { $0.id == savedDrawing.id }
            saveMetadata()
        } catch {
            print("Error deleting drawing: \(error)")
        }
    }
    
    func exportDrawing(_ drawing: PKDrawing) -> UIImage {
        return drawing.image(from: drawing.bounds, scale: 2.0)
    }
    
    private func generateThumbnail(from drawing: PKDrawing) -> UIImage {
        let bounds = drawing.bounds
        if bounds.isEmpty {
            return UIImage(systemName: "doc.text.image") ?? UIImage()
        }
        return drawing.image(from: bounds, scale: 0.2)
    }
    
    private func saveMetadata() {
        let metadataURL = documentsDirectory.appendingPathComponent("drawings_metadata.json")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(drawings)
            try data.write(to: metadataURL)
        } catch {
            print("Error saving metadata: \(error)")
        }
    }
    
    private func loadDrawings() {
        let metadataURL = documentsDirectory.appendingPathComponent("drawings_metadata.json")
        
        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: metadataURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            drawings = try decoder.decode([SavedDrawing].self, from: data)
        } catch {
            print("Error loading metadata: \(error)")
        }
    }
}

struct SavedDrawing: Identifiable, Codable {
    let id: UUID
    var name: String
    let fileName: String
    let date: Date
    var thumbnail: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id, name, fileName, date
    }
}
