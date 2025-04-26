//
//  Extensions.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/25/25.
//



import CoreGraphics

extension CGVector {
    /// Returns the length (magnitude) of the vector.
    func length() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
}
