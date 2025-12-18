//
//  TrackpadGestureHandler.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 17/12/25.
//

import SwiftUI
import UIKit

class TrackpadGestureHandler: NSObject, UIGestureRecognizerDelegate {
    weak var canvasView: UIView?
    var onPanGesture: ((CGPoint) -> Void)?
    var onZoomGesture: ((CGFloat) -> Void)?
    
    private var panGesture: UIPanGestureRecognizer?
    private var pinchGesture: UIPinchGestureRecognizer?
    
    init(canvasView: UIView) {
        self.canvasView = canvasView
        super.init()
        setupGestures()
    }
    
    private func setupGestures() {
        guard let canvas = canvasView else { return }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        pan.delegate = self
        canvas.addGestureRecognizer(pan)
        panGesture = pan
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        canvas.addGestureRecognizer(pinch)
        pinchGesture = pinch
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.numberOfTouches == 2 else { return }
        
        let translation = gesture.translation(in: gesture.view)
        onPanGesture?(translation)
        
        if gesture.state == .ended {
            gesture.setTranslation(.zero, in: gesture.view)
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        onZoomGesture?(gesture.scale)
        
        if gesture.state == .ended {
            gesture.scale = 1.0
        }
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

struct TrackpadGestureView: UIViewRepresentable {
    let onPan: (CGPoint) -> Void
    let onZoom: (CGFloat) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        context.coordinator.setupHandler(for: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPan: onPan, onZoom: onZoom)
    }
    
    class Coordinator {
        var handler: TrackpadGestureHandler?
        let onPan: (CGPoint) -> Void
        let onZoom: (CGFloat) -> Void
        
        init(onPan: @escaping (CGPoint) -> Void, onZoom: @escaping (CGFloat) -> Void) {
            self.onPan = onPan
            self.onZoom = onZoom
        }
        
        func setupHandler(for view: UIView) {
            handler = TrackpadGestureHandler(canvasView: view)
            handler?.onPanGesture = onPan
            handler?.onZoomGesture = onZoom
        }
    }
}
