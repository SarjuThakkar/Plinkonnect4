//
//  SoundManager.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/25/25.
//

import SpriteKit

class SoundManager {
    static let shared = SoundManager()

    private let pegHitSounds = ["aNote.wav", "cNote.wav", "dNote.wav", "eNote.wav", "gNote.wav"]
    private var lastPegSoundTime: TimeInterval = 0

    private init() {}

    func playPegHitSound(on scene: SKScene, velocity: CGFloat) {
        guard !HomeScene.isMuted, velocity > 100 else { return }

        let now = CACurrentMediaTime()
        guard now - lastPegSoundTime > 0.1 else { return }

        let soundName = pegHitSounds.randomElement() ?? "aNote.wav"
        scene.run(SKAction.playSoundFileNamed(soundName, waitForCompletion: false))
        lastPegSoundTime = now
    }
}
