//
//  SaveDrawingDialog.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 17/12/25.
//
import SwiftUI

struct SaveDrawingDialog: View {
    @Binding var isPresented: Bool
    @State private var drawingName: String = ""
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Drawing Name")) {
                    TextField("Enter name", text: $drawingName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Button(action: save) {
                        HStack {
                            Spacer()
                            Text("Save Drawing")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(drawingName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Save Drawing")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
            )
        }
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            drawingName = "Drawing \(formatter.string(from: Date()))"
        }
    }
    
    private func save() {
        let name = drawingName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        onSave(name)
        isPresented = false
    }
}
