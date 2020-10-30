//
//  AudioRecorder.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/30/20.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    
    static let shared = AudioRecorder()
    
    private override init(){
        super.init()
        checkForRecordPermission()
    }
    
    func checkForRecordPermission(){
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission {
                self.isAudioRecordingGranted = $0
            }
        default: break
        
        }
    }
    
    func setupRecorder(){
        if isAudioRecordingGranted{
            recordingSession = AVAudioSession.sharedInstance()
             
            do {
                
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                
            } catch (let error){
                print(error.localizedDescription)
            }
        }
    }
    
    func startRecording(fileName: String){
        let audioFileName = getDocumentsURL().appendingPathComponent(fileName + ".m4a", isDirectory: false)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch (let error){
            print("error while recoding \(error.localizedDescription)")
            finisRecording()
        }
    }
    func finisRecording(){
        if audioRecorder != nil{
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
}
