import AVFoundation
import SwiftUI
import Combine

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    private var currentBackgroundMusicName: String?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erreur configuration audio session: \(error)")
        }
    }
    
    func playBackgroundMusic(named name: String, volume: Float = 0.3) {
        if currentBackgroundMusicName == name && backgroundMusicPlayer?.isPlaying == true {
            return
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Musique de fond non trouvée: \(name)")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = volume
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
            currentBackgroundMusicName = name
        } catch {
            print("Erreur lecture musique de fond: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        currentBackgroundMusicName = nil
    }
    
    func playSoundEffect(named name: String, volume: Float = 0.7) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Son non trouvé: \(name)")
            return
        }
        
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.volume = volume
            soundEffectPlayer?.prepareToPlay()
            soundEffectPlayer?.play()
        } catch {
            print("Erreur lecture son: \(error)")
        }
    }
}
