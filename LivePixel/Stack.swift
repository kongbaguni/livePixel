//
//  Stack.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import Foundation

struct Stack<Element> {
    private var elements: [Element] = []

    mutating func push(_ element: Element) {
        elements.append(element)
    }

    mutating func pop() -> Element? {
        return elements.popLast()
    }

    func peek() -> Element? {
        return elements.last
    }

    var isEmpty: Bool {
        return elements.isEmpty
    }

    var count: Int {
        return elements.count
    }
}
