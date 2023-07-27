import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func willDismissDetailViewController()
}

class ViewController: UIViewController, DetailViewControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var startstopBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var image: UIImage?
    var imageNames = ["bard", "cat", "dog"]
    var currentIndex = 0
    var timer: Timer?
    var isSlideshowStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextBtn.setImage(UIImage(named: "right"), for: .normal)
        backBtn.setImage(UIImage(named: "left"), for: .normal)
        startstopBtn.setImage(UIImage(named: "start"), for: .normal)
        
        updateImage()
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resumeSlideShowIfNeeded()
    }
    
    func resumeSlideShowIfNeeded() {
        if timer == nil, isSlideshowStarted {
            startSlideShow()
        }
    }
    
    @IBAction func nextImage(_ sender: Any) {
        stopSlideShow()
        currentIndex = (currentIndex + 1) % imageNames.count
        updateImageWithTransition(fromLeft: false)
    }
    
    @IBAction func prevImage(_ sender: Any) {
        stopSlideShow()
        currentIndex = (currentIndex - 1 + imageNames.count) % imageNames.count
        updateImageWithTransition(fromLeft: true)
    }
    
    @IBAction func startStopSlideShow(_ sender: Any) {
        if timer != nil {
            nextBtn.isHidden = false
            backBtn.isHidden = false
            startstopBtn.setImage(UIImage(named: "start"), for: .normal)
            stopSlideShow()
        } else {
            nextBtn.isHidden = true
            backBtn.isHidden = true
            startstopBtn.setImage(UIImage(named: "stop"), for: .normal)
            startSlideShow()
            isSlideshowStarted = true
        }
    }
    
    func startSlideShow() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(autoNextImage), userInfo: nil, repeats: true)
    }
    
    func stopSlideShow() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func autoNextImage() {
        currentIndex = (currentIndex + 1) % imageNames.count
        updateImageWithTransition(fromLeft: false)
    }
    
    func updateImage() {
        let image = UIImage(named: imageNames[currentIndex])
        imageView.image = image
    }
    
    func updateImageWithTransition(fromLeft: Bool) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = fromLeft ? .fromLeft : .fromRight
        imageView.layer.add(transition, forKey: nil)
        
        let image = UIImage(named: imageNames[currentIndex])
        imageView.image = image
    }
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        if let tappedImageView = sender.view as? UIImageView {
            image = tappedImageView.image
            stopSlideShow()
            performSegue(withIdentifier: "ShowDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let resultViewController = segue.destination as? DetailViewController
            resultViewController?.image = image
            resultViewController?.delegate = self
        }
    }
    
    func willDismissDetailViewController() {
        resumeSlideShowIfNeeded()
    }
}

