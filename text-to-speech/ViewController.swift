import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var tvSpeechText: UITextField!
    @IBOutlet weak var lbRate: UILabel!
    @IBOutlet weak var sRate: UISlider!
    @IBOutlet weak var ddVoice: UIButton!
    
    let synthesizer = AVSpeechSynthesizer()
    var voices: [AVSpeechSynthesisVoice] = []
    var selectedVoice: AVSpeechSynthesisVoice? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        synthesizer.delegate = self
        configureAudioSession()
        fetchAvailableVoices()
    }
    
    func fetchAvailableVoices() {
        voices = AVSpeechSynthesisVoice.speechVoices()
    }
    
    @IBAction func onDropdownVoice(_ sender: UIButton) {
        showVoiceSelection()
    }
    
    func setupUI() {
        sRate.minimumValue = 0.1
        sRate.maximumValue = 1.0
        sRate.value = 0.5
        updateLabelWithValue(sRate.value)
    }
    
    func updateLabelWithValue(_ value: Float) {
        lbRate.text = String(format: "%.2f", value)
    }
    
    @IBAction func onSliderUpdate(_ sender: UISlider) {
        let value = sender.value
        updateLabelWithValue(value)
    }
    
    func showVoiceSelection() {
        let alertController = UIAlertController(title: "Select Voice", message: nil, preferredStyle: .actionSheet)
        
        for voice in voices {
            let action = UIAlertAction(title: "\(voice.name)(\(voice.language))", style: .default) { action in
                
                for myVoice in self.voices {
                    if(action.title == "\(myVoice.name)(\(myVoice.language))"){
                        self.selectedVoice = myVoice
                        self.ddVoice.setTitle("\(myVoice.name)(\(myVoice.language))",for: UIControl.State.normal)
                    }
                }
                print(action)
            }
            alertController.addAction(action)
        }
        
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        let statement = tvSpeechText.text ?? "No statement"
        if(selectedVoice?.language != nil){
            speak(text: statement, language: selectedVoice?.language ?? "en-US", voiceIdentifier: selectedVoice?.identifier)
        }else{
            let alertController = UIAlertController(title: "validation error", message: "Please select voice", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                // Handle OK button tap action here
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
       
    }
    
    func speak(text: String, language: String, voiceIdentifier: String? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        if let rate = Float(lbRate.text ?? "0.5") {
            utterance.rate = rate
        } else {
            print("Invalid string for conversion to Float")
        }
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        if let voiceIdentifier = voiceIdentifier {
            utterance.voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)
        }
        
        synthesizer.speak(utterance)
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("AVAudioSession configured successfully")
        } catch {
            print("Failed to set up AVAudioSession: \(error.localizedDescription)")
        }
    }
    
}

extension ViewController: AVSpeechSynthesizerDelegate {
    // Implement delegate methods here if needed
}
